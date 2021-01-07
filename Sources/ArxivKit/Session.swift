
import Foundation

public final class FetchSession {
    
    let urlSession: URLSession
    
    public init() {
        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration)
    }
    
    public func fethTask(with request: Request) -> FetchTask {
        return FetchTask(request: request, urlSession: urlSession)
    }
    
    deinit {
        // Is this necessary?
        urlSession.invalidateAndCancel()
    }
}
