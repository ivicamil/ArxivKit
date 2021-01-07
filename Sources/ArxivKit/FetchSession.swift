
import Foundation

public final class FetchSession {
    
    let urlSession: URLSession
        
    private var taskID: Int = 0
    
    private var tasks: [Int: FetchTask] = [:]
    
    public init() {
        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration)
    }
    
    public func fethTask(with request: Request, completion: @escaping (Result<Response, ArxivKitError>) -> ()) -> FetchTask {
        taskID += taskID
        let taskKey = taskID
        
        let newTask = FetchTask(request: request, urlSession: urlSession) { [weak self] in
            completion($0)
            self?.tasks[taskKey] = nil
        }
        
        tasks[taskKey] = newTask
        return newTask
    }
}

