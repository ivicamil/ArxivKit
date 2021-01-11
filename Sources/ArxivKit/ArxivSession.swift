
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
    
    /**
     Minimal number of seconds to wait before starting the next queued task.
     
     Default value of this property is `0`, which is suitable for cases where tasks are manualy triggered by users (e.g. in apps).
     If multiple tasks are programatically run in a raw,
     a 3 seconds delay between the tasks is recomended by [arxiv API manual](https://arxiv.org/help/api/user-manual).
     */
    public let minimalDelayBetweenTasks: TimeInterval
    
    let urlSession: URLSession
        
    private var taskID: Int = 0
    
    private var tasks: [Int: ArxivFetchTask] = [:]
    
    /**
     Creates a session with specified minimal delay between the tasks.
     
     - Parameter minimalDelayBetweenTasks: Minimal number of seconds to wait before running the next queued task.
     
     Default value of the delay is 0 seconds. Provided negative values are ignorred. If multiple tasks are programatically run in a raw,
     a 3 seconds delay between the tasks is recomended by [arxiv API manual](https://arxiv.org/help/api/user-manual).
     
     - Note: Constructed session objects must be retained.
     */
    public init(minimalDelayBetweenTasks: TimeInterval = 0) {
        let configuration = URLSessionConfiguration.default
        self.minimalDelayBetweenTasks = minimalDelayBetweenTasks < 0 ? 0 : minimalDelayBetweenTasks
        urlSession = URLSession(configuration: configuration)
    }
    
    /**
     Returns a task for fetching and parsing articles specified by provided request.
     
     - Parameter request: An `ArxivRequest` value that specifies the articles to be fetched by the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed `ArxivResponse`, or an `ArxivKitError`, if one occurs.
     
     - Note: Created task is retained by the session and released upon completion.
     */
    public func fethTask(with request: ArxivRequest, completion: @escaping (Result<ArxivResponse, ArxivKitError>) -> ()) -> ArxivFetchTask {
        taskID += 1
        let taskKey = taskID
        
        let newTask = ArxivFetchTask(request: request, arxivSession: self) { [weak self] in
            completion($0)
            self?.tasks[taskKey] = nil
        }
        
        tasks[taskKey] = newTask
        return newTask
    }
}

