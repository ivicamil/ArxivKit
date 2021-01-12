
import Foundation

public protocol ArxivQueryExpression {
    
    var query: ArxivQuery { get }
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
        query = .sumbitted(in: interval)
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
}


