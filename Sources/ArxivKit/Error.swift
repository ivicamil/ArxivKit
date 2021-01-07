
public enum ArxivKitError: Error {
    case invalidRequest
    case taskCanceled
    case urlDomainError(Error)
    case apiError(String)
    case parseError(String)
    case validationError(String)
}
