
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
    
    public typealias CompetionHandler = (Result<ArxivResponse, ArxivKitError>) -> ()
    
    /// Returns request specifying articles to be fetched by the task.
    public let request: ArxivRequest
    
    private weak var arxiveSession: ArxivSession?
    
    private weak var urlSession: URLSession?
    
    private weak var dataTask: URLSessionDataTask?
    
    private let parser = ArxivParser()
        
    private let sessionQueue = DispatchQueue(label: "io.polifonia.ArxivKit.sessionQueue")
    
    let completion: (Result<ArxivResponse, ArxivKitError>) -> ()
        
    init(request: ArxivRequest, arxivSession: ArxivSession, completion: @escaping CompetionHandler) {
        self.request = request
        self.arxiveSession = arxivSession
        self.urlSession = arxivSession.urlSession
        self.completion = completion
    }
    
    /**
     Runs the task.
     
     - Note: If multiple tasks are programatically run in a raw,
     a 3 seconds delay between the tasks is recomended by [arxiv API manual](https://arxiv.org/help/api/user-manual).
     */
    public func run() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard let requestURL = self.request.url else {
                self.completion(.failure(.invalidRequest))
                return
            }
            
            guard self.dataTask == nil else {
                return
            }
            
            self.dataTask = self.urlSession?.dataTask(with: URLRequest(url: requestURL)) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error as NSError? {
                    if !(error.domain == NSURLErrorDomain  && error.code == NSURLErrorCancelled) {
                        self.completion(.failure(.urlDomainError(error)))
                    }
                } else if let data = data {
                    self.parser.parse(responseData: data, completion: self.completion)
                }
                
                self.dataTask = nil
            }
            
            self.dataTask?.resume()
        }
    }
    
    /**
     Cancels the task.
     
     After the task is canceled, its completion handler
     is called with `.failure(ArxivKitError.taskCanceled)`.
     */
    public func cancel() {
        self.sessionQueue.async { [weak self] in
            self?.dataTask?.cancel()
            self?.dataTask = nil
            self?.completion(.failure(.taskCanceled))
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
     
     If multiple tasks are programatically run in a raw,
     a 3 seconds delay between the tasks is recomended by [arxiv API manual](https://arxiv.org/help/api/user-manual).
     */
    @discardableResult
    func fetch(using session: ArxivSession, completion: @escaping ArxivFetchTask.CompetionHandler) -> ArxivFetchTask {
        let task = session.fethTask(with: self, completion: completion)
        task.run()
        return task
    }
}

