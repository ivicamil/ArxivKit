
import Foundation

private let nameKey = "name"

private let childSubjectsKey = "child subjects"

/**
 Representation of a single searchable arXiv subject.
 
 Use `Subject` values with `ArxivQuery.subject` to retrieve articles belonging to the subject.
 
 All available subject constants are defined under `ArxivSubjects` namespace.
 */
public struct ArxivSubject: Hashable, Codable, CustomStringConvertible {
    
    /// Returns arXive category symbol of the subject.
    public let symbol: String
    
    init(_ symbol: String) {
        self.symbol = symbol
    }
    
    /**
     Constructs `ArxivSubject` for provideed symbol, or `nil` if provided string is not a valid arXiv category symbol.
     
     - Parameter symbol: A valid arXivCategory symbol.
     */
    public init?(symbol: String) {
        if ArxivSubject.dictionary[symbol] != nil && !ArxivSubject.nonArXiveSubjects.contains(symbol) {
            self.init(symbol)
        }
        return nil
    }
    
    /// Returns human-readable arXiv subject name.
    public var name: String {
        return ArxivSubject.dictionary[symbol]?[nameKey] as? String ?? ""
    }
    
    /// Returns an array of child subjects or empty array if the given subject does not have any chidlren.
    public var children: [ArxivSubject] {
        let childSubjects = (ArxivSubject.dictionary[symbol]?[childSubjectsKey] as? [String])?.compactMap { ArxivSubject($0) } ?? []
        return childSubjects
    }
    
    public var description: String {
        return symbol
    }
}

/**
 Recursive tree structure used for grouping arXiv subjects.
 
 Use for making arbitrary groups of arXiv subjects. For example, [arXiv.org](https://arxiv.org) organises
 multiple subjects under umbrella term Physics. To represent such groups together with regular subjects, this library uses `SubjectTree`.
 `SubjectTree.allSubjects` returns a `SubjectTree` that can be used to recursively enumerate all available subjects and their groupings as organised on [arXiv.org](https://arxiv.org).
 
 Other arbitrary groupings can be constructed, depending on particular needs.
 */
public indirect enum SubjectTree: Hashable {
    
    /// Leaf node, a single arXive suject.
    case subject(ArxivSubject)
    
    /// Arbitrary grouping of arXive subjects.
    case grouping(name: String, children: [SubjectTree])
}

public extension SubjectTree {
    
    /// Returns group name. If the node is single subject, group name is the subject's name.
    var name: String {
        switch self {
        case let .subject(s):
            return s.name
        case let .grouping(name: n, children: _):
            return n
        }
    }
    
    /// Retunrs child nodes of the given node.
    var children: [SubjectTree] {
        switch self {
        case let .subject(s):
            return s.children.map { .subject($0) }
        case let .grouping(name: _, children: c):
            return c
        }
    }
    
    /// Returns node's subject if the node is `.subject(_)` or `nil` otherwise.
    var subject: ArxivSubject? {
        switch self {
        case let .subject(s):
            return s
        case .grouping(name: _, children: _):
            return nil
        }
    }
}

public extension SubjectTree {
    
    /// Returns a tree that can be used to recursively enumerate all available subjects
    /// and their groupings as organised on [arXiv.org](https://arxiv.org).
   static var allSubjects = SubjectTree.grouping(
        name: "\(ArxivSubject("main").name)",
        children: [physicsGroup] + nonPhysicsRootSubjects.map { .subject($0) }
    )
}

extension ArxivSubject {
    
    static var nonArXiveSubjects = ["main", "physics-field"]
    
    static var main = ArxivSubject("main")
    
    static var allPhysics = ArxivSubject("physics-field")
}

extension SubjectTree {
    
    static var physicsGroup = SubjectTree.grouping(
        name: "Physics Subjects",
        children: ArxivSubject("physics-field").children.map { .subject($0) }
    )
    
    static var nonPhysicsRootSubjects: [ArxivSubject] {
        return ArxivSubject.main.children.filter { $0.symbol != ArxivSubject.allPhysics.symbol }
    }
}
