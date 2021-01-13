
import Foundation

/**
 
 # From [SE-0289](https://github.com/apple/swift-evolution/blob/master/proposals/0289-function-builders.md#function-building-methods)
 
 This is a quick reference for the function-builder methods currently proposed. The typing here is subtle, as it often is in macro-like features. In the following descriptions, Expression stands for any type that is acceptable for an expression-statement to have (that is, a raw partial result), Component stands for any type that is acceptable for a partial or combined result to have, and Return stands for any type that is acceptable to be ultimately returned by the transformed function.

 - buildBlock(_ components: Component...) -> Component is used to build combined results for statement blocks. It is required to be a static method in every function builder.

 - buildOptional(_ component: Component?) -> Component is used to handle a partial result that may or may not be available in a given execution. When a function builder provides buildOptional(_:), the transformed function can include if statements without an else.

 - buildEither(first: Component) -> Component and buildEither(second: Component) -> Component are used to build partial results when a selection statement produces a different result from different paths. When a function builder provides these functions, the transformed function can include if statements with an else statement as well as switch statements.

 - buildArray(_ components: [Component]) -> Component is used to build a partial result given the partial results collected from all of the iterations of a loop. When a function builder provides buildArray(_:), the transformed function can include for..in statements.

 - buildExpression(_ expression: Expression) -> Component is used to lift the results of expression-statements into the Component internal currency type. It is optional, but when provided it allows a - function builder to distinguish Expression types from Component types or to provide contextual type information for statement-expressions.

 - buildFinalResult(_ component: Component) -> Return is used to finalize the result produced by the outermost buildBlock call for top-level function bodies. It is optional, and allows a function builder to distinguish Component types from Return types, e.g. if it wants builders to internally traffic in some type that it doesn't really want to expose to clients.

 - buildLimitedAvailability(_ component: Component) -> Component is used to transform the partial result produced by buildBlock in a limited-availability context (such as if #available) into one suitable for any context. It is optional, and is only needed by function builders that might carry type information from inside an if #available outside it.
 
 */


@_functionBuilder
public struct SignleExpressionBuilder {
    
    public static func buildBlock(_ queryExp: ArxivQueryExpression) -> ArxivQueryExpression {
        return AnyQueryExpression(query: queryExp.query)
    }
}

@_functionBuilder
public struct AnyOfBuilder {
    
    public static func buildBlock(
        _ firstExp: ArxivQueryExpression,
        _ otherExps: ArxivQueryExpression...
    ) -> ArxivQueryExpression {
        guard let secondExp = otherExps.first else {
            return firstExp
        }
        let query = otherExps.dropFirst().reduce(firstExp.query.or(secondExp.query)) { $0.or($1.query) }
        return AnyQueryExpression(query: query)
    }
}

@_functionBuilder
public struct AllOfBuilder {
    
    public static func buildBlock(
        _ firstExp: ArxivQueryExpression,
        _ otherExps: ArxivQueryExpression...
    ) -> ArxivQueryExpression {
        guard let secondExp = otherExps.first else {
            return firstExp
        }
        let query = otherExps.dropFirst().reduce(firstExp.query.and(secondExp.query)) { $0.and($1.query) }
        return AnyQueryExpression(query: query)
    }
}


public extension ArxivQueryExpression {
    
    func excluding(@SignleExpressionBuilder _ content: () -> ArxivQueryExpression) -> ArxivQueryExpression {
        return AnyQueryExpression(query: query.excluding(content().query))
    }
}

public struct AnyOf: ArxivQueryExpression {
    
    public let query: ArxivQuery
    
    public init(@AnyOfBuilder _ content: () -> ArxivQueryExpression) {
        self.query = content().query
    }
}

public struct AllOf: ArxivQueryExpression {
    
    public let query: ArxivQuery
    
    public init(@AllOfBuilder _ content: () -> ArxivQueryExpression) {
        self.query = content().query
    }
}


