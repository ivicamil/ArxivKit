import Foundation

/**
 Specifies search criteria for arXiv request.
 
 `ArxivQuery` represents either a search term in specified article field,
 a date intervarl in which desired articles were published or updated or an arXive subject.
 
 Queries can be combined to construct arbitrarily complex queries by using `all` and `any` combinators.
 It is also possible to exclude articles matching a query by using `excluding` combinator.
 */
public struct ArxivQuery: Codable {
    
    private var tree: ArxivQueryTree
    
    fileprivate init(_ tree: ArxivQueryTree) {
        self.tree = tree
    }
    
    /**
     Used to restrict term search to specific article field.
     
     To search given term in any field, use `ArxivQuery.Field.any`.
     */
    public struct Field: Codable {
        
        let rawValue: Value
        
        private init(_ field: Value) {
            self.rawValue = field
        }
        
        /// Restricts search to title.
        public static var title = Field(.title)
        
        /// Restricts search to  abstract (summary).
        public static var abstract = Field(.abstract)
        
        /// Restricts search to  authors' names.
        public static var authors = Field(.authors)
        
        /// Restricts search to  comment.
        public static var comment = Field(.comment)
        
        /// Restricts search to  journal reference.
        public static var journalReference = Field(.journalReference)
        
        /// Restricts search to  report number.
        public static var reportNumber = Field(.reportNumber)
        
        /// Used for searching inside any of the above fields.
        public static var any = Field(.any)
    }
}

public extension ArxivQuery {
    
    /// Returns a string representation of the query.
    var string: String {
        return tree.string
    }
}

extension ArxivQuery {
    
    static func term(_ term: String, in field: Field = .any) -> ArxivQuery {
        
        let termString = term.trimmingWhiteSpaces
        
        guard !termString.isEmpty else {
            return .empty
        }
        
        let tree: ArxivQueryTree
        
        switch field.rawValue  {
        case .title:
            tree = .title(contains: termString)
        case .abstract:
            tree = .abstract(contains: termString)
        case .authors:
            tree = .authors(contains: termString)
        case .comment:
            tree = .comment(contains: termString)
        case .journalReference:
            tree = .journalReference(contains: termString)
        case .reportNumber:
            tree = .reportNumber(contains: termString)
        case .any:
            tree = .anyField(contains: "electron")
        }
        
        return ArxivQuery(tree)
    }
    
    static func subject(_ subject: ArxivSubject) -> ArxivQuery {
        return ArxivQuery(.subject(subject))
    }
    
    static func submitted(in interval: DateInterval) -> ArxivQuery {
        return ArxivQuery(.submitted(in: interval))
    }
    
    static func lastUpdated(in interval: DateInterval) -> ArxivQuery {
        return ArxivQuery(.lastUpdated(in: interval))
    }
    
    static func submitted(in period: PastPeriodFromNow) -> ArxivQuery {
        return ArxivQuery(.submitted(in: period.dateInterval))
    }
    
    static func lastUpdated(in period: PastPeriodFromNow) -> ArxivQuery {
        return ArxivQuery(.lastUpdated(in: period.dateInterval))
    }
    
    static var empty: ArxivQuery {
        return ArxivQuery(.empty)
    }
}

extension ArxivQuery {
    
    func and(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return ArxivQuery(.both(tree, anotherQuery.tree))
    }
    
   func or(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return ArxivQuery(.either(tree, anotherQuery.tree))
    }
    
    func andNot(_ anotherQuery: ArxivQuery) -> ArxivQuery {
         return ArxivQuery(.firstAndNotSecond(tree, anotherQuery.tree))
     }
}

extension ArxivQuery {
    
    var isEmpty: Bool {
        return tree.isEmpty
    }
}

extension ArxivQuery.Field {
    
    enum Value: String, Codable {
        case title
        case abstract
        case authors
        case comment
        case journalReference
        case reportNumber
        case any
    }
}

// MARK: - Global Functions Used For Query Expressions

/// Returns an empty query.
public var empty: ArxivQuery {
    return .empty
}

/**
 Returns a query for retrieving the articles containing provided term in the specified field.
 
    - Parameter term: A string to search for.
    - Parameter field: An article field to be searched for provided term.
 
 Default value of `field` parameter isis `.any`.
 
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
public func term(_ term: String, in field: ArxivQuery.Field = .any) -> ArxivQuery {
    return .term(term, in: field)
}

/**
 Returns a query for retrieving  the articles categorised under provided arXiv subject.
 
 - Parameter subject: An arXive subject. Possible values are defined under `ArxivSubjects` namespace.
*/
public func subject(_ subject: ArxivSubject) -> ArxivQuery {
    return .subject(subject)
}


/**
 Returns a query for retrieving the articles whose first version was published in provided interval.
 
 - Parameter interval: Desired date interval.
*/
public func submitted(in interval: DateInterval) -> ArxivQuery {
    return .submitted(in: interval)
}

/**
 Returns a query for retrieving the articles whose most recent version was published in provided interval.
 
 - Parameter interval: Desired date interval.
*/
public func lastUpdated(in interval: DateInterval) -> ArxivQuery {
    return .lastUpdated(in: interval)
}

/**
 Returns a query for retrieving the articles whose most recent version was published in provided interval.
 
 - Parameter interval: Desired date interval.
*/
public func submitted(in period: PastPeriodFromNow) -> ArxivQuery {
    return .submitted(in: period)
}

/**
 Returns a query for retrieving the articles whose most recent version was published in provided time period.
 
 - Parameter period: Desired time period.
*/
public func lastUpdated(in period: PastPeriodFromNow) -> ArxivQuery {
    return .lastUpdated(in: period)
}

/**
 Returns a new query for retrieving the articles matching **ALL** of the provided subqueries.

 - Parameter queries: A query builder that creates list of subqueries of `all`.
 */
public func all(@ArxivQueryBuilder _ queries: () -> [ArxivQuery]) -> ArxivQuery {
    
    let queryList = queries().filter { !$0.isEmpty }
    
    guard let firstQuery = queryList.first else {
        return .empty
    }
    
    let otherQueries = queryList.dropFirst()
    
    guard let secondQuery = otherQueries.first else {
        return firstQuery
    }
    
    return otherQueries.dropFirst().reduce(firstQuery.and(secondQuery)) { $0.and($1) }
}

/**
 Returns a query for retrieving the articles matching **ANY** of the provided subqueries.

 - Parameter queries: A query builder that creates list of subqueries oaf `any`.
 */
public func any(@ArxivQueryBuilder _ queries: () -> [ArxivQuery]) -> ArxivQuery {
    
    let queryList = queries().filter { !$0.isEmpty }
    
    guard let firstQuery = queryList.first else {
        return .empty
    }
    
    let otherQueries = queryList.dropFirst()
    
    guard let secondQuery = otherQueries.first else {
        return firstQuery
    }
    
    return otherQueries.dropFirst().reduce(firstQuery.or(secondQuery)) { $0.or($1) }
}

public extension ArxivQuery {
    
    /**
     Returns a new query for retrieving the articles matching the query **AND NOT** the provided subqueries.
    
     - Parameter queries: A query builder that creates list of subqueries to exclude.
          
     Semantics of the returned query is to exclude the articles matching all of the provided subqueries.
     In other words, `.excluding { q1; q2; q3 }` is equivalent to `.excluding { all { q1; q2; q3 } }`.
     Use `.excluding { any { q1; q2; q3; } }` to exclude the articles mathing any of the subqueries.
     */
    func excluding(@ArxivQueryBuilder _ queries: () -> [ArxivQuery]) -> ArxivQuery {
        
        let queryList = queries().filter { !$0.isEmpty }
        
        guard let firstQuery = queryList.first else {
            return self
        }
        
        let otherQueries = queryList.dropFirst()
        
        guard let secondQuery = otherQueries.first else {
            return ArxivQuery(.firstAndNotSecond(tree, firstQuery.tree))
        }
        
        let excludedQuery = otherQueries.dropFirst().reduce(firstQuery.and(secondQuery)) { $0.and($1) }
        return ArxivQuery(.firstAndNotSecond(tree, excludedQuery.tree))
    }
}

extension ArxivQuery: CustomStringConvertible {
    
    public var description: String {
        switch tree {
        case .empty:
            return "empty"
        case let .title(string):
            return "term(\(string), in: .title)"
        case let .authors(string):
            return "term(\(string), in: .author)"
        case let .abstract(string):
            return "term(\(string), in: .abstract)"
        case let .comment(string):
            return "term(\(string), in: .comment)"
        case let .journalReference(string):
            return "term(\(string), in: .journalReference)"
        case let .subject(subject):
            return ".subject(\(subject))"
        case let .reportNumber(string):
            return "term(\(string), in: .reportNumber)"
        case let .anyField(string):
            return "term(\(string), in: .any)"
        case let .submitted(interval):
            let dateFormater = DateFormatter()
            dateFormater.locale = .current
            dateFormater.dateStyle = .short
            let start = dateFormater.string(from: interval.start)
            let end = dateFormater.string(from: interval.end)
            return "submissionDate(in: \(start) - \(end)"
        case let .lastUpdated(interval):
            let dateFormater = DateFormatter()
            dateFormater.locale = .current
            dateFormater.dateStyle = .short
            let start = dateFormater.string(from: interval.start)
            let end = dateFormater.string(from: interval.end)
            return "lastUpdateDate(in: \(start) - \(end)"
        case let .both(q1, q2):
            return "(\(ArxivQuery(q1)) AND \(ArxivQuery(q2)))"
        case let .either(q1, q2):
            return "(\(ArxivQuery(q1)) OR \(ArxivQuery(q2)))"
        case let .firstAndNotSecond(q1, q2):
            return "(\(ArxivQuery(q1)) ANDNOT \(ArxivQuery(q2)))"
        }
    }
}
