
import Foundation

public final class ArxivSession {
    
    let urlSession: URLSession
        
    private var taskID: Int = 0
    
    private var tasks: [Int: ArxivFetchTask] = [:]
    
    public init() {
        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration)
    }
    
    public func fethTask(with request: ArxivRequest, completion: @escaping (Result<ArxivResponse, ArxivKitError>) -> ()) -> ArxivFetchTask {
        taskID += taskID
        let taskKey = taskID
        
        let newTask = ArxivFetchTask(request: request, urlSession: urlSession) { [weak self] in
            completion($0)
            self?.tasks[taskKey] = nil
        }
        
        tasks[taskKey] = newTask
        return newTask
    }
}

