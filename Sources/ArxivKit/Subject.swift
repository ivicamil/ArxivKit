
import Foundation

/// Representation of a single searchable arXiv subject.
/// Use `Subject` values with `ArxiveKit.Query.subject` to search for articles belonging to the subject.
///
/// All available subject constants are defined under `Subjects` namespace.
public struct Subject: Hashable, Identifiable {
    
    private let nameKey = "name"
    
    private let childSubjectsKey = "child subjects"
    
    /// Unique arXive subject symbol.
    public let symbol: String
    
    init(_ symbol: String) {
        self.symbol = symbol
    }
    
    /// Returns an arXiv `Subject` or `nil` if provided string is not a valid subject symbol.
    public init?(arxivSubject symbol: String) {
        if Subjects.dictionary[symbol] != nil && !Subjects.nonArXiveSubjects.contains(symbol) {
            self.init(symbol)
        }
        return nil
    }
    
    /// Human-readable arXive subject name.
    public var name: String {
        return Subjects.dictionary[symbol]?[nameKey] as? String ?? ""
    }
    
    /// Child subjects or empty array if the given subject does not have any chidlren.
    public var children: [Subject] {
        let childSubjects = (Subjects.dictionary[symbol]?[childSubjectsKey] as? [String])?.compactMap { Subject($0) } ?? []
        return childSubjects
    }
    
    public var id: Subject {
        return self
    }
}

/// Recursive tree structure used for grouping of arXive subjects.
public indirect enum SubjectTree: Hashable {
    
    /// Leaf node, a single arXive suject.
    case subject(Subject)
    
    /// Arbitrary grouping of arXive subjects.
    case grouping(name: String, children: [SubjectTree])
}

public extension SubjectTree {
    
    /// Group name. If the node is single subject, group name is the subject name.
    var name: String {
        switch self {
        case let .subject(s):
            return s.name
        case let .grouping(name: n, children: _):
            return n
        }
    }
    
    /// Child nodes of the given node.
    var children: [SubjectTree] {
        switch self {
        case let .subject(s):
            return s.children.map { .subject($0) }
        case let .grouping(name: _, children: c):
            return c
        }
    }
    
    /// Node's subject if the node is `SubjectTree` or `nil` otherwise.
    var subject: Subject? {
        switch self {
        case let .subject(s):
            return s
        case .grouping(name: _, children: _):
            return nil
        }
    }
}
