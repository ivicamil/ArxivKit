
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 Enapsulates network communication and keeps track of individual fetch tasks.
 
 It is strongly recomended to reuse a single session instance for multiple related tasks
 or even a single instance for the entire app or command line tool.
 
 - Note: Constructed session objects must be retained at least until all of its tasks are completed.
 */
public final class ArxivSession {
    
    let urlSession: URLSession
        
    private var taskID: Int = 0
    
    private var tasks: [Int: ArxivFetchTask] = [:]
    
    /**
     Creates a session using provided configuration.
     
     If no configuration is provided, `URLSessionConfiguration.default` is used.
     
     - Note: Constructed session objects must be retained.
     */
    public init(urlSessionConfiguration: URLSessionConfiguration = .default) {
        urlSession = URLSession(configuration: urlSessionConfiguration)
    }
    
    
}

public extension ArxivSession {
    
    /**
     Returns a task for fetching and parsing articles specified by provided request.
     
     - Parameter request: An `ArxivRequest` value that specifies the articles to be fetched by the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed `ArxivResponse`, or an `ArxivKitError`, if one occurs.
     
     - Note: Created task is retained by the session and released upon completion.
     */
    func fethTask(with request: ArxivRequest, completion: @escaping ArxivFetchTask.CompetionHandler) -> ArxivFetchTask {
        taskID += 1
        let taskKey = taskID
        
        let newTask = ArxivFetchTask(request: request, arxivSession: self) { [weak self] in
            completion($0)
            self?.tasks[taskKey] = nil
        }
        
        tasks[taskKey] = newTask
        return newTask
    }
    
    func publisher(with request: ArxivRequest) {
        
        if let url = request.requestSpecification.url {
            let publisher =
                urlSession.dataTaskPublisher(for: url)
        }
    }
}
