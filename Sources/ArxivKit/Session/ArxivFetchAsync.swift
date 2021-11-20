
import Foundation

public extension ArxivRequest {
    
    /**
    Uses provided session to download and parse articles specified by the  request and delivers the result asynchronously.
     
     - Parameter session: An `URLSession` object used for fetching.
     - Parameter delegate: A delegate that receives life cycle and authentication challenge callbacks as the transfer progresses.
     
     - Throws: An error which is either `ArxivURLError`, `ArxivServerError`, `ArxivParserError` or `ArxivAPIError`.
     */
    @available(macOS 12.0.0, iOS 15.0.0, *)
    func fetch(using session: URLSession, delegate: URLSessionTaskDelegate? = nil) async throws -> ArxivResponse {
        return try await session.arxivResponse(for: self, delegate: delegate)
    }
}

