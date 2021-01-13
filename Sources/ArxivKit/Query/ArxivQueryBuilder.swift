
import Foundation

public struct QueryList {
    
    public let first: ArxivQuery
    
    public let all: [ArxivQuery]
    
    public var tail: [ArxivQuery] {
        return Array(all.dropFirst())
    }
    
    public init(_ first: ArxivQuery, _ tail: ArxivQuery...) {
        self.first = first
        self.all = [first] + tail
    }
    
   public init(_ first: ArxivQuery, _ tail: [ArxivQuery]) {
        self.first = first
        self.all = [first] + tail
    }
}

@_functionBuilder
public struct QueryBuilder {
    
    public static func buildBlock(
        _ first: ArxivQuery,
        _ tail: ArxivQuery...
    ) -> QueryList {
        return QueryList(first, tail)
    }
}
