
/**
 Defines errors that can be returned from `ArxivKit` APIs.
 */
public enum ArxivKitError: Error {
    
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
    
    /// Returned when XML parser finishes without error, but returns `nil` `ArxivResponse`.
    case unexpectedParseError
}
