
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 A task used for fetching and parsing articles specified by `ArxivRequest`.
 
 Instances of the class are created indirectly, by `ArxivSession` object.
 The session retains created tasks and releases them upon completion.
 */
public final class ArxivFetchTask {
    
    /// Returns request specifying articles to be fetched by the task.
    public let request: ArxivRequest
    
    private weak var arxiveSession: ArxivSession?
    
    private weak var urlSession: URLSession?
    
    private weak var dataTask: URLSessionDataTask?
    
    private let parser = ArxivParser()
    
    private let parserQueue = DispatchQueue(label: "io.polifonia.ArxivKit.parserQueue")
    
    private let sessionQueue = DispatchQueue(label: "io.polifonia.ArxivKit.sessionQueue")
    
    let completion: (Result<ArxivResponse, ArxivKitError>) -> ()
    
    private var previousTaskTimestamp: Date?
    
    init(request: ArxivRequest, arxivSession: ArxivSession, completion: @escaping (Result<ArxivResponse, ArxivKitError>) -> ()) {
        self.request = request
        self.urlSession = arxivSession.urlSession
        self.completion = completion
    }
    
    /// Runs the task.
    public func run() {
        
        guard let requestURL = request.url else {
            completion(.failure(.invalidRequest))
            return
        }
        
        func dispatch(_ block: @escaping () -> ()) {
            
            guard let previousTaskDate = previousTaskTimestamp else {
                sessionQueue.async {
                    block()
                }
                return
            }
            
            guard let minimalDelay = arxiveSession?.minimalDelayBetweenTasks else {
                sessionQueue.async {
                    block()
                }
                return
            }
            
            let now = Date()
            let timeSincePreviousTask = now.timeIntervalSince(previousTaskDate)
            
            if timeSincePreviousTask < minimalDelay {
                sessionQueue.asyncAfter(deadline: .now() + (minimalDelay - timeSincePreviousTask)) {
                    block()
                }
            } else {
                sessionQueue.async {
                    block()
                }
            }
        }
        
        dispatch { [weak self] in
            guard let self = self else { return }

            self.dataTask = self.urlSession?.dataTask(with: URLRequest(url: requestURL)) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error as NSError? {
                    if !(error.domain == NSURLErrorDomain  && error.code == NSURLErrorCancelled) {
                        self.completion(.failure(.urlDomainError(error)))
                    }
                } else if let data = data {
                    self.parserQueue.async { [weak self] in
                        guard let self = self else { return }
                        self.parser.parse(responseData: data, completion: self.completion)
                    }
                }
                
                self.sessionQueue.async { [weak self] in
                    self?.dataTask = nil
                }
            }
            
            self.previousTaskTimestamp = Date()
            self.dataTask?.resume()
        }
    }
    
    /**
     Cancels the task.
     
     After the task is canceled, its completion handler
     is called with `.failure(ArxivKitError.taskCanceled)`.
     */
    public func cancel() {
        dataTask?.cancel()
        self.sessionQueue.async { [weak self] in
            self?.dataTask = nil
        }
        parserQueue.async { [weak self] in
            guard let self = self else { return }
            self.parser.abort()
            self.completion(.failure(.taskCanceled))
        }
    }
}

public extension ArxivRequest {
    
    /**
     Returns and runs a task for fetching and parsing articles described by the request, by using provided session.
     
     - Parameter session: An `ArxivSession` object used for creating and running the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed `ArxivResponse`, or an `ArxivKitError`, if one occurs.
     
     - Note: Created task is retained by the session and released upon completion.
     */
    @discardableResult
    func fetch(using session: ArxivSession, completion: @escaping (Result<ArxivResponse, ArxivKitError>) -> ()) -> ArxivFetchTask {
        let task = session.fethTask(with: self, completion: completion)
        task.run()
        return task
    }
}
