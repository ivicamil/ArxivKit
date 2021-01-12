
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
    
    public init(in interval: DateInterval?) {
        query = .sumbitted(in: <#T##DateInterval#>)
    }
}

public struct LastUpdated: ArxivQueryExpression {
    
    public let query: ArxivQuery
    
    public init(in interval: DateInterval) {
        query = .lastUpdated(in: interval)
    }
}

public extension ArxivQueryExpression {
    
    func excluding(_ otherExp: ArxivQueryExpression) -> ArxivQueryExpression {
        return AnyQueryExpression(query: query.excluding(otherExp.query))
    }
}

public struct AnyOf: ArxivQueryExpression {
    
    public let query: ArxivQuery
    
    
    init(
        _ firstExp: ArxivQueryExpression,
        _ secondExp: ArxivQueryExpression,
        _ otherExps: ArxivQueryExpression...
    ) {
        
        query = otherExps.reduce(firstExp.query.or(secondExp.query)) { $0.or($1.query) }
    }
}

public struct AllOf: ArxivQueryExpression {
    
    public let query: ArxivQuery
    
    
    init(
        _ firstExp: ArxivQueryExpression,
        _ secondExp: ArxivQueryExpression,
        _ otherExps: ArxivQueryExpression...
    ) {
        
        query = otherExps.reduce(firstExp.query.and(secondExp.query)) { $0.and($1.query) }
    }
}
