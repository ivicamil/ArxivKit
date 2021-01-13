
import Foundation

/**
 Non-empty list of queries.
 */
public struct QueryList {
    
    /// Returns the first element of the list.
    public let first: ArxivQuery
    
    /// Returns the entire list.
    public let all: [ArxivQuery]
    
    /// Returns the tail of the list.
    public var tail: [ArxivQuery] {
        return Array(all.dropFirst())
    }
    
    init(_ first: ArxivQuery, _ tail: ArxivQuery...) {
        self.first = first
        self.all = [first] + tail
    }
    
    init(_ first: ArxivQuery, _ tail: [ArxivQuery]) {
        self.first = first
        self.all = [first] + tail
    }
}

/// A custom parameter attribute that constructs query list from closures.
@_functionBuilder
public struct QueryBuilder {
    
    public static func buildBlock(
        _ first: ArxivQuery,
        _ tail: ArxivQuery...
    ) -> QueryList {
        return QueryList(first, tail)
    }
}
