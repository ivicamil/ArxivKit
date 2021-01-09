import Foundation

public struct ArxivQuery {
    
    private var tree: ArxivQueryTree
    
    private init(_ tree: ArxivQueryTree) {
        self.tree = tree
    }
}

public extension ArxivQuery {
    
    struct Field {
        
        fileprivate enum Value {
            case title
            case abstract
            case authors
            case comment
            case journalReference
            case reportNumber
            case any
        }
        
        fileprivate let value: Value
        
        private init(_ field: Value) {
            self.value = field
        }
        
        public static var title = Field(.title)
        
        public static var abstract = Field(.abstract)
        
        public static var author = Field(.authors)
        
        public static var comment = Field(.comment)
        
        public static var journalReference = Field(.journalReference)
        
        public static var reportNumber = Field(.reportNumber)
        
        public static var any = Field(.any)
    }
}

public extension ArxivQuery {
    
    internal static var empty: ArxivQuery {
        return ArxivQuery(.empty)
    }
    
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
    
    static func subject(_ s: ArxivSubject) -> ArxivQuery {
        return ArxivQuery(.subject(s))
    }
    
    static func submitted(_ interval: DateInterval) -> ArxivQuery {
        return ArxivQuery(.submitted(interval))
    }
    
    static func lastUpdated(_ interval: DateInterval) -> ArxivQuery {
        return ArxivQuery(.lastUpdated(interval))
    }
}

public extension ArxivQuery {
    
    /// Constructs `ArxiveKit.Query.and`.
    private func and(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return ArxivQuery(.both(tree, anotherQuery.tree))
    }
    
    /// Constructs `ArxiveKit.Query.or`.
    private func or(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return ArxivQuery(.either(tree, anotherQuery.tree))
    }
    
    /// Constructs `ArxiveKit.Query.andNot`.
    func excluding(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return ArxivQuery(.firstAndNotSecond(tree, anotherQuery.tree))
    }
    
    static func allOf(_ first: ArxivQuery, _ second: ArxivQuery,_ otherQueries: ArxivQuery...) -> ArxivQuery {
        return otherQueries.reduce(first.and(second)) { $0.and($1) }
    }
    
    static func anyOf(_ first: ArxivQuery, _ second: ArxivQuery,_ otherQueries: ArxivQuery...) -> ArxivQuery {
        return otherQueries.reduce(first.or(second)) { $0.or($1) }
    }
}

public extension ArxivQuery {
    
    var string: String {
        return tree.string
    }
    
    var isEmpty: Bool {
        return tree.isEmpty
    }
}
