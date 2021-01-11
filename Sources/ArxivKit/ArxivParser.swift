
import Foundation

#if canImport(FoundationXML)
import FoundationXML
#endif

/**
 A parser for arXiv API atom feed.
 */
public final class ArxivParser {
    
    private var xmlParser: XMLParser?
    
    private var xmlParserDelegate: ParserDelegate?
    
    fileprivate var finishedParsing: ((Result<ArxivResponse, ArxivKitError>) -> ())?
    
    /// Creates a parser.
    public init() {
        
    }
}

// MARK: - Public `Parser` Methods

public extension ArxivParser {
    
    /**
     Parses provided response data into `ArxivResponse`.
     
     - Parameter responseData: Raw data of arXiv API response.
     - Parameter completion: A function to be called after the parsing finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed response, or an error if one occurs.
     */
    func parse(responseData: Data, completion: @escaping (Result<ArxivResponse, ArxivKitError>) -> ()) {
        finishedParsing = completion
        self.xmlParser = XMLParser(data: responseData)
        let xmlParserDelegate = ParserDelegate(parent: self)
        self.xmlParser?.delegate = xmlParserDelegate
        let success = self.xmlParser?.parse()
        if let success = success, !success, let error = xmlParser?.parserError {
            finishedParsing?(.failure(.parseError(error)))
            cleanupXMLParser()
        }
    }
    
    /**
     Aborts parsing.
     
     After parsing is aborted, completion handler provided to `parse(responseData:completion:)`
     is called with `.failure(ArxivKitError.parsingCanceled)`.
     */
    func abort() {
        xmlParser?.abortParsing()
        finishedParsing?(.failure(.parsingCanceled))
        cleanupXMLParser()
    }
}

// MARK: - Private `Parser` Methods

private extension ArxivParser {
    
    func cleanupXMLParser() {
        self.xmlParser = nil
        self.xmlParserDelegate = nil
    }
}

// MARK: - Delegate

private final class ParserDelegate: NSObject {
    
    weak var parent: ArxivParser?
    
    private var dateFormater: DateFormatter
    
    private var response = ArxivResponse()
        
    private var currentString = ""
    
    private var currentEntry: ArxivEntry?
    
    private var currentAuthor: ArxivEntry.Author?
    
    init(parent: ArxivParser) {
        self.parent = parent
        dateFormater = DateFormatter()
        dateFormater.locale = .current
    }
}

// MARK: - `XMLParserDelegate`

extension ParserDelegate: XMLParserDelegate {
    
    func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
                
        if elementName == FeedConstant.entry.value {
            currentEntry = ArxivEntry()
            return
        }
   
        if elementName == FeedConstant.Entry.author.value {
            currentAuthor = ArxivEntry.Author()
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
       
        if elementName == FeedConstant.feed.value {
            if response.entries.count == 1 && response.entries[0].title == FeedConstant.Entry.errorTitle.value {
                parent?.finishedParsing?(.failure(.apiError(response.entries[0].summary)))
            } else {
                parent?.finishedParsing?(.success(response))
            }
            parent?.cleanupXMLParser()
            return
        }
        
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
        if !((parseError as NSError).code == XMLParser.ErrorCode.delegateAbortedParseError.rawValue) {
            parent?.finishedParsing?(.failure(.parseError(parseError)))
        }
        parent?.cleanupXMLParser()
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError:Error) {
        parent?.finishedParsing?(.failure(.validationError(validationError)))
        parent?.cleanupXMLParser()
    }
}

// MARK: - Private `ParserDelefate` methods

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
            currentEntry?.primaryCategory = categoryName
            return true
        }
        
        if elementName == FeedConstant.Entry.category.value,
           let categoryName = attributeDict[FeedConstant.Entry.categoryTerm.value] {
            currentEntry?.categories.append(categoryName)
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
            response.title = currentString.trimmingWhiteSpaces.removingNewLine
        case FeedConstant.id.value:
            response.id = currentString.trimmingWhiteSpaces.removingNewLine
        case FeedConstant.updated.value:
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss-hh:mm"
            if let updatedDate = dateFormater.date(from: currentString) {
                response.updated = updatedDate
            }
        case FeedConstant.totalResults.value:
            if let totalResultsInt = Int(currentString.trimmingWhiteSpaces) {
                response.totalResults = totalResultsInt
            }
        case FeedConstant.startIndex.value:
            if let startIndexInt = Int(currentString.trimmingWhiteSpaces) {
                response.startIndex = startIndexInt
            }
        case FeedConstant.itemsPerPage.value:
            if let itemsPerPageInt = Int(currentString.trimmingWhiteSpaces) {
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
            currentEntry?.id = idFromAbstractLink(currentString.trimmingWhiteSpaces)
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
            currentEntry?.title = currentString.trimmingWhiteSpaces.removingNewLine
        case FeedConstant.Entry.summary.value:
            currentEntry?.summary = currentString.trimmingWhiteSpaces.replacingNewLineWithSpace
        case FeedConstant.Entry.doi.value:
            currentEntry?.doi = currentString.trimmingWhiteSpaces.removingNewLine
        case FeedConstant.Entry.comment.value:
            currentEntry?.comment = currentString.trimmingWhiteSpaces.replacingNewLineWithSpace
        case FeedConstant.Entry.journalReference.value:
            currentEntry?.journalReference = currentString.trimmingWhiteSpaces.removingNewLine
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
            currentAuthor?.name = currentString.trimmingWhiteSpaces
        case FeedConstant.Entry.Author.affiliation.value:
            currentAuthor?.affiliation = currentString.trimmingWhiteSpaces
        default:
            break
        }
        return true
    }
    
    func idFromAbstractLink(_ abstractLink: String) -> String {
        guard var pathComponents = URL(string: abstractLink)?.pathComponents else {
            return ""
        }
        
        pathComponents.removeFirst(2)
        
        return pathComponents.joined(separator: "/")
    }
}

