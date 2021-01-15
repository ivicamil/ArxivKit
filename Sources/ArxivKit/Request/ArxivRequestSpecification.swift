
import Foundation

private let scheme = "https"
private let host = "export.arxiv.org"
private let path = "/api/query"
private let searchQueryKey = "search_query"
private let idListKey = "id_list"
private let startIndexKey = "start"
private let itemsPerPageKey = "max_results"
private let sortByKey = "sortBy"
private let sortOrderKey = "sortOrder"

private let lastUpdatedDateValue = "lastUpdatedDate"
private let submittedDateValue = "submittedDate"
private let relevanceValue = "relevance"

private let ascendingValue = "ascending"
private let descendingValue = "descending"

/**
 A full sppecification of an arXiv API request.
 */
public struct ArxivRequestSpecification: Codable {
    
    /// Returns a query used for  the request or `nil` if the request consists of `idList` only.
    public let query: ArxivQuery?
    
    /// Returns an array od article ids. If the array is non-empty, qyery matching is limmited to specified articles.
    public private(set) var idList: [String]
    
    /**
     Returns zero-based index of the first article in the response. Set using `startIndex(_)` method.
     Default value is `0`.
     
     The index can be used to implement paging. For example, if `itemsPerPage` is 20, the first page is with `startIndex == 0` ,
     the second with `startIndex == 20`, the third with `startIndex == 60` etc.
     
     `ArxivReponse` values can be used for getting various page indicies for given response.
     */
    public internal(set) var startIndex: Int
    
    /// Returns maximum number of articles to be returned from a single API call. Set using `itemsPerPage(_)` method. Default value is 50.
    public internal(set) var itemsPerPage: Int
    
    /// Returns sorting criterion for returned articles. Set using `sorted(by:)` method. Default value is `.lastUpdateDate`.
    public internal(set) var sortingCriterion: SortingCriterion
    
    /// Returns sorting order for returned articles. Set using `sortingOrder(_)` method. Default value is `.descending`.
    public internal(set) var sortingOrder: SortingOrder
    
    /**
     Creates a request for retrieving the articles matching provided query and belonging to optionally provided ID list.
     
     - Parameter query: A specification of search criteria for the request.
     - Parameter iDlist: Search scope for matching the query. Default value is empty list.
     
     If a non-empty `idList` is provided, only the articles with specified IDs will be matched againt the `query`.
     
     To retrieve a specific version of an article, end the corresponding ID with `vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has properties for getting the version versioned IDs of the corresponing article.
     
     For detailed explanation of arXiv identifiers see [arXiv help](https://arxiv.org/help/arxiv_identifier).
    */
    public init(query: ArxivQuery, idList: [String] = []) {
        self.init(searchQuery: query, ids: idList)
    }
    
    /**
     Creates a request for retrieving the articles specified by provided IDs.
     
      - Parameter idList: A list of arXiv article IDs.
     
     To retrieve a specific version of an article, end the corresponding ID with `vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has properties for getting the version and versioned IDs of the corresponing article.
     
     For detailed explanation of arXiv identifiers see [arXiv help](https://arxiv.org/help/arxiv_identifier).
     */
    public init(idList: [String]) {
        self.init(ids: idList)
    }
    
    init(
        searchQuery: ArxivQuery = .empty,
        ids: [String] = [],
        startIndex: Int = 0,
        itemsPerPage: Int = 50,
        sortBy: SortingCriterion = .lastUpdateDate,
        sortOrder: SortingOrder = .descending
    ) {
        self.query = searchQuery
        self.idList = ids
        self.startIndex = startIndex
        self.itemsPerPage = itemsPerPage
        self.sortingCriterion = sortBy
        self.sortingOrder = sortOrder
    }
    
    
    /// Specifies sorting criteria for  articles returned by API calls.
    public struct SortingCriterion: Codable, CustomStringConvertible {
        
        let rawValue: String
        
        private init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Sort returned articles by relevance.
        public static var relevance = SortingCriterion(relevanceValue)
        
        /// Sort returned articles by submission date of the most recent version.
        public static var lastUpdateDate = SortingCriterion(lastUpdatedDateValue)
        
        /// Sort returned articles by submission date of the first version.
        public static var submissionDate = SortingCriterion(submittedDateValue)
        
        public var description: String {
            switch rawValue {
            case relevanceValue:
                return "relevance"
            case lastUpdatedDateValue:
                return "lastUpdateDate"
            case submittedDateValue:
                return "submissionDate"
            default:
                return "unknown"
            }
        }
    }
    
    /// Specifies sorting order for articles returned by API calls.
    public struct SortingOrder: Codable, CustomStringConvertible {
        
        let rawValue: String
        
        private init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Sort returned articles in descending order.
        public static var descending = SortingOrder(descendingValue)
        
        /// Sort returned articles in ascending order.
        public static var ascending = SortingOrder(ascendingValue)
        
        public var description: String {
            return rawValue
        }
    }
}

public extension ArxivQuery {
    
    /**
     Creates a request for retrieving the articles matching the query and belonging to provided ID list.
     
     - Parameter firstID: An arXiv artile IDs.
     - Parameter otherIDs: Other optional IDs.
          
     To retrieve a specific version of an article, end the corresponding ID with `vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has properties for getting the version and versioned IDs of the corresponing article.
     
     For detailed explanation of arXiv identifiers see [arXiv help](https://arxiv.org/help/arxiv_identifier).
     */
    func scopedTo(_ firstID: String, otherIDs: String...) -> ArxivRequestSpecification {
        return ArxivRequestSpecification(query: self, idList: [firstID] + otherIDs)
    }
}

public extension ArxivRequestSpecification {
    
    /// A URL for making arXiv API calls specified by the request.
    var url: URL {
        
        var components = URLComponents()
        
        components.scheme = scheme
        components.host = host
        components.path = path
        
        components.queryItems = []
        
        if let query = query, !query.isEmpty {
            components.queryItems?.append(URLQueryItem(name: searchQueryKey, value: query.string))
        }
        
        if !idList.isEmpty {
            components.queryItems?.append(URLQueryItem(name: idListKey, value: idList.joined(separator: ",")))
        }
        
        components.queryItems?.append(contentsOf: [
            URLQueryItem(name: sortOrderKey, value: sortingOrder.rawValue),
            URLQueryItem(name: sortByKey, value: sortingCriterion.rawValue),
            URLQueryItem(name: startIndexKey, value: "\(startIndex)"),
            URLQueryItem(name: itemsPerPageKey, value: "\(itemsPerPage)")
        ])
        
        guard let requestURL = components.url else {
            /*
             URLComponents documentation states the following:
             
             If the NSURLComponents has an authority component (user, password, host or port)
             and a path component, then the path must either begin with “/” or be an empty string.
             If the NSURLComponents does not have an authority component (user, password, host or port)
             and has a path component, the path component must not start with “//”.
             If those requirements are not met, nil is returned.
             
             As the path here is manualy set to "/api/query", url should never be nil.
             */
            fatalError("Unable to construct URL from ArxivRequest:\n\(self)")
        }
        
        return requestURL
    }
}

extension ArxivRequestSpecification: CustomStringConvertible {
    
    public var description: String {
        return """

        {
            query: \(maybe: query),
            idList: \(idList),
            sortingCriterion: \(sortingCriterion),
            sortingOrder: \(sortingOrder),
            startIndex: \(startIndex),
            itemsPerPage: \(itemsPerPage),
        }

        """
    }
}


