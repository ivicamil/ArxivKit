
/**
 Defines errors that can be returned from `ArxivKit` APIs.
 */
public enum ArxivKitError: Error {
    
    /// Returned if `ArxivReqeust` URL cannot be constructed.
    ///
    /// - Note: This error should never occur, but it is included as `Error` rather than precondition for future comptaibility.
    case invalidRequest
    
    /// Returned when`ArxivFetchTask` is explicitly canceled.
    case taskCanceled
    
    /// Returned when`ArxivParser` is explicitly aborted.
    case parsingCanceled
    
    /// Any neworking-related error that caused failure of a fetch task.
    /// Provided argument is from [NSURLErrorDomain](https://developer.apple.com/documentation/foundation/nsurlerrordomain).
    case urlDomainError(Error)
    
    /// A description of an error returned by arXiv API call.
    case apiError(String)
    
    /// Returned when XML parser reports a parsing error.
    /// Provided argument has a codes  from [XMLParser.ErrorCode](https://developer.apple.com/documentation/foundation/xmlparser/errorcode)
    case parseError(Error)
    
    /// Returned when XML parser reports a validation error.
    /// Provided argument has a codes  from [XMLParser.ErrorCode](https://developer.apple.com/documentation/foundation/xmlparser/errorcode)
    case validationError(Error)
}
