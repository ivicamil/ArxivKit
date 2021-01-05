
import Foundation

public struct Response {
    
    init() {
        
    }
    
    public internal(set) var id = ""
    
    public internal(set) var title = ""
    
    public internal(set) var link = URL(string: "https://arxiv.org/")!
    
    public internal(set) var updated = Date(timeIntervalSince1970: 0)
    
    public internal(set) var totalResults = 0
    
    public internal(set) var startIndex = 0
    
    public internal(set) var itemsPerPage = 0
    
    public internal(set) var entries: [Entry] = []
}

public struct Entry: Hashable, Identifiable {
    
    public struct Author: Hashable {
        
        init(){
            
        }
        
        public internal(set) var name = ""
        
        public internal(set) var affiliation = ""
    }
    
    init() {
        
    }
    
    public internal(set) var id = ""
    
    public internal(set) var title = ""
    
    public internal(set) var  published =  Date(timeIntervalSince1970: 0)
    
    public internal(set) var  updated =  Date(timeIntervalSince1970: 0)
    
    public internal(set) var  summary = ""
    
    public internal(set) var authors: [Author] = []
    
    public internal(set) var categories = [Subjects.main]
    
    public internal(set) var primaryCategory = Subjects.main
    
    public internal(set) var abstractURL = URL(string: "https://arxiv.org/")!
    
    public internal(set) var pdfURL = URL(string: "https://arxiv.org/")!
    
    public internal(set) var doiURL: URL? = nil
    
    public internal(set) var comment = ""
    
    public internal(set) var  journalReference = ""
    
    public internal(set) var  doi = ""
}
