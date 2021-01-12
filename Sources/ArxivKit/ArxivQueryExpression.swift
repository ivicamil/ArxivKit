
import Foundation

public protocol ArxivQueryExpression {
    
    var query: ArxivQuery { get }
}

public extension ArxivQueryExpression {
    
    /**
     Creates a request for retrieving the articles matching the query and belonging to the optional ID list.
     
     - Parameter scope: Search scope for matching the query. Default value is `.anyArticle`
     
     If `specificArticles(idList:)` scope is provided, only the articles with specified IDs will be matched againt the query.
     
     To retrieve a specific version of an article, end the corresponding ID with `vN` suffix where `N` is the desired version number. If an identifier without the suffix is provided,
     the most recent version will be retrieved. `ArxivEntry` type has properties for getting the version and versioned IDs of the corresponing article.
     
     For detailed explanation of arXiv identifiers see [arXiv help](https://arxiv.org/help/arxiv_identifier).
     */
    func makeRequest(scope: ArxivRequest.SearchScope = .anyArticle) -> ArxivRequest {
        return ArxivRequest(scope: scope, query)
    }
}

struct AnyQueryExpression: ArxivQueryExpression {
    
    let query: ArxivQuery
}

public struct Term: ArxivQueryExpression {
    
    public let query: ArxivQuery
    
    public init(_ string: String, in field: ArxivQuery.Field) {
        query = .term(string, in: field)
    }
}

public struct Submitted: ArxivQueryExpression {
    
    public let query: ArxivQuery
    
    public init(in interval: DateInterval) {
        query = .submitted(in: interval)
    }
    
    public init(in period: PastPeriodFromNow) {
        query = .submitted(in: period)
    }
}

public struct LastUpdated: ArxivQueryExpression {
    
    public let query: ArxivQuery
    
    public init(in interval: DateInterval) {
        query = .lastUpdated(in: interval)
    }
    
    public init(in period: PastPeriodFromNow) {
        query = .lastUpdated(in: period)
    }
}


