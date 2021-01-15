
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public extension ArxivRequest {
    
    /**
     Uses provided session to create and return a task described by the request.
     
     - Parameter session: An `URLSession` object used for creating and running the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed `ArxivResponse`, or an `ArxivKitError`, if one occurs.
               
     If multiple tasks are programatically run in a raw,
     a 3 seconds delay between the tasks is recomended by [arxiv API manual](https://arxiv.org/help/api/user-manual).
     */
    @discardableResult
    func fetchTask(using session: URLSession, completion: @escaping ArxivFetchTaskCompetionHandler) -> URLSessionDataTask {
        return session.fethTask(with: self, completion: completion)
    }
    
    /**
     Uses provided session to create and and run a task described by the request. Method returns the task after it starts running.
     
     - Parameter session: An `URLSession` object used for creating and running the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed `ArxivResponse`, or an `ArxivKitError`, if one occurs.
               
     If multiple tasks are programatically run in a raw,
     a 3 seconds delay between the tasks is recomended by [arxiv API manual](https://arxiv.org/help/api/user-manual).
     */
    @discardableResult
    func fetch(using session: URLSession, completion: @escaping ArxivFetchTaskCompetionHandler) -> URLSessionDataTask {
        let task = session.fethTask(with: self, completion: completion)
        task.resume()
        return task
    }
}

