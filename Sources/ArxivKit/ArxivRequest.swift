
import Foundation

public struct ArxivRequest {
    
    public let searchQuery: ArxivQuery
    
    public private(set) var idList: [String]
    
    public private(set) var startIndex: Int = 0
    
    public private(set) var itemsPerPage: Int
    
    public private(set) var sortedBy: SortingCriterion
    
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
    
    public init(idList: [String] = [], _ query: ArxivQuery) {
        self.init(searchQuery: query, ids: idList)
    }
    
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
        self.searchQuery = searchQuery
        self.idList = ids
        self.itemsPerPage = itemsPerPage <= 100 ? itemsPerPage : 100
        self.sortedBy = sortBy
        self.sortingOrder = sortOrder
    }
    
    public struct SortingCriterion {
        
        let rawValue: String
        
        private init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static var relevance = SortingCriterion("relevance")
        
        public static var lastUpdatedDate = SortingCriterion("lastUpdatedDate")
        
        public static var submitedDate = SortingCriterion("submittedDate")
    }
    
    public struct SortingOrder {
        
        let rawValue: String
        
        private init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static var descending = SortingOrder("descending")
        public static var ascending = SortingOrder("ascending")
    }
}

public extension ArxivRequest {
    
    func sortedBy(_ sortCriterion: SortingCriterion) -> ArxivRequest {
        var request = self
        request.sortedBy = sortCriterion
        return request
    }
    
    func sortingOrder(_ sortingOrder: SortingOrder) -> ArxivRequest {
        var request = self
        request.sortingOrder = sortingOrder
        return request
    }
    
    func startIndex(_ i: Int) -> ArxivRequest {
        var request = self
        request.startIndex = i
        return request
    }
    
    func itemsPerPage(_ n: Int) -> ArxivRequest {
        var request = self
        request.itemsPerPage = n
        return request
    }
}

public extension ArxivRequest {
    
    enum SearchScope {
        case anyArticle
        case articlesWithIDs([String])
    }
}

public extension ArxivQuery {
    
    func search(in scope: ArxivRequest.SearchScope) -> ArxivRequest {
        switch scope {
        case .anyArticle:
            return ArxivRequest(self)
        case let .articlesWithIDs(idList):
            return ArxivRequest(idList: idList, self)
        }
    }
}

public extension ArxivRequest {
    
    var url: URL? {
        var components = URLComponents()
        
        components.scheme = scheme
        components.host = host
        components.path = path
        
        components.queryItems = []
        
        if !searchQuery.isEmpty {
            components.queryItems?.append(URLQueryItem(name: searchQueryKey, value: searchQuery.string))
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


