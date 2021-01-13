

struct FeedConstant {
    
    let value: String
    
    static let id = FeedConstant(value: "id")
    
    static let title = FeedConstant(value: "title")
    
    static let link = FeedConstant(value: "link")
    
    static let href = FeedConstant(value: "href")
    
    static let updated = FeedConstant(value: "updated")
    
    static let totalResults = FeedConstant(value: "opensearch:totalResults")
    
    static let startIndex = FeedConstant(value: "opensearch:startIndex")
    
    static let itemsPerPage = FeedConstant(value: "opensearch:itemsPerPage")
    
    static let feed = FeedConstant(value: "feed")
    
    static let entry = FeedConstant(value: "entry")
    
    enum Entry {
        
        static let id = FeedConstant(value: "id")
        
        static let title = FeedConstant(value: "title")
        
        static let published = FeedConstant(value: "published")
        
        static let updated = FeedConstant(value: "updated")
        
        static let summary = FeedConstant(value: "summary")
        
        static let author = FeedConstant(value: "author")
        
        static let category = FeedConstant(value: "category")
        
        static let primaryCategory = FeedConstant(value: "arxiv:primary_category")

        static let categoryTerm = FeedConstant(value: "term")
        
        static let link = FeedConstant(value: "link")
        
        static let comment = FeedConstant(value: "arxiv:comment")
        
        static let journalReference = FeedConstant(value: "arxiv:journal_ref")
        
        static let doi = FeedConstant(value: "arxiv:doi")
        
        static let errorTitle = FeedConstant(value: "Error")
        
        enum Author {
            
            static let name = FeedConstant(value: "name")
            
            static let affiliation = FeedConstant(value: "arxiv:affiliation")
        }
        
        enum Link {
            
            static let rel = FeedConstant(value: "rel")
            
            static let alternate = FeedConstant(value: "alternate")
            
            static let related = FeedConstant(value: "related")
            
            static let title = FeedConstant(value: "title")
            
            static let pdf = FeedConstant(value: "pdf")
            
            static let doi = FeedConstant(value: "doi")
        }
    }
}
