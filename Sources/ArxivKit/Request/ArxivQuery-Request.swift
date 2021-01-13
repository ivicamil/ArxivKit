

public extension ArxivQuery {
    
    /**
     Returns a request created with `ArxivRequest(self)` specifying sorting criterion for returned articles.
     
     - Parameter sortCriterion: A sorting criterion.
     */
    func sorted(by sortingCriterion: ArxivRequest.SortingCriterion) -> ArxivRequest {
        return ArxivRequest(self).sorted(by: sortingCriterion)
    }
    
    /**
     Returns a request created with `ArxivRequest(self)` specifying sorting order for returned articles.
     
     - Parameter sortingOrder: A sorting order.
     */
    func sortingOrder(_ sortingOrder: ArxivRequest.SortingOrder) -> ArxivRequest {
        return ArxivRequest(self).sortingOrder(sortingOrder)
    }
    
    /**
     Returns a request created with `ArxivRequest(self)` specifying zero-based index of the first article in the response..
     
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
     ArxivQuery.term("electron", in: .any)
         .makeRequest()
         .startIndex(6000)
         .itemsPerPage(8000)
    ```
     Large result sets put considerable load on the server and also take a long time to render.
     We recommend to refine queries which return more than 1,000 results, or at least request smaller slices.
     For bulk metadata harvesting or set information, etc., the OAI-PMH interface is more suitable.
     A request with `itemsPerPage` > 30,000 will result in an HTTP 400 error code with appropriate explanation.
     A request for 30000 results will typically take a little over 2 minutes to return a response of over 15MB.
     Requests for fewer results are much faster and correspondingly smaller.
     */
    func startIndex(_ i: Int) -> ArxivRequest {
        return ArxivRequest(self).startIndex(i)
    }
    
    /**
     Returns a request created with `ArxivRequest(self)` specifying maximum number of articles to be returned from a single API call.
     
     - Parameter n: Maximum number of articles per response.
     
     From [arxiv API manual](https://arxiv.org/help/api/user-manual):
     
     In cases where the API needs to be called multiple times in a row, we encourage you to play nice and incorporate a 3 second delay in your code.

     Because of speed limitations in our implementation of the API,
     the maximum number of results returned from a single call (`itemsPerPage`) is limited to 30000 in slices of at most 2000 at a time,
     using the `itemsPerPage` and `startIndex` parameters.
     
     For example to retrieve matches 6001-8000:
     
     ```
     ArxivQuery.term("electron", in: .any)
         .makeRequest()
         .startIndex(6000)
         .itemsPerPage(8000)
    ```
     Large result sets put considerable load on the server and also take a long time to render.
     We recommend to refine queries which return more than 1,000 results, or at least request smaller slices.
     For bulk metadata harvesting or set information, etc., the OAI-PMH interface is more suitable.
     A request with `itemsPerPage > 30000` will result in an `HTTP 400` error code with appropriate explanation.
     A request for `30000` results will typically take a little over 2 minutes to return a response of over 15MB.
     Requests for fewer results are much faster and correspondingly smaller.
     */
    func itemsPerPage(_ n: Int) -> ArxivRequest {
        return ArxivRequest(self).itemsPerPage(n)
    }
}
