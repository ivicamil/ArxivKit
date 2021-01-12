
import Foundation

/**
 A single parsed `entry` element from arXiv API reponse.
*/
public struct ArxivEntry: Hashable, Codable {
    
    /// A single parsed `author` element from arXiv API reponse.
    public struct Author: Hashable, Codable {
        
        /// Returns author's name.
        public internal(set) var name: String
        
        /// Returns author's affiliation.
        public internal(set) var affiliation: String
        
        init(){
            name = ""
            affiliation = ""
        }
    }
    
    /**
     Returns arXiv identifier of the article.
     
     For detailed explanation of arXiv identifiers see [arXiv.org help](https://arxiv.org/help/arxiv_identifier).
     */
    public internal(set) var id: String
    
    /// Returnes article's title.
    public internal(set) var title: String
    
    /// Returnes the date in which the first version of the article was submitted and processed.
    public internal(set) var  submissionDate: Date
    
    /// Returned the date on which the current version of the article  was submitted and processed.
    public internal(set) var  lastUpdateDate: Date
    
    /// Returnes article's abstract.
    public internal(set) var  summary: String
    
    /// Returnes an array of article's authors.
    public internal(set) var authors: [Author]
    
    /**
     Returns an array of all arXiv, ACM, or MSC category symbols describing article's classification.
     
     For detailed explanation of article categorisation see [arXiv.org help](https://arxiv.org/help/prep).
     
     If an element from the returned list is arXiv category symbol,
     it can be used as the argument for `ArxivSubject.init?(symbol:)`.
     Constructed value can then be used for retrieving articles belonging to the subject.
     */
    public internal(set) var categories: [String]
    
    /**
     Returns a symbol of article's primary category.
     
     For detailed explanation of article categorisation see [arXiv.org help](https://arxiv.org/help/prep).
     
     If the returned value is arXiv category symbol,
     it can be used as the argument for `ArxivSubject.init?(symbol:)`.
     Constructed value can then be used for retrieving articles belonging to the subject.
     */
    public internal(set) var primaryCategory: String
    
    /// Returns URL to article's abstract page.
    public internal(set) var abstractURL: URL
    
    /// Returns URL to article's full text PDF file.
    public internal(set) var pdfURL: URL
    
    /// Returns URL to article's resolved DOI page if available, or `nil` otherwise.
    public internal(set) var doiURL: URL?
    
    /// Returns authors' comment of the article.
    public internal(set) var comment: String
    
    /// Returnes a  journal reference for the article
    public internal(set) var  journalReference: String
    
    /// Returnes a  DOI for the article if one is provided or empty string otherwise.
    public internal(set) var  doi: String
    
    init() {
        id = ""
        title = ""
        submissionDate = Date(timeIntervalSince1970: 0)
        lastUpdateDate = Date(timeIntervalSince1970: 0)
        summary = ""
        authors = []
        categories = []
        primaryCategory = ""
        abstractURL = URL(string: "https://arxiv.org/")!
        pdfURL = URL(string: "https://arxiv.org/")!
        comment = ""
        journalReference = ""
        doi = ""
    }
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

        published: \(submissionDate)
        last updated: \(lastUpdateDate)

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
    
    /// Returns an example of parsed arXiv API response `entry` element.
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
        example.submissionDate = published
        example.lastUpdateDate = updated
        example.id = id
        example.abstractURL = abstractURL
        example.pdfURL = pdfURL
        example.comment = comment
        
        return example
    }
}

public extension ArxivEntry {
    
    /// Returns version number of the article or `nil` if the `id` is without verrsion suffix.
    var version: Int? {
        
        guard let rangeOfVersion = ArxivEntry.rangeOfVersion(in: id) else {
            return nil
        }
        
        return Int(String(id[rangeOfVersion].dropFirst()))
    }
    
    /**
     Returns `id` without version suffix.
     
     Returned value can be used for fetching the latest version of the article.
     */
    var latestVersionID: String {
        return ArxivEntry.versionlessId(from: id)
    }

    /// Returns an array of IDs for all available versions of the article in ascending order.
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
