
import Foundation


public final class Fetcher {
    
    public enum Error: Swift.Error {
        case invalidRequest
        case urlSessionError(String)
        case apiError(String)
        case parseError(String)
        case validationError(String)
    }
    
    private let urlSessionConfiguration = URLSessionConfiguration.default
    
    private var urlSession: URLSession?
    
    private var dataTask: URLSessionDataTask?
    
    private var xmlParser: XMLParser?
    
    private var xmlParserDelegate: ParserDelegate?
    
    private let parserQueue = DispatchQueue(label: "io.polifonia.ArticlesKit.parserQueue")
    
    fileprivate var finishedParsing: ((Result<Response, Error>) -> ())?
    
    public init() {
        
    }
    
    public func fetch(_ request: Request, completion: @escaping (Result<Response, Error>) -> ()) {
        guard let requestURL = request.url else {
            completion(.failure(.invalidRequest))
            return
        }
        
        finishedParsing = completion
        urlSession = URLSession(configuration: urlSessionConfiguration)
        dataTask = urlSession?.dataTask(with: URLRequest(url: requestURL)) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                self.finishedParsing?(.failure(.urlSessionError(error.localizedDescription)))
            } else if let data = data {
                self.parserQueue.async {
                    self.xmlParser = XMLParser(data: data)
                    let xmlParserDelegate = ParserDelegate(parent: self)
                    self.xmlParser?.delegate = xmlParserDelegate
                    self.xmlParser?.parse()
                }
            }
            self.cleanupURLSession()
        }
        dataTask?.resume()
    }
    
    public func abortParsing() {
        parserQueue.async { [weak self] in
            guard let self = self else { return }
            self.xmlParser?.abortParsing()
            self.cleanupXMLParser()
            self.cleanupURLSession()
        }
    }
    
    private func cleanupURLSession() {
        self.urlSession?.invalidateAndCancel()
        self.urlSession = nil
        self.dataTask = nil
    }
    
    private func cleanupXMLParser() {
        self.xmlParser = nil
        self.xmlParserDelegate = nil
    }
}

private final class ParserDelegate: NSObject, XMLParserDelegate {
    
    let parent: Fetcher
    
    private var dateFormater: DateFormatter
    
    private var response = Response()
        
    private var currentString = ""
    
    private var currentEntry: Entry?
    
    private var currentAuthor: Entry.Author?
    
    init(parent: Fetcher) {
        self.parent = parent
        dateFormater = DateFormatter()
        dateFormater.locale = .current
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if response.entries.count == 1 && response.entries[0].title == FeedConstant.Entry.errorTitle.value {
            parent.finishedParsing?(.failure(.apiError(response.entries[0].summary)))
            return
        }
        parent.finishedParsing?(.success(response))
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
                
        if elementName == FeedConstant.entry.value {
            currentEntry = Entry()
            return
        }
   
        if elementName == FeedConstant.Entry.author.value {
            currentAuthor = Entry.Author()
            return
        }
        
        if parseLink(elementName, attributeDict) {
            return
        }
        
        if parseCategoryElement(elementName, attributeDict) {
            return
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
       
        currentString.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
       
        if let author = currentAuthor, elementName == FeedConstant.Entry.author.value {
            currentEntry?.authors.append(author)
            currentAuthor = nil
            return
        }
        
        if let entry = currentEntry, elementName == FeedConstant.entry.value {
            response.entries.append(entry)
            currentEntry = nil
            return
        }
        
        if parseFeedElement(elementName) || parseEntryElement(elementName) || parseAuthorElement(elementName) {
           currentString = ""
            return
        }
        
        
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        parent.finishedParsing?(.failure(.parseError(parseError.localizedDescription)))
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        parent.finishedParsing?(.failure(.validationError(validationError.localizedDescription)))
    }
}

private extension ParserDelegate {
    
    func parseLink(_ elementName: String, _ attributeDict: [String : String]) -> Bool {
        
        if currentEntry == nil && elementName == FeedConstant.link.value,
           let feedPath = attributeDict[FeedConstant.href.value]?.removingPercentEncoding,
           let feedURL = URL(string: feedPath) {
                response.link = feedURL
            return true
        }
        
        if currentEntry != nil, elementName == FeedConstant.Entry.link.value,
            let path = attributeDict[FeedConstant.href.value]?.removingPercentEncoding,
            let url = URL(string: path){
            
            switch (attributeDict[FeedConstant.Entry.Link.rel.value], attributeDict[FeedConstant.Entry.Link.title.value]) {
            case (FeedConstant.Entry.Link.alternate.value?, nil):
                currentEntry?.abstractURL = url
            case (FeedConstant.Entry.Link.related.value?, FeedConstant.Entry.Link.pdf.value?):
                currentEntry?.pdfURL = url
            case (FeedConstant.Entry.Link.related.value?, FeedConstant.Entry.Link.doi.value?):
                currentEntry?.doiURL = url
            default:
                return false
            }
            return true
        }
        
        return false
    }
    
    func parseCategoryElement(_ elementName: String, _ attributeDict: [String : String]) -> Bool {
        
        guard currentEntry != nil else {
            return false
        }
        
        if elementName == FeedConstant.Entry.primaryCategory.value,
           let categoryName = attributeDict[FeedConstant.Entry.categoryTerm.value] {
            currentEntry?.primaryCategory = Subject(categoryName)
            return true
        }
        
        if elementName == FeedConstant.Entry.category.value,
           let categoryName = attributeDict[FeedConstant.Entry.categoryTerm.value] {
            currentEntry?.categories.append(Subject(categoryName))
            return true
        }
        
        return false
    }
    
    func parseFeedElement(_ elementName: String) -> Bool {
        
        guard currentEntry == nil else {
            return false
        }
        
        switch elementName {
        case FeedConstant.title.value:
            response.title = currentString.trimingWhiteSpaces.removingNewLine
        case FeedConstant.id.value:
            response.id = currentString.trimingWhiteSpaces.removingNewLine
        case FeedConstant.updated.value:
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-hh:mm"
            if let updatedDate = dateFormater.date(from: currentString) {
                response.updated = updatedDate
            }
        case FeedConstant.totalResults.value:
            if let totalResultsInt = Int(currentString) {
                response.totalResults = totalResultsInt
            }
        case FeedConstant.startIndex.value:
            if let startIndexInt = Int(currentString) {
                response.startIndex = startIndexInt
            }
        case FeedConstant.itemsPerPage.value:
            if let itemsPerPageInt = Int(currentString) {
                response.itemsPerPage = itemsPerPageInt
            }
        default:
            break
        }
        
        return true
    }
    
    func parseEntryElement(_ elementName: String) -> Bool {
        
        guard currentEntry != nil else {
            return false
        }
        
        switch elementName {
        case FeedConstant.Entry.id.value:
            currentEntry?.id = currentString.trimingWhiteSpaces
        case FeedConstant.Entry.updated.value:
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let updatedDate = dateFormater.date(from: currentString) {
                currentEntry?.updated = updatedDate
            }
        case FeedConstant.Entry.published.value:
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let publishedDate = dateFormater.date(from: currentString) {
                currentEntry?.published = publishedDate
            }
        case FeedConstant.Entry.title.value:
            currentEntry?.title = currentString.trimingWhiteSpaces.removingNewLine
        case FeedConstant.Entry.summary.value:
            currentEntry?.summary = currentString.trimingWhiteSpaces.replacingNewLineWithSpace
        case FeedConstant.Entry.doi.value:
            currentEntry?.doi = currentString.trimingWhiteSpaces.removingNewLine
        case FeedConstant.Entry.comment.value:
            currentEntry?.comment = currentString.trimingWhiteSpaces.replacingNewLineWithSpace
        case FeedConstant.Entry.journalReference.value:
            currentEntry?.journalReference = currentString.trimingWhiteSpaces.removingNewLine
        default:
            return false
        }
        
        return true
    }
    
    func parseAuthorElement(_ elementName: String) -> Bool {
               
        guard currentAuthor != nil else {
            return false
        }
        
        switch elementName {
        case FeedConstant.Entry.Author.name.value:
            currentAuthor?.name = currentString.trimingWhiteSpaces
        case FeedConstant.Entry.Author.affiliation.value:
            currentAuthor?.affiliation = currentString.trimingWhiteSpaces
        default:
            break
        }
        return true
    }
}

private extension String {
    
    var trimingWhiteSpaces: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var removingNewLine: String {
        replacingOccurrences(of: "\n", with: "")
    }
    
    var replacingNewLineWithSpace: String {
        replacingOccurrences(of: "\n", with: " ")
    }
}
