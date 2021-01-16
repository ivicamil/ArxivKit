
import Foundation

/// A custom parameter attribute that constructs query list from closures.
@_functionBuilder
public struct ArxivQueryBuilder {
    
    public static func buildExpression(
        _ query: ArxivQuery
    ) -> [ArxivQuery] {
        return [query]
    }
    
    public static func buildExpression<S: Sequence>(
        _ queries: S
    ) -> [ArxivQuery] where S.Element == ArxivQuery {
        return Array(queries)
    }
    
    public static func buildBlock(
        _ queries: [ArxivQuery]...
    ) -> [ArxivQuery] {
        return Array(queries.joined())
    }
    
    public static func buildDo(_ queries: [ArxivQuery]) -> [ArxivQuery] {
        return queries
    }
    
    public static func buildLimitedAvailability(_ queries: [ArxivQuery]) -> [ArxivQuery] {
        return queries
      }
    
   public static func buildArray(_ queries: [[ArxivQuery]]) -> [ArxivQuery] {
        return Array(queries.joined())
   }
    
    public static func buildOptional(_ maybeQuery: [ArxivQuery]?) -> [ArxivQuery] {
        return maybeQuery ?? []
    }
    
    public static func buildEither(first queries: [ArxivQuery]) -> [ArxivQuery] {
        return queries
    }
    
    public static func buildEither(second queries: [ArxivQuery]) -> [ArxivQuery] {
        return queries
    }
}
