
import Foundation

/**
 `ArxivResponse` is parsed arXiv API reponse.
*/
public struct ArxivResponse {
    
    init() {
        
    }
    
    /**
     Returns the value of arXiv feed id element.
     
     From [arxiv API manual](https://arxiv.org/help/api/user-manual):
     
     The <id> element serves as a unique id for query defined by reponse's `title`,
     and is useful if you are writing a program such as a feed reader that wants to keep track of all the feeds requested in the past.
     This id can then be used as a key in a database.
     
     The id is guaranteed to be unique for each query.
     */
    public internal(set) var id = ""
    
    /**
     Returns the value of arXiv feed title element.
     
     From [arxiv API manual](https://arxiv.org/help/api/user-manual):
     
     The title contains a canonicalized version of the query used to call the API.
     The canonicalization includes all parameters, using their defaults if they were not included,
     and always puts them in the order search_query,id_list,start,max_results,
     even if they were specified in a different order in the actual query.
    */
    public internal(set) var title = ""
    
    /**
     Returns the value of arXiv feed link element.
     
     From [arxiv API manual](https://arxiv.org/help/api/user-manual):
     
     The <link> element provides a URL that can be used to retrieve this feed again.
     
     Note that the url in the link represents the canonicalized version of the query.
     The <link> provides a GET requestable url, even if the original request was done via POST.
     */
    public internal(set) var link = URL(string: "https://arxiv.org/")!
    
    /**
     Returns the value of arXiv feed updated element.
     
     From [arxiv API manual](https://arxiv.org/help/api/user-manual):
     
     The `updated` element provides the last time the contents of the feed were last updated:
     
     Because the arXiv submission process works on a 24 hour submission cycle,
     new articles are only available to the API on the midnight after the articles were processed.
     The `updated` tag thus reflects the midnight of the day that you are calling the API.
     This is very important - search results do not change until new articles are added.
     Therefore there is no need to call the API more than once in a day for the same query.
     Please cache your results. This primarily applies to production systems,
     and of course you are free to play around with the API while you are developing your program!
     */
    public internal(set) var updated = Date(timeIntervalSince1970: 0)
    
    /// Returns total number of articles matching the query defined by `ArxiveRequest`.
    public internal(set) var totalResults = 0
    
    /// Returns zero-based index of the first article in the list of total results,
    /// set by `startIndex(_)` on `an ArxiveRequest`.
    public internal(set) var startIndex = 0
    
    /// Returns maximum number of article per response,
    /// set by `itemsPerPage(_)` on `an ArxiveRequest`.
    public internal(set) var itemsPerPage = 0
    
    /// Returns an array od articles matching the query defined by `ArxiveRequest`.
    public internal(set) var entries: [ArxivEntry] = []
}

public extension ArxivResponse {
    
    /// Returns total number od pages of the reponse.
    var numberOfPages: Int {
        return (totalResults + itemsPerPage - 1) / itemsPerPage
    }
    
    /// Returns zero-based current page index of the reponse.
    var currentPage: Int {
        return startIndex / itemsPerPage
    }
    
    /// Returns zero-based start index of the previous page, or `nil` if `currentPage ==  0`.
    var previousPageStartIndex: Int? {
        guard currentPage != 0 else {
            return nil
        }
        return startIndex - itemsPerPage
    }
    
    /// Returns zero-based start index of the next page, or `nil` if `currentPage == numberOfPages - 1`.
    var nextPageStartIndex: Int? {
        guard currentPage < numberOfPages - 1 else {
            return nil
        }
        return startIndex + itemsPerPage
    }
    
    /// Returns zero-based start index of the last page.
    var lastPageStartIndex: Int {
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
