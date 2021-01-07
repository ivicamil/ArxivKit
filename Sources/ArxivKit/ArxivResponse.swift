
import Foundation

public struct ArxivResponse {
    
    init() {
        
    }
    
    public internal(set) var id = ""
    
    public internal(set) var title = ""
    
    public internal(set) var link = URL(string: "https://arxiv.org/")!
    
    public internal(set) var updated = Date(timeIntervalSince1970: 0)
    
    public internal(set) var totalResults = 0
    
    public internal(set) var startIndex = 0
    
    public internal(set) var itemsPerPage = 0
    
    public internal(set) var entries: [ArxivEntry] = []
}

public extension ArxivResponse {
    
    var numberOfPages: Int {
        return (totalResults + itemsPerPage - 1) / itemsPerPage
    }
    
    var currentPage: Int {
        return startIndex / itemsPerPage
    }
    
    var previousPageIndex: Int? {
        guard currentPage != 0 else {
            return nil
        }
        return startIndex - itemsPerPage
    }
    
    var nextPageIndex: Int? {
        guard currentPage < numberOfPages - 1 else {
            return nil
        }
        return startIndex + itemsPerPage
    }
    
    var lastPageIndex: Int {
        (numberOfPages - 1) * itemsPerPage
    }
}


extension ArxivResponse: CustomStringConvertible {
    
    
    public var description: String {
        return """
        id: \(id)
        title: \(title)
        link: \(link.absoluteString)

        updated: \(updated)

        total results: \(totalResults)
        current page: \(startIndex)
        items per page: \(itemsPerPage)
        number of pages: \(numberOfPages)
        """
    }
}
