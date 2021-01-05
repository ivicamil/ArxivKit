import Foundation

extension Subjects {
    
    static var dictionary: [String: [String: Any]] {
        let dictURL = Bundle.module.url(forResource: "ArxivSubjectsDictionary", withExtension: "plist")!
        return NSDictionary(contentsOf: dictURL) as? [String: [String: Any]] ?? [:]
    }
    
    private static var allSubjects: [Subject] {
        return dictionary.keys.map { Subject($0) }
    }
    
    static func print() {
        for subject in main.children {
            Swift.print("\(subject.name)")
            for child in subject.children {
                if !child.children.isEmpty {
                    Swift.print("\t\(child.name)")
                    for s in child.children {
                        Swift.print("\t\t\(s.symbol) - \(s.name)")
                    }
                } else {
                    Swift.print("\t\(child.symbol) - \(child.name)")
                }
            }
        }
    }
    
    static func generateSwiftConstants() -> String {
        var code = ""
        
        code.append("\npublic extension Subjects {\n")
        code.append("\n\tenum OtherPhysicsSubjects {}\n")
        for subject in allSubjects {
            if subject.symbol.hasSuffix("*") {
                code.append("\n\tenum \(typeNameForSubject(subject)) {}\n")
            }
        }
        code.append("}\n")
        
        code.append("\npublic extension Subjects.OtherPhysicsSubjects {\n")
        for subject in Subject("physics-field").children {
            if !subject.symbol.hasSuffix("*")  {
                code.append(constantForSubject(subject))
            }
        }
        code.append("}\n")
        
        for subject in allSubjects.filter({ $0.symbol.hasSuffix("*") }) {
            code.append("\npublic extension Subjects.\(typeNameForSubject(subject)) {\n")
            code.append("\n\tstatic let all = Subject(\"\(subject.symbol)\")\n")
            for child in subject.children {
                code.append(constantForSubject(child))
            }
            code.append("}\n")
        }
        
        return code
    }
    
    private static func constantForSubject(_ subject: Subject) -> String {
        return "\n\tstatic let \(constantNameForSubject(subject)) = Subject(\"\(subject.symbol)\")\n"
    }
    
    private static func typeNameForSubject(_ subject: Subject) -> String {
        return String(subject.name.capitalized.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) })
    }
    
    private static func constantNameForSubject(_ subject: Subject) -> String {
        let filteredName = String(subject.name.capitalized.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) })
        return filteredName.replacingCharacters(in: ...filteredName.startIndex, with: filteredName[filteredName.startIndex].lowercased())
    }
}


