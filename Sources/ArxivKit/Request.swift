
import Foundation


public struct Request {
    
    /// Query portion of the request.
    ///
    /// Default value is empty query `SearchQuery.all("")`.
    /// Either a valid  non-empty`query` or a non-empty valid `idlist` must be provided.
    public let searchQuery: SearchQuery
    
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
        query: SearchQuery = .all(""),
        idList: [String] = [],
        itemsPerPage: Int = 50,
        sortBy: SortBy = .lastUpdatedDate,
        sortOrder: SortOrder = .descending
    ) {
        self.searchQuery = query
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

public extension Request {
    
    /// Returns a new request for next page.
    ///
    /// Returned request is not valid if  its `startIndex` is equal to `numberOfPages` of corresponding response.
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
    
    /// Request for specific article with given id.
    ///
    /// - Parameter id: arXiv id of desired article.
    /// - Parameter version: Desired version of the article. Default value 0 or any negative value returns request for the most recent version.
    static func article(id: String, version: Int = 0) -> Request  {
        let versionSuffix = version > 0 ? "v\(version)" : ""
        return Request(idList: ["\(versionlessId(from: id))\(versionSuffix)"])
    }
    
    static func versionOfId(_ id: String) -> String? {
        
        guard let rangeOfVersion = rangeOfVersion(in: id) else {
            return nil
        }
        
        return String(id[rangeOfVersion])
    }
    
    static func versionlessId(from id: String) -> String {
        guard let rangeOfVersion = rangeOfVersion(in: id) else {
            return id
        }
        return id.replacingCharacters(in: rangeOfVersion, with: "")
    }
    
    private static func rangeOfVersion(in articleID: String) -> Range<String.Index>? {
        articleID.range(of: #"[v,V][1-9]+$"#, options: .regularExpression)
    }
}

public extension Request {
    
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
