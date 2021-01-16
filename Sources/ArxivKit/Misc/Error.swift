
/**
 A URL error that can be passed to arXiv fetch task completion handler.
 */
public enum ArxivURLError: Error {
    
    /// `URLSessionDataTask` error.
    /// The associated value is an [URLError]( https://developer.apple.com/documentation/foundation/urlerror).
    case urlError(Error)
    
    /// Returned when a `URLSessionDataTask` completion handler
    /// returns no error and returns a succesful HTTP response, but no data.
    ///
    /// This should never happen, but it is included to guard against crashes in corner cases,
    case unexpectedURLError
}

/// A server error that can be passed to arXiv fetch task completion handler.
public enum ArxivServerError: Error {
    
    /// Passed if `URLSessionDataTask` HTTP response code is not in the range [200...299].
    /// The associated value is HTTP status code of the reponse.
    case httpResponseError(statusCode: Int)
    
    /// Passed when a `URLSessionDataTask` completion handler
    /// returns no error and no HTTP response.
    ///
    /// This should never happen, but it is included to guard against crashes in corner cases,
    /// as `URLSession` documentation doesn't state when and if `URLResponse` can be `nil`
    /// when no `URLError` occurs.
    case unexpectedHTTPError
}

/// An error  returned by arXiv API call.
public struct ArxivAPIError: Error {
    
    /// A human-readable description of the error.
    let description: String
}

/**
 An `ArxivParser` error.
 */
public enum ArxivParserError: Error {
    
    /// Thrown when XML parser reports a parsing error.
    /// The associated value is an [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser) error.
    case parseError(Error)
    
    /// Thrown when XML parser reports a validation error.
    /// The associated value is an [XMLParser](https://developer.apple.com/documentation/foundation/xmlparser) error.
    case validationError(Error)
    
    /// Another parsing error.
    case unexpectedParseError
}
