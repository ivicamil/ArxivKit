
/**
 `ArxivKit` error.
 */
public enum ArxivKitError: Error {
    
    /// Returned if `ArxivReqeust` URL can not be constructed.
    ///
    /// This error should never occur, but it is included as `Error` rather than precondition for future comptaibility.
    case invalidRequest
    
    /// Returned when`ArxivFetchTask` is explicitely canceled.
    case taskCanceled
    
    /// Returned when`ArxivParser` is explicitely aborted.
    case parsingCanceled
    
    /// Any URL related error. Provided argument is from [NSURLErrorDomain](https://developer.apple.com/documentation/foundation/nsurlerrordomain).
    case urlDomainError(Error)
    
    /// A description of an error returned by arXiv API call.
    case apiError(String)
    
    /// Returned when XML parser reports a parsing error.
    /// Provided argument has a code listed in [XMLParser.ErrorCode](https://developer.apple.com/documentation/foundation/xmlparser/errorcode)
    ///
    ///
    case parseError(Error)
    
    /// Returned when XML parser reports a validation error.
    /// Provided argument has a code listed in [XMLParser.ErrorCode](https://developer.apple.com/documentation/foundation/xmlparser/errorcode)
    ///
    /// This error should never occur, but it is included as `Error` rather than precondition for future comptaibility.
    case validationError(Error)
}
