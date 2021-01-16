
import Foundation

#if canImport(FoundationXML)
import FoundationXML
#endif

/**
 A parser for arXiv API atom feed.
 */
public final class ArxivParser {
    
    fileprivate var result: Result<ArxivResponse, Error>?

    /// Creates a parser.
    public init() {
        
    }
}

// MARK: - Public `Parser` Methods

public extension ArxivParser {
        
    /**
     Parses provided response data into `ArxivResponse`.
     
     - Parameter responseData: Raw data of arXiv API response.
     
     - Throws: `ArxivParserError` or `ArxivAPIError`.
     */
    func parse(responseData: Data) throws -> ArxivResponse {
        let xmlParser = XMLParser(data: responseData)
        let xmlParserDelegate = ParserDelegate(parent: self)
        xmlParser.delegate = xmlParserDelegate
        let _ = xmlParser.parse()
        
        guard let result = result else {
            throw ArxivParserError.unexpectedParseError
        }
        
        return try result.get()
    }
}

// MARK: - Delegate

private final class ParserDelegate: NSObject {
    
    let parent: ArxivParser
    
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
                parent.result = .failure(ArxivAPIError(description: response.entries[0].summary))
            } else if response.totalResults > 0 && response.entries.count == 0 {
                let unknownAPIError = "Unknwon API error. Server reporeted \(response.totalResults) total results, but returned no entries."
                parent.result = .failure(ArxivAPIError(description: unknownAPIError))
            }
            else {
                parent.result = .success(response)
            }
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
        parent.result = .failure(ArxivParserError.parseError(parseError))
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError:Error) {
        parent.result = .failure(ArxivParserError.validationError(validationError))
    }
}

// MARK: - Private `ParserDelegate` methods

private extension ParserDelegate {
    
    func parseLink(_ elementName: String, _ attributeDict: [String : String]) -> Bool {
        
        if currentEntry == nil && elementName == FeedConstant.link.value,
           let feedPath = attributeDict[FeedConstant.href.value],
           let feedURL = URL(string: feedPath) {
                response.link = feedURL
            return true
        }
        
        if currentEntry != nil, elementName == FeedConstant.Entry.link.value,
            let path = attributeDict[FeedConstant.href.value],
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
                response.updatedDate = updatedDate
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
            currentEntry?.id = idFromAbstractURL(currentString.trimmingWhiteSpaces)
        case FeedConstant.Entry.updated.value:
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let updatedDate = dateFormater.date(from: currentString) {
                currentEntry?.lastUpdateDate = updatedDate
            }
        case FeedConstant.Entry.published.value:
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let publishedDate = dateFormater.date(from: currentString) {
                currentEntry?.submissionDate = publishedDate
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
    
    func idFromAbstractURL(_ abstractURLString: String) -> String {
        guard var pathComponents = URL(string: abstractURLString)?.pathComponents else {
            return ""
        }
        
        pathComponents.removeFirst(2)
        
        return pathComponents.joined(separator: "/")
    }
}

