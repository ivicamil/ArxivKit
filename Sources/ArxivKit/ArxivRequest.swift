
import Foundation


public struct ArxivRequest {
    
    /// Query portion of the request.
    ///
    /// Default value is empty query `SearchQuery.all("")`.
    /// Either a valid  non-empty`searchQuery` or a non-empty valid `idlist` must be provided.
    public let searchQuery: ArxivQuery
    
    /// A list of article ids to search for.
    ///
    /// Default value is empty array.
    /// Either a valid `query` or a non-empty valid `idlist` must be provided.
    /// To search for specific version of an article, append the article's id with `vn` where `n` is the desired version number.
    public let idList: [String]
    
    public internal(set) var startIndex: Int = 0
    
    public let itemsPerPage: Int
    
    public let sortBy: SortBy
    
    public let sortOrder: SortOrder
   
    private let scheme = "https"
    private let host = "export.arxiv.org"
    private let path = "/api/query"
    private let searchQueryKey = "search_query"
    private let idListKey = "id_list"
    private let startIndexKey = "start"
    private let itemsPerPageKey = "max_results"
    private let sortByKey = "sortBy"
    private let sortOrderKey = "sortOrder"
    
    public init(
        searchQuery: ArxivQuery = .all(""),
        idList: [String] = [],
        itemsPerPage: Int = 50,
        sortBy: SortBy = .lastUpdatedDate,
        sortOrder: SortOrder = .descending
    ) {
        self.searchQuery = searchQuery
        self.idList = idList
        self.itemsPerPage = itemsPerPage <= 100 ? itemsPerPage : 100
        self.sortBy = sortBy
        self.sortOrder = sortOrder
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
}

public extension ArxivRequest {
    
    /// Returns a new request for given page `startIndex`.
    func withStartIndex(_ index: Int) -> ArxivRequest {
        var page = self
        page.startIndex = index
        return page
    }
}

public extension ArxivRequest {
    
    /// Request for specific article with given id.
    ///
    /// - Parameter id: arXiv id of desired article.
    /// - Parameter version: Desired version of the article. Default value 0 or any negative value returns request for the most recent version.
    static func article(id: String, version: Int = 0) -> ArxivRequest  {
        let versionSuffix = version > 0 ? "v\(version)" : ""
        return ArxivRequest(idList: ["\(ArxivEntry.versionlessId(from: id))\(versionSuffix)"])
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
            URLQueryItem(name: sortOrderKey, value: sortOrder.rawValue),
            URLQueryItem(name: sortByKey, value: sortBy.rawValue),
            URLQueryItem(name: startIndexKey, value: "\(startIndex)"),
            URLQueryItem(name: itemsPerPageKey, value: "\(itemsPerPage)")
        ])
        
        return components.url
    }
}
