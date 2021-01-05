
import Foundation


public struct Request {
    
    /// Query portion of the request.
    ///
    /// Default value is empty query `Query.all("")`.
    /// Either a valid `query` or a non-empty valid `idlist` must be provided.
    public let query: Query
    
    /// A list of article ids to search for.
    ///
    /// Default value is empty array.
    /// Either a valid `query` or a non-empty valid `idlist` must be provided.
    /// To search for specific version of an article, append the article's id with `vn` where `n` is the desired version number.
    public let idList: [String]
    
    /// 
    public var startIndex: Int = 0
    
    public let itemsPerPage: Int
    
    public let sortingRule: SortingRule
   
    private let scheme = "https"
    private let host = "export.arxiv.org"
    private let path = "/api/query"
    private let searchQueryKey = "search_query"
    private let idListKey = "id_list"
    private let startIndexKey = "start"
    private let itemsPerPageKey = "max_results"
    private let sortByKey = "sortBy"
    private let sortOrderKey = "sortOrder"
    
    public init(query: Query = .all(""), idList: [String] = [], itemsPerPage: Int = 50, sortingRule: SortingRule = SortingRule(sortBy: .lastUpdatedDate, sortOrder: .descending)) {
        self.query = query
        self.idList = idList
        self.itemsPerPage = itemsPerPage <= 100 ? itemsPerPage : 100
        self.sortingRule = sortingRule
    }
    
    public enum SortBy : String {
        case relevance = "relevance"
        case lastUpdatedDate = "lastUpdatedDate"
        case submitedDate = "submittedDate"
    }
    
    public enum SortOrder : String {
        case descending = "descending"
        case ascending = "ascending"
    }
    
    public struct SortingRule {
        
        let sortBy: SortBy
        
        let sortOrder: SortOrder
        
        public init(sortBy: SortBy, sortOrder: SortOrder) {
            self.sortBy = sortBy
            self.sortOrder = sortOrder
        }
    }
}

public extension Request {
    
    /// Returns a new request for next page.
    func nextPage() -> Request {
        var nextPageRequest = self
        nextPageRequest.startIndex = self.startIndex + 1
        return nextPageRequest
    }
    
    /// Returns a new request for previous page or nil, if the caller's startIndex is 0.
    func previousPage() -> Request? {
        if self.startIndex  == 0 {
            return nil
        } else {
            var previousPageRequest = self
            previousPageRequest.startIndex = self.startIndex - 1
            return previousPageRequest
        }
    }
}

public extension Request {
    
    var url: URL? {
        var components = URLComponents()
        
        components.scheme = scheme
        components.host = host
        components.path = path
        
        components.queryItems = [
            URLQueryItem(name: searchQueryKey, value: query.string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            URLQueryItem(name: idListKey, value: idList.joined(separator: ",")),
            URLQueryItem(name: sortOrderKey, value: sortingRule.sortOrder.rawValue),
            URLQueryItem(name: sortByKey, value: sortingRule.sortBy.rawValue),
            URLQueryItem(name: startIndexKey, value: "\(startIndex)"),
            URLQueryItem(name: itemsPerPageKey, value: "\(itemsPerPage)")
        ]
        
        return components.url
    }
}
