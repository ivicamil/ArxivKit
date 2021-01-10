
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 A task used for fetching and parsing given `ArxivRequest`.
 
 Instances of the class are created indirectly, by `ArxivSession` object,
 which retains created tasks and releases them upon completion.
 */
public final class ArxivFetchTask {
    
    /// Returns request used for creating the task.
    public let request: ArxivRequest
        
    private weak var urlSession: URLSession?
    
    private weak var dataTask: URLSessionDataTask?
    
    private let parser = ArxivParser()
    
    private let parserQueue = DispatchQueue(label: "io.polifonia.ArticlesKit.parserQueue")
    
    let completion: (Result<ArxivResponse, ArxivKitError>) -> ()
    
    init(request: ArxivRequest, urlSession: URLSession, completion: @escaping (Result<ArxivResponse, ArxivKitError>) -> ()) {
        self.request = request
        self.urlSession = urlSession
        self.completion = completion
    }
    
    /// Runs the task.
    public func run() {
        
        guard let requestURL = request.url else {
            completion(.failure(.invalidRequest))
            return
        }
                
        dataTask = urlSession?.dataTask(with: URLRequest(url: requestURL)) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error as NSError? {
                if !(error.domain == NSURLErrorDomain  && error.code == NSURLErrorCancelled) {
                    self.completion(.failure(.urlDomainError(error)))
                }
            } else if let data = data {
                self.parserQueue.async {
                    self.parser.parse(responseData: data, completion: self.completion)
                }
            }
            self.dataTask = nil
        }
        dataTask?.resume()
    }
    
    /**
     Cancels the task.
     
     After the task is canceled, its completion handler
     is called with `.failure(ArxivKitError.taskCanceled)`.
     */
    public func cancel() {
        dataTask?.cancel()
        parserQueue.async { [weak self] in
            guard let self = self else { return }
            self.parser.abort()
            self.completion(.failure(.taskCanceled))
        }
    }
}

public extension ArxivRequest {
    
    /**
     Returns and runs an `ArxiveFetchTask` using provided session.
     
     - Parameter session: An `ArxivSession` object used for creating and running the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed response, or an error if one occurs.
     
     Created task is retained by the session and released upon completion.
     */
    @discardableResult
    func fetch(using session: ArxivSession, completion: @escaping (Result<ArxivResponse, ArxivKitError>) -> ()) -> ArxivFetchTask {
        let task = session.fethTask(with: self, completion: completion)
        task.run()
        return task
    }
}
