
import Foundation

/**
 A type providing specification of aXiv API request.
 */
public protocol ArxivRequest {
    
    /**
     Returns full specification of the request.
     
     Conformig type decide and document configuration of the returned specification.
     */
    var requestSpecification: ArxivRequestSpecification { get }
}

public extension ArxivRequest {
    
    var url: URL {
        return requestSpecification.url
    }
    
    /**
     Returns a new request changing the sorting criterion in `requestSpecification`.
     
     - Parameter sortCriterion: A sorting criterion.
     */
    func sorted(by sortingCriterion: ArxivRequestSpecification.SortingCriterion) -> ArxivRequest {
        var request = requestSpecification
        request.sortingCriterion = sortingCriterion
        return request
    }
    
    /**
     Returns a new request changing the sorting order in `requestSpecification`.
     
     - Parameter sortingOrder: A sorting order.
     */
    func sortingOrder(_ sortingOrder: ArxivRequestSpecification.SortingOrder) -> ArxivRequest {
        var request = requestSpecification
        request.sortingOrder = sortingOrder
        return request
    }
    
    /**
     Returns a new request changing the start index in `requestSpecification`.
     
     - Parameter i: Start index of the request.
     
     Use to imlement paging. For example, if `itemsPerPage == 20`, the first page corresponds to `startIndex == 0`,
     the second page to `startIndex == 40`, the third page to `startIndex == 60` etc.
     
     `ArxivReponse` values can be used for getting various page indicies for given response.
     
     From [arxiv API manual](https://arxiv.org/help/api/user-manual):
     
     In cases where the API needs to be called multiple times in a row, we encourage you to play nice and incorporate a 3 second delay in your code.

     Because of speed limitations in our implementation of the API,
     the maximum number of results returned from a single call (`itemsPerPage`) is limited to 30000 in slices of at most 2000 at a time,
     using the `itemsPerPage` and `startIndex` query parameters.
     
     For example to retrieve matches 6001-8000:
     
     ```
     term("electron", in: .any)
         .startIndex(6000)
         .itemsPerPage(8000)
    ```
     Large result sets put considerable load on the server and also take a long time to render.
     We recommend to refine queries which return more than 1,000 results, or at least request smaller slices.
     For bulk metadata harvesting or set information, etc., the OAI-PMH interface is more suitable.
     A request with `itemsPerPage` > 30,000 will result in an HTTP 400 error code with appropriate explanation.
     A request for 30000 results will typically take a little over 2 minutes to return a response of over 15MB.
     Requests for fewer results are much faster and correspondingly smaller.
     
     - Precondition: `i >= 0`
     */
    func startIndex(_ i: Int) -> ArxivRequest {
        precondition(i >= 0, "Start index must be greater than or equal to zero.")
        var request = requestSpecification
        request.startIndex = i
        return request
    }
    
    /**
     Returns a new request changing the number of items per single response page in `requestSpecification`.
     
     - Parameter n: Maximum number of articles per response.
     
     From [arxiv API manual](https://arxiv.org/help/api/user-manual):
     
     In cases where the API needs to be called multiple times in a row, we encourage you to play nice and incorporate a 3 second delay in your code.

     Because of speed limitations in our implementation of the API,
     the maximum number of results returned from a single call (`itemsPerPage`) is limited to 30000 in slices of at most 2000 at a time,
     using the `itemsPerPage` and `startIndex` parameters.
     
     For example to retrieve matches 6001-8000:
     
     ```
     term("electron", in: .any)
         .startIndex(6000)
         .itemsPerPage(8000)
    ```
     Large result sets put considerable load on the server and also take a long time to render.
     We recommend to refine queries which return more than 1,000 results, or at least request smaller slices.
     For bulk metadata harvesting or set information, etc., the OAI-PMH interface is more suitable.
     A request with `itemsPerPage > 30000` will result in an `HTTP 400` error code with appropriate explanation.
     A request for `30000` results will typically take a little over 2 minutes to return a response of over 15MB.
     Requests for fewer results are much faster and correspondingly smaller.
     
     - Precondition: `n > 0`
     */
    func itemsPerPage(_ n: Int) -> ArxivRequest {
        precondition(n > 0, "itemsPerPage value must be greater than zero.")
        var request = requestSpecification
        request.itemsPerPage = n
        return request
    }
}

extension ArxivQuery: ArxivRequest {
    
    /// Returns `ArxivRequestSpecification(query: self)`.
    public var requestSpecification: ArxivRequestSpecification {
        return ArxivRequestSpecification(query: self)
    }
}

extension ArxivRequestSpecification: ArxivRequest {
    
    /// Returns `self`.
    public var requestSpecification: ArxivRequestSpecification {
        return self
    }
}


