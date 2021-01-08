
import Foundation

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


/// Query portion of `ArxivRequest`.

public indirect enum ArxivQuery  {
    
    /// Searches for articles containing given term in the title.
    case empty
    
    /// Searches for articles containing given term in the title.
    case title(contains: String)
    
    /// Searches for articles containing given term in authors' names.
    case author(contains: String)
    
    /// Searches for articles containing given term in the abstract.
    case abstract(contains: String)
    
    /// Searches for articles containing given term in the abstract.
    case comment(contains: String)
    
    /// Searches for articles containing given term in the journal reference.
    case journalReference(contains: String)
    
    /// Searches for articles belonging to given subject.
    case subject(contains: ArxivSubject)
    
    /// Searches for articles containing given term in the report number.
    case reportNumber(contains: String)
    
    /// Searches for articles containing given term in of the fields.
    case anyField(contains: String)
    
    /// Searches for articles submited between the two dates.
    case submitted(DateInterval)
    
    /// Searches for articles updated between the two dates.
    case lastUpdated(DateInterval)
    
    /// Searches for articles satisfying both of the queries.
    case both(ArxivQuery, ArxivQuery)
    
    /// Searches for articles satisfying any of the queries.
    case either(ArxivQuery, ArxivQuery)
    
    /// Searches for articles satisfying the first, but not the second query.
    case firstAndNotSecond(ArxivQuery, ArxivQuery)
}

public extension ArxivQuery {
    
    /// Constructs `ArxiveKit.Query.and`.
    func and(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return .both(self, anotherQuery)
    }
    
    /// Constructs `ArxiveKit.Query.or`.
    func or(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return .either(self, anotherQuery)
    }
    
    /// Constructs `ArxiveKit.Query.andNot`.
    func andNot(_ anotherQuery: ArxivQuery) -> ArxivQuery {
        return .firstAndNotSecond(self, anotherQuery)
    }
    
    func test(_ int: Int) -> ArxivQuery {
        return self
    }
    
    static func allOf(_ first: ArxivQuery, _ second: ArxivQuery,_ otherQueries: ArxivQuery...) -> ArxivQuery {
        return otherQueries.reduce(first.and(second)) { $0.and($1) }
    }
    
    static func anyOf(_ first: ArxivQuery, _ second: ArxivQuery,_ otherQueries: ArxivQuery...) -> ArxivQuery {
        return otherQueries.reduce(first.or(second)) { $0.or($1) }
    }
}

public extension ArxivQuery {

    /// String representation of the query.
    var string: String {
        switch self {
        case .empty:
            return ""
        case let .title(string):
            return "\(titleKey):\"\(string.removingNonallowedCharacters)\""
        case let .author(string):
            return "\(authorKey):\"\(string.removingNonallowedCharacters)\""
        case let .abstract(string):
            return "\(abstractKey):\"\(string.removingNonallowedCharacters)\""
        case let .comment(string):
            return "\(commentKey):\"\(string.removingNonallowedCharacters)\""
        case let .journalReference(string):
            return "\(journalReferenceKey):\(string)"
        case let .subject(subject):
            return "\(categoryKey):\(subject.symbol)"
        case let .reportNumber(string):
            return "\(reportNumberKey):\(string)"
        case let .anyField(string):
            return "\(allKey):\"\(string.removingNonallowedCharacters)\""
        case let .submitted(interval):
            let dateFormater = DateFormatter()
            dateFormater.locale = .current
            dateFormater.dateFormat = dateQueryFormat
            return "\(submittedDateKey):[\(dateFormater.string(from: interval.start))+TO+\(dateFormater.string(from: interval.end))]"
        case let .lastUpdated(interval):
            let dateFormater = DateFormatter()
            dateFormater.locale = .current
            dateFormater.dateFormat = dateQueryFormat
            return "\(lastUpdatedDateKey):[\(dateFormater.string(from: interval.start))+TO+\(dateFormater.string(from: interval.end))]"
        case let .both(q1, q2):
            return "(\(q1.string)+\(andKey)+\(q2.string))"
        case let .either(q1, q2):
            return "(\(q1.string)+\(orKey)+\(q2.string))"
        case let .firstAndNotSecond(q1, q2):
            return "(\(q1.string)+\(andNotKey)+\(q2.string))"
        }
    }
    
    /// True if all of the query's arguments are empty strings, false otherwise.
    var isEmpty: Bool {
        switch self {
        case .empty:
            return true
        case let .title(string):
            return string.trimmingWhiteSpaces.isEmpty
        case let .author(string):
            return string.trimmingWhiteSpaces.isEmpty
        case let .abstract(string):
            return string.trimmingWhiteSpaces.isEmpty
        case let .comment(string):
            return string.trimmingWhiteSpaces.isEmpty
        case let .journalReference(string):
            return string.trimmingWhiteSpaces.isEmpty
        case .subject(_):
             return false
        case let .reportNumber(string):
            return string.trimmingWhiteSpaces.isEmpty
        case let .anyField(string):
            return string.trimmingWhiteSpaces.isEmpty
        case .submitted(_):
            return false
        case .lastUpdated(_):
            return false
        case let .both(q1, q2):
            return q1.isEmpty && q2.isEmpty
        case let .either(q1, q2):
            return q1.isEmpty && q2.isEmpty
        case let .firstAndNotSecond(q1, q2):
            return q1.isEmpty && q2.isEmpty
        }
    }
}

private extension String {
    
    var removingNonallowedCharacters: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
        return mutableString.replacingOccurrences(of: "\"", with: "") as String
    }
}
