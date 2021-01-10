

import Foundation

/**
 `ArxivRequest` is a full sppecification of an arXiv API request.
 
 `ArxivRequest` is used for constructing `ArxivFetchTask`.
 */
public struct ArxivRequest {
    
    /// Returns a query used for constucting the request or `nil` if the request consists of `idList` only.
    public let query: ArxivQuery?
    
    /// Returns a list od article ids. If the list is non-empty, the search will be limmited to the provided articles.
    public private(set) var idList: [String]
    
    /**
     Returns zero-based index in the list of all the articles matching the `query` and belonging to `idList`,
     of the first article returned by the API call made with the request. It is set by `startIndex(Int)` method.
     
     Use to imlement paging. For example, if `itemsPerPage` is 20, the first page corresponds to `startIndex` 0,
     the second page to `startIndex` 20, the third page to `startIndex` 60 etc.
     `ArxivReponse` values can be used for getting various page indicies for given response.
     */
    public private(set) var startIndex: Int = 0
    
    /// Returns maximum number of articles to be returned from a single API call set by `itemsPerPage(Int)` method. Default value is 50.
    public private(set) var itemsPerPage: Int
    
    /// Returns sorting criterion for returned articles set by `sortedBy(SortingCriterion)` method. Default value is `.lastUpdatedDate`.
    public private(set) var sortedBy: SortingCriterion
    
    /// Returns sorting order for returned articles set by `sortingOrder(SortingOrder)` method. Default value is `.descending`.
    public private(set) var sortingOrder: SortingOrder
   
    private let scheme = "https"
    private let host = "export.arxiv.org"
    private let path = "/api/query"
    private let searchQueryKey = "search_query"
    private let idListKey = "id_list"
    private let startIndexKey = "start"
    private let itemsPerPageKey = "max_results"
    private let sortByKey = "sortBy"
    private let sortOrderKey = "sortOrder"
    
    /**
     Creates a request for retrieving the articles matching the provided query and belonging to the optional ID list.
     
     - Parameter scope: Search scope for matching the query. Default value is `.anyArticle`
     - Parameter query: An `ArxivQuery` value.
     
     If `articlesWithIDs([Strng])` scope is provided, only the articles with specified IDs will be matched againt the `query`.
     
     To retrieve a specific version of an article, end the corresponding ID with`vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has a few  properties for getting the version and and different versioned IDs of the corresponing article.
     For detailed explanation of arXiv identifiers refer to [this link](https://arxiv.org/help/arxiv_identifier).
     
     A fluent alternative to using this initaliser is `makeRequest(scope ArxivRequest.SearchScope)` method on `ArxivQuery`.
     */
    public init(scope: SearchScope = .anyArticle, _ query: ArxivQuery) {
        self.init(searchQuery: query, ids: scope.idList)
    }
    
    /**
     Creates a request for retrieving the articles specified by provided IDs.
     
      - Parameter idList: A list of arXiv article IDs.
     
     To retrieve a specific version of an article, end the corresponding ID with`vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has a few  properties for getting the version and and different versioned IDs of the corresponing article.
     For detailed explanation of arXiv identifiers refer to [this link](https://arxiv.org/help/arxiv_identifier).
     */
    public init(idList: [String]) {
        self.init(ids: idList)
    }
    
    init(
        searchQuery: ArxivQuery = .empty,
        ids: [String] = [],
        itemsPerPage: Int = 50,
        sortBy: SortingCriterion = .lastUpdatedDate,
        sortOrder: SortingOrder = .descending
    ) {
        self.query = searchQuery
        self.idList = ids
        self.itemsPerPage = itemsPerPage
        self.sortedBy = sortBy
        self.sortingOrder = sortOrder
    }
    
    
    /// Defines sorting criteria for  articles returned by API calls.
    public struct SortingCriterion {
        
        let rawValue: String
        
        private init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Sort returned articles by relevance.
        public static var relevance = SortingCriterion("relevance")
        
        /// Sort returned articles by submission date of the most recent version.
        public static var lastUpdatedDate = SortingCriterion("lastUpdatedDate")
        
        /// Sort returned articles by submission date of the first version.
        public static var submitedDate = SortingCriterion("submittedDate")
    }
    
    /// Defines sorting order for articles returned by API calls.
    public struct SortingOrder {
        
        let rawValue: String
        
        private init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        /// Sort returned articles in descending order.
        public static var descending = SortingOrder("descending")
        
        /// Sort returned articles in ascending order.
        public static var ascending = SortingOrder("ascending")
    }
}

public extension ArxivRequest {
            
    /// Returns a new request with provided sorting criterion for returned articles. Default value is `.lastUpdatedDate`.
    func sortedBy(_ sortCriterion: SortingCriterion) -> ArxivRequest {
        var request = self
        request.sortedBy = sortCriterion
        return request
    }
    
    /// Returns a new request with provided sorting order for returned articles. Default value is `.descending`.
    func sortingOrder(_ sortingOrder: SortingOrder) -> ArxivRequest {
        var request = self
        request.sortingOrder = sortingOrder
        return request
    }
    
    /**
     Returns a new request with provided zero-based index in the list of all the articles matching the `query` and belonging to the `idList`,
     of the first article returned by the API call made with the request.
     
     Use to imlement paging. For example, if `itemsPerPage` is 20, the first page corresponds to `startIndex` 0,
     the second page to `startIndex` 20, the third page to `startIndex` 60 etc.
     `ArxivReponse` values can be used for getting various page indicies for given response.
     */
    func startIndex(_ i: Int) -> ArxivRequest {
        var request = self
        request.startIndex = i
        return request
    }
    
    /// Returns a new request with provided  maximum number of articles to be returned from a single API call. Default value is 50.
    func itemsPerPage(_ n: Int) -> ArxivRequest {
        var request = self
        request.itemsPerPage = n
        return request
    }
}

public extension ArxivRequest {
    
    /// Defines scope of the articles to be matched against an `ArxivQuery`.
    enum SearchScope {
        
        /// Match a query against all available articles.
        case anyArticle
        
        /// Match a query only against the articles specified by provided IDs.
        case articlesWithIDs([String])
        
        var idList: [String] {
            switch self {
            case .anyArticle:
                return []
            case let .articlesWithIDs(ids):
                return ids
            }
        }
    }
}

public extension ArxivQuery {
    
    /**
     Creates a request for retrieving the articles matching the query and belonging to the optional ID list.
     
     - Parameter scope: Search scope for matching the query. Default value is `.anyArticle`
     
     If `articlesWithIDs([Strng])` scope is provided, only the articles with specified IDs will be matched againt the query.
     
     To retrieve a specific version of an article, end the corresponding ID with`vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has a few  properties for getting the version and and different versioned IDs of the corresponing article.
     For detailed explanation of arXiv identifiers refer to [this link](https://arxiv.org/help/arxiv_identifier).
     */
    func makeRequest(scope: ArxivRequest.SearchScope = .anyArticle) -> ArxivRequest {
        return ArxivRequest(scope: scope, self)
    }
}

public extension ArxivRequest {
    
    
    /// The url for making an arXiv API call specified by the request or `nil` if the request is not valid.
    var url: URL? {
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
            URLQueryItem(name: sortByKey, value: sortedBy.rawValue),
            URLQueryItem(name: startIndexKey, value: "\(startIndex)"),
            URLQueryItem(name: itemsPerPageKey, value: "\(itemsPerPage)")
        ])
        
        return components.url
    }
}


