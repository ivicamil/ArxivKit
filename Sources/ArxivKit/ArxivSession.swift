
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 `ArxivSession`enapsulates network communication and keeps track of individual fetch tasks.
 
 Due to internal implementation details, It is more efficient to reuse a single session instance for all requests inside the app or command line tool.
 Currently, only  `ArxivSession.default` instance is available. Future `ArxivKit` versions may include configurable initialisers.
 Construct and retain a session object by calling its constructor:

 ```swift
 let session = ArxivSession.default
 ```
 */
public final class ArxivSession {
    
    let urlSession: URLSession
        
    private var taskID: Int = 0
    
    private var tasks: [Int: ArxivFetchTask] = [:]
    
    init() {
        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration)
    }
    
    /// Returnes a preconfigured arxive session object.
    public static var `default` = ArxivSession()
    
    /**
     Returns an `ArxiveFetchTask` for provided request.
     
     - Parameter request: An `ArxivRequest` value.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed response, or an error if one occurs.
     
     Created task is retained by the session and released upon completion.
     */
    public func fethTask(with request: ArxivRequest, completion: @escaping (Result<ArxivResponse, ArxivKitError>) -> ()) -> ArxivFetchTask {
        taskID += 1
        let taskKey = taskID
        
        let newTask = ArxivFetchTask(request: request, urlSession: urlSession) { [weak self] in
            completion($0)
            self?.tasks[taskKey] = nil
        }
        
        tasks[taskKey] = newTask
        return newTask
    }
}

