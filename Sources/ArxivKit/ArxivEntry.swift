
import Foundation

/**
 `ArxivEntry` is a single parsed `entry` element from arXiv API reponse.
*/
public struct ArxivEntry: Hashable, Identifiable {
    
    /// Encapsulates information about a single autor.
    public struct Author: Hashable {
        
        init(){
            
        }
        
        /// Returns author's name.
        public internal(set) var name = ""
        
        /// Returns author's affiliation.
        public internal(set) var affiliation = ""
    }
    
    init() {
        
    }
    
    /**
     Returns arXiv identifier of the article.
     
     For detailed explanation of arXiv identifiers refer to [this link](https://arxiv.org/help/arxiv_identifier).
     */
    public internal(set) var id = ""
    
    /// Returnes article's title.
    public internal(set) var title = ""
    
    // Returnes the date in which the first version of this article was submitted and processed.
    public internal(set) var  published =  Date(timeIntervalSince1970: 0)
    
    /// Returned date on which the version of article described by this ebtry was submitted and processed.
    public internal(set) var  updated =  Date(timeIntervalSince1970: 0)
    
    /// Returnes article's abstract.
    public internal(set) var  summary = ""
    
    /// Returnes an array of article's authors.
    public internal(set) var authors: [Author] = []
    
    /**
     Returns an array of all arXiv, ACM, or MSC category symbols describing article's classification.
     
     For detailed explanation of article categorisation reffer to [this link](https://arxiv.org/help/prep).
     
     If an element from the returned list is arXiv category symbol,
     it can be used as the argument for `ArxivSubject.init?(symbol:)`.
     Constructed value can then be used for retrieving articles belonging to the subject.
     */
    public internal(set) var categories: [String] = []
    
    /**
     Returns a symbol of articles primary category.
     
     For detailed explanation of article categorisation reffer to [this link](https://arxiv.org/help/prep).
     
     If the returned value is arXiv category symbol,
     it can be used as the argument for `ArxivSubject.init?(symbol:)`.
     Constructed value can then be used for retrieving articles belonging to the subject.
     */
    public internal(set) var primaryCategory = ""
    
    /// Returns URL to article's abstract page.
    public internal(set) var abstractURL = URL(string: "https://arxiv.org/")!
    
    /// Returns URL to article's full text PDF file.
    public internal(set) var pdfURL = URL(string: "https://arxiv.org/")!
    
    /// Returns URL to article's resolved DOI page if available, or `nil` otherwise.
    public internal(set) var doiURL: URL? = nil
    
    /// Returns authors' comment of the article.
    public internal(set) var comment = ""
    
    /// Returnes a  journal reference for the article. If the reference is not prvoded, empty string is returned.
    public internal(set) var  journalReference = ""
    
    /// Returnes a  DOI for the article. If the DOI is not prvoded, empty string is returned.
    public internal(set) var  doi = ""
}

extension ArxivEntry: CustomStringConvertible {
    
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

public extension ArxivEntry {
    
    /// Returns an example of parsed arXiv entry.
    static var example: ArxivEntry {

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
        
        var example = ArxivEntry()
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

public extension ArxivEntry {
    
    /// Returns version of the article represented by the entry or `nil` if the `id` is without verrsion suffix.
    var version: Int? {
        
        guard let rangeOfVersion = ArxivEntry.rangeOfVersion(in: id) else {
            return nil
        }
        
        return Int(String(id[rangeOfVersion].dropFirst()))
    }
    
    /// Returns the `id` without version suffix,  which can be used for fetching the latest version of the article.
    var latestVersionID: String {
        return ArxivEntry.versionlessId(from: id)
    }

    /// Returns an array of IDs for all available versions in ascending order.
    var allVersionsIDs: [String] {
        guard let currentVersion = self.version else {
            return [id]
        }
        
        return (1...currentVersion).map { n in
            "\(latestVersionID)v\(n)"
        }
    }
}

extension ArxivEntry {
    
    static func versionlessId(from id: String) -> String {
        guard let rangeOfVersion = rangeOfVersion(in: id) else {
            return id
        }
        return id.replacingCharacters(in: rangeOfVersion, with: "")
    }
    
    private static func rangeOfVersion(in articleID: String) -> Range<String.Index>? {
        articleID.range(of: #"[v,V][1-9]+$"#, options: .regularExpression)
    }
}
