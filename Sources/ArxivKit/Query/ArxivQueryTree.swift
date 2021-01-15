
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


indirect enum ArxivQueryTree  {
    case empty
    case title(contains: String)
    case authors(contains: String)
    case abstract(contains: String)
    case comment(contains: String)
    case journalReference(contains: String)
    case subject(ArxivSubject)
    case reportNumber(contains: String)
    case anyField(contains: String)
    case submitted(in: DateInterval)
    case lastUpdated(in: DateInterval)
    case both(ArxivQueryTree, ArxivQueryTree)
    case either(ArxivQueryTree, ArxivQueryTree)
    case firstAndNotSecond(ArxivQueryTree, ArxivQueryTree)
}

extension ArxivQueryTree {
    
    var string: String {
        switch self {
        case .empty:
            return ""
        case let .title(string):
            return "\(titleKey):\(string.removingDiacritics)"
        case let .authors(string):
            return "\(authorKey):\(string.removingDiacritics)"
        case let .abstract(string):
            return "\(abstractKey):\(string.removingDiacritics)"
        case let .comment(string):
            return "\(commentKey):\(string.removingDiacritics)"
        case let .journalReference(string):
            return "\(journalReferenceKey):\(string)"
        case let .subject(subject):
            return "\(categoryKey):\(subject.symbol)"
        case let .reportNumber(string):
            return "\(reportNumberKey):\(string)"
        case let .anyField(string):
            return "\(allKey):\(string.removingDiacritics)"
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
    
    var isEmpty: Bool {
        switch self {
        case .empty:
            return true
        case let .title(string):
            return string.trimmingWhiteSpaces.isEmpty
        case let .authors(string):
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

extension ArxivQueryTree: Codable {
    
    enum CodingKeys: CodingKey {
        case empty
        case title
        case authors
        case abstract
        case comment
        case journalReference
        case anyField
        case subject
        case reportNumber
        case submitted
        case lastUpdated
        case both
        case either
        case firstAndNotSecond
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .empty:
            try container.encode(true, forKey: .empty)
        case let .title(string):
            try container.encode(string, forKey: .title)
        case let .authors(string):
            try container.encode(string, forKey: .authors)
        case let .abstract(string):
            try container.encode(string, forKey: .abstract)
        case let .comment(string):
            try container.encode(string, forKey: .comment)
        case let .journalReference(string):
            try container.encode(string, forKey: .journalReference)
        case let .subject(subject):
            try container.encode(subject, forKey: .subject)
        case let .reportNumber(string):
            try container.encode(string, forKey: .reportNumber)
        case let .anyField(string):
            try container.encode(string, forKey: .anyField)
        case let .submitted(interval):
            try container.encode(interval, forKey: .submitted)
        case let .lastUpdated(interval):
            try container.encode(interval, forKey: .lastUpdated)
        case let .both(q1, q2):
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .both)
            try nestedContainer.encode(q1)
            try nestedContainer.encode(q2)
        case let .either(q1, q2):
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .either)
            try nestedContainer.encode(q1)
            try nestedContainer.encode(q2)
        case let .firstAndNotSecond(q1, q2):
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .firstAndNotSecond)
            try nestedContainer.encode(q1)
            try nestedContainer.encode(q2)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .empty:
            self = .empty
        case .title:
            let string = try container.decode(String.self, forKey: .title)
            self = .title(contains: string)
        case .authors:
            let string = try container.decode(String.self, forKey: .authors)
            self = .authors(contains: string)
        case .abstract:
            let string = try container.decode(String.self, forKey: .abstract)
            self = .abstract(contains: string)
        case .comment:
            let string = try container.decode(String.self, forKey: .comment)
            self = .comment(contains: string)
        case .journalReference:
            let string = try container.decode(String.self, forKey: .journalReference)
            self = .journalReference(contains: string)
        case .anyField:
            let string = try container.decode(String.self, forKey: .anyField)
            self = .anyField(contains: string)
        case .subject:
            let s = try container.decode(ArxivSubject.self, forKey: .subject)
            self = .subject(s)
        case .reportNumber:
            let string = try container.decode(String.self, forKey: .reportNumber)
            self = .title(contains: string)
        case .submitted:
            let i = try container.decode(DateInterval.self, forKey: .submitted)
            self = .submitted(in: i)
        case .lastUpdated:
            let i = try container.decode(DateInterval.self, forKey: .lastUpdated)
            self = .lastUpdated(in: i)
        case .both:
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .both)
            let q1 = try nestedContainer.decode(ArxivQueryTree.self)
            let q2 = try nestedContainer.decode(ArxivQueryTree.self)
            self = .both(q1, q2)
        case .either:
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .either)
            let q1 = try nestedContainer.decode(ArxivQueryTree.self)
            let q2 = try nestedContainer.decode(ArxivQueryTree.self)
            self = .either(q1, q2)
        case .firstAndNotSecond:
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .firstAndNotSecond)
            let q1 = try nestedContainer.decode(ArxivQueryTree.self)
            let q2 = try nestedContainer.decode(ArxivQueryTree.self)
            self = .firstAndNotSecond(q1, q2)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unable to decode `ArxivQueryTree`."
                )
            )
        }
    }
}

private extension String {
    
    var removingDiacritics: String {
        return folding(options: .diacriticInsensitive, locale: .current)
    }
}
