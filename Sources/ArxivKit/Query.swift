
import Foundation

// versions

private let titleKey = "ti"
private let authorKey = "au"
private let abstractKey = "abs"
private let commentKey = "co"
private let journalReferenceKey = "jr"
private let categoryKey = "cat"
private let reportNumberKey = "rn"
private let allKey = "all"
private let submittedDateKey = "submittedDate"
private let lastUpdatedDateKey = "lastUpdatedDate"

// Date Options
private let fromKey = "from"
private let toKey = "to"
private let dateQueryFormat = "yyyyMMddHHmm"

// Logical Operators
private let andKey = "AND"
private let andNotKey = "ANDNOT"
private let orKey = "OR"


/// Query portion of `ArxiveKit.Request`.
public indirect enum Query {
    
    /// Searches for articles containing given term in the title.
    case title(String)
    
    /// Searches for articles containing given term in authors' names.
    case author(String)
    
    /// Searches for articles containing given term in the abstract.
    case abstract(String)
    
    /// Searches for articles containing given term in the abstract.
    case comment(String)
    
    /// Searches for articles containing given term in the journal reference.
    case journalReference(String)
    
    /// Searches for articles belonging to given subject.
    case subject(Subject)
    
    /// Searches for articles containing given term in the report number.
    case reportNumber(String)
    
    /// Searches for articles containing given term in of the fields.
    case all(String)
    
    /// Searches for articles submited between the two dates.
    case submittedDate(from :Date, to: Date)
    
    /// Searches for articles updated between the two dates.
    case lastUpdatedDate(from :Date, to: Date)
    
    /// Searches for articles satisfying both of the queries.
    case and(Query, Query)
    
    /// Searches for articles satisfying any of the queries.
    case or(Query, Query)
    
    /// Searches for articles satisfying the first, but not the second query.
    case andNot(Query, Query)
}

public extension Query {
    
    /// Constructs `ArxiveKit.Query.and`.
    func and(_ anotherQuery: Query) -> Query {
        return .and(self, anotherQuery)
    }
    
    /// Constructs `ArxiveKit.Query.or`.
    func or(_ anotherQuery: Query) -> Query {
        return .or(self, anotherQuery)
    }
    
    /// Constructs `ArxiveKit.Query.andNot`.
    func andNot(_ anotherQuery: Query) -> Query {
        return .andNot(self, anotherQuery)
    }
}

extension Query {
    
    var string: String {
        switch self {
        case let .title(string):
            return "\(titleKey):\"\(string.removingNonEnglishCharacters)\""
        case let .author(string):
            return "\(authorKey):\"\(string.removingNonEnglishCharacters)\""
        case let .abstract(string):
            return "\(abstractKey):\"\(string.removingNonEnglishCharacters)\""
        case let .comment(string):
            return "\(commentKey):\"\(string.removingNonEnglishCharacters)\""
        case let .journalReference(string):
            return "\(journalReferenceKey):\(string)"
        case let .subject(subject):
            return "\(categoryKey):\(subject.symbol)"
        case let .reportNumber(string):
            return "\(reportNumberKey):\(string)"
        case let .all(string):
            return "\(allKey):\"\(string.removingNonEnglishCharacters)\""
        case let .submittedDate(from, to):
            let dateFormater = DateFormatter()
            dateFormater.locale = .current
            dateFormater.dateFormat = dateQueryFormat
            return "\(submittedDateKey):[\(dateFormater.string(from: from))+TO+\(dateFormater.string(from: to))]"
        case let .lastUpdatedDate(from, to):
            let dateFormater = DateFormatter()
            dateFormater.locale = .current
            dateFormater.dateFormat = dateQueryFormat
            return "\(lastUpdatedDateKey):[\(dateFormater.string(from: from))+TO+\(dateFormater.string(from: to))]"
        case let .and(q1, q2):
            return "(\(q1.string)+\(andKey)+\(q2.string))"
        case let .or(q1, q2):
            return "(\(q1.string)+\(orKey)+\(q2.string))"
        case let .andNot(q1, q2):
            return "(\(q1.string)+\(andNotKey)+\(q2.string))"
        }
    }
}

private extension String {
    
    var removingNonEnglishCharacters: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
        return mutableString as String
    }
}
