
import Foundation

public struct Entry: Hashable, Identifiable {
    
    public struct Author: Hashable {
        
        init(){
            
        }
        
        public internal(set) var name = ""
        
        public internal(set) var affiliation = ""
    }
    
    public init() {
        
    }
    
    public internal(set) var id = ""
    
    public internal(set) var title = ""
    
    public internal(set) var  published =  Date(timeIntervalSince1970: 0)
    
    public internal(set) var  updated =  Date(timeIntervalSince1970: 0)
    
    public internal(set) var  summary = ""
    
    public internal(set) var authors: [Author] = []
    
    public internal(set) var categories: [String] = []
    
    public internal(set) var primaryCategory = ""
    
    public internal(set) var abstractURL = URL(string: "https://arxiv.org/")!
    
    public internal(set) var pdfURL = URL(string: "https://arxiv.org/")!
    
    public internal(set) var doiURL: URL? = nil
    
    public internal(set) var comment = ""
    
    public internal(set) var  journalReference = ""
    
    public internal(set) var  doi = ""
}

extension Entry: CustomStringConvertible {
    
    public var description: String {
        return """
        \(title)

        Authors:
        \(authors.map { "\($0.name), \($0.affiliation)" }.joined(separator: "\n"))

        Abstract:
        \(summary)

        primary subject: \(primaryCategory)
        all subjects: \(categories.joined(separator: ", "))

        published: \(published)
        last updated: \(updated)

        id: \(id)
        doi: \(doi)
        journalRef: \(journalReference)

        abstract url: \(abstractURL.absoluteString)
        pdf url: \(pdfURL.absoluteString)
        doi url: \(doiURL?.absoluteString ?? "")

        Comment:
        \(comment)
        """
    }
}

public extension Entry {
    
    static var example: Entry {

        let title = "Feynman Lectures on the Strong Interactions"

        var feynman = Author()
        feynman.name = "Richard P. Feynman"
        var cline = Author()
        cline.name = "James M. Cline"
        let authors = [feynman, cline]
        
        let summary = """
        These twenty-two lectures, with exercises, comprise the extent of what was meant to be a full-year graduate-level course on the strong interactions and QCD, given at Caltech in 1987-88. The course was cut short by the illness that led to Feynman's death. Several of the lectures were finalized in collaboration with Feynman for an anticipated monograph based on the course. The others, while retaining Feynman's idiosyncrasies, are revised similarly to those he was able to check. His distinctive approach and manner of presentation are manifest throughout. Near the end he suggests a novel, nonperturbative formulation of quantum field theory in $D$ dimensions. Supplementary material is provided in appendices and ancillary files, including verbatim transcriptions of three lectures and the corresponding audiotaped recordings.
        
        """
        
        let primarySubject = "hep-ph"
        let allSubjects = ["hep-ph", "hep-th", "physics.hist-ph"]
        
        let df = DateFormatter()
        df.dateStyle = .full
        let published = df.date(from: "2020-06-15 17:59:55 +0000") ?? Date(timeIntervalSince1970: 0)
        let updated = df.date(from: "2020-06-15 17:59:55 +0000") ?? Date(timeIntervalSince1970: 0)
        
        let id = "2006.08594v1"
        
        let abstractURL = URL(string: "https://arxiv.org/abs/2006.08594v1")!
        let pdfURL = URL(string: "https://arxiv.org/pdf/2006.08594v1")!
        
        let comment = """
        98 pages, 117 figures; Feynman's personal course notes and audio   files for lectures 15, 17, 18 available at   http://www.physics.mcgill.ca/~jcline/Feynman/
        """
        
        var example = Entry()
        example.title = title
        example.authors = authors
        example.summary = summary
        example.primaryCategory = primarySubject
        example.categories = allSubjects
        example.published = published
        example.updated = updated
        example.id = id
        example.abstractURL = abstractURL
        example.pdfURL = pdfURL
        example.comment = comment
        
        return example
    }
}

public extension Entry {
    
    var version: Int? {
        
        guard let rangeOfVersion = Entry.rangeOfVersion(in: id) else {
            return nil
        }
        
        return Int(String(id[rangeOfVersion].dropFirst()))
    }
    
    var latestVersionID: String {
        return Entry.versionlessId(from: id)
    }
    
    internal static func versionlessId(from id: String) -> String {
        guard let rangeOfVersion = rangeOfVersion(in: id) else {
            return id
        }
        return id.replacingCharacters(in: rangeOfVersion, with: "")
    }
    
    private static func rangeOfVersion(in articleID: String) -> Range<String.Index>? {
        articleID.range(of: #"[v,V][1-9]+$"#, options: .regularExpression)
    }
    
    var allVersionsIDs: [String] {
        guard let currentVersion = self.version else {
            return [id]
        }
        
        return (1...currentVersion).map { n in
            "\(latestVersionID)v\(n)"
        }
    }
}
