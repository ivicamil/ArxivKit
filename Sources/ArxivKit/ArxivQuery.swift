import Foundation

/**
 Defines search criteria for arXiv request.
 
 `ArxivQuery` represents either a search term in specified article field,
 a query for retrieving articles published or updated in specified date interval or articles categorised under specified subject.
 Queries can be combined to construct arbitrarily complex queries by using `allOf` and `anyOf` combinators.
 It is also possible to exclude articles matching a query by using `excluding` combinator.
 
 Use `makeRequest(scope:)` method or `ArxivRequest(scope:query)` to transform a query into an `ArxivRequest`.
 */
public struct ArxivQuery {
    
    private var tree: ArxivQueryTree
    
    private init(_ tree: ArxivQueryTree) {
        self.tree = tree
    }
}

public extension ArxivQuery {
    
    /**
     `ArxivQuery.Field` is used to restrict term search to specific article field.
     
     To search given term in any field, use `ArxivQuery.Field.any`.
     */
    struct Field {
        
        fileprivate let value: Value
        
        private init(_ field: Value) {
            self.value = field
        }
        
        /// Used to define a query for retrieving the articles containing a term in the title.
        public static var title = Field(.title)
        
        /// Used to define a query for retrieving the articles containing a term in the abstract (summary).
        public static var abstract = Field(.abstract)
        
        /// Used to define a query for retrieving the articles containing a term in the authors' names.
        public static var author = Field(.authors)
        
        /// Used to define a query for retrieving the articles containing a term in the comment.
        public static var comment = Field(.comment)
        
        /// Used to define a query for retrieving the articles containing a term in the journal reference.
        public static var journalReference = Field(.journalReference)
        
        /// Used to define a query for retrieving the articles containing a term in the report number.
        public static var reportNumber = Field(.reportNumber)
        
        /// Used to define a query for retrieving the articles containing a term in any field.
        public static var any = Field(.any)
    }
}

private extension ArxivQuery.Field {
    
    enum Value {
        case title
        case abstract
        case authors
        case comment
        case journalReference
        case reportNumber
        case any
    }
}

public extension ArxivQuery {
    
    internal static var empty: ArxivQuery {
        return ArxivQuery(.empty)
    }
    
    /**
     Returns a query for retrieving the articles containing provided term in the specified field.
     
        - Parameter term: A string to search for.
        - Parameter in: An article field to search for provided term.
     
     From [arxiv API manual](https://arxiv.org/help/api/user-manual):
     
    **Wildcards:**

    - Use ? to replace a single character or * to replace any number of characters.
     Can be used in any field, but not in the first character position. See Journal References tips for exceptions.
     
     **Expressions:**
     
     - TeX expressions can be searched, enclosed in single $ characters.

     **Phrases:**

     - Enclose phrases in double quotes for exact matches in title, abstract, and comments.
     
     **Journal References:**

     - If a journal reference search contains a wildcard, matches will be made using wildcard matching as expected. For example, math* will match math, maths, mathematics.
     - If a journal reference search does not contain a wildcard, only exact phrases entered will be matched. For example, math would match math or math and science but not maths or mathematics.
     - All journal reference searches that do not contain a wildcard are literal searches: a search for Physica A will match all papers with journal references containing Physica A, but a search for Physica A, 245 (1997) 181 will only return the paper with journal reference Physica A, 245 (1997) 181.
     
     */
    static func term(_ term: String, in field: Field) -> ArxivQuery {
        let tree: ArxivQueryTree
        
        switch field.value  {
        case .title:
            tree = .title(contains: term)
        case .abstract:
            tree = .abstract(contains: term)
        case .authors:
            tree = .authors(contains: term)
        case .comment:
            tree = .comment(contains: term)
        case .journalReference:
            tree = .journalReference(contains: term)
        case .reportNumber:
            tree = .reportNumber(contains: term)
        case .any:
            tree = .anyField(contains: term)
        }
        
        return ArxivQuery(tree)
    }
    
    /**
     Returns a query for retrieving  the articles categorised under provided arXiv subject.
     
     - Parameter subject: An arXive subject. Possible values are defined under `ArxivSubjects` namespace.
    */
    static func subject(_ subject: ArxivSubject) -> ArxivQuery {
        return ArxivQuery(.subject(subject))
    }
    
    /**
     Returns a query for retrieving the articles whose first version was published in provided date interval.
     
     - Parameter interval: A date interval.
    */
    static func submitted(in interval: DateInterval) -> ArxivQuery {
        return ArxivQuery(.submitted(interval))
    }
    
    /**
     Returns a query for retrieving the articles whose most recent version was published in provided date interval.
     
     - Parameter interval: A date interval.
    */
    static func lastUpdated(in interval: DateInterval) -> ArxivQuery {
        return ArxivQuery(.lastUpdated(interval))
    }
}

public extension ArxivQuery {
    
    private func and(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return ArxivQuery(.both(tree, anotherQuery.tree))
    }
    
    private func or(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return ArxivQuery(.either(tree, anotherQuery.tree))
    }
    
    /**
     Returns a query for retrieving the articles matching the query **AND NOT** the provided argument query.
    
     - Parameter anotherQuery:A query that retrieved articles do not match.
     */
    func excluding(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return ArxivQuery(.firstAndNotSecond(tree, anotherQuery.tree))
    }
    
    /**
     Returns a query for retrieving the articles matching **ALL** of the provided subqueries.
    
     - Parameter first: The first subquery.
     
     - Parameter second: The second subquery.
     
     - Parameter otherQueries: Any number of subqueries.
     */
    static func allOf(_ first: ArxivQuery, _ second: ArxivQuery,_ otherQueries: ArxivQuery...) -> ArxivQuery {
        return otherQueries.reduce(first.and(second)) { $0.and($1) }
    }
    
    /**
     Returns a query for retrieving the articles matching **ANY** of the provided subqueries.
    
     - Parameter first: The first subquery.
     
     - Parameter second: The second subquery.
     
     - Parameter otherQueries: Any number of subqueries.
     */
    static func anyOf(_ first: ArxivQuery, _ second: ArxivQuery,_ otherQueries: ArxivQuery...) -> ArxivQuery {
        return otherQueries.reduce(first.or(second)) { $0.or($1) }
    }
}

public extension ArxivQuery {
    
    /// Returns a string representation of the query.
    var string: String {
        return tree.string
    }
}

extension ArxivQuery {
    
    var isEmpty: Bool {
        return tree.isEmpty
    }
}
