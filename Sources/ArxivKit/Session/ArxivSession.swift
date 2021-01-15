
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias ArxivFetchTaskCompetionHandler = (Result<ArxivResponse, Error>) -> ()

public typealias ArxivFetchResultKeypath<Root> = ReferenceWritableKeyPath<Root, Result<ArxivResponse, Error>>

public typealias ArxivResponseKeypath<Root> = ReferenceWritableKeyPath<Root, ArxivResponse>

public typealias ArxivErrorKeypath<Root> = ReferenceWritableKeyPath<Root, Error>

public extension URLSession {
    
    /**
     Returns a task for fetching and parsing articles specified by provided request.
     
     - Parameter request: An `ArxivRequest` value that specifies the articles to be fetched by the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed `ArxivResponse`, or an `ArxivKitError`, if one occurs.
     
     - Note: Completion handler is called on session's `delegateQueue`.
     */
    func fetchTask(with request: ArxivRequest, completion: @escaping ArxivFetchTaskCompetionHandler) -> URLSessionDataTask {
        
        return dataTask(with: URLRequest(url: request.url)) { data, response, error in
                        
            if let error = error as NSError? {
                completion(.failure(ArxivKitError.urlDomainError(error)))
            } else if let data = data {
                let parser = ArxivParser()
                let result = Result { try parser.parse(responseData: data) }
                completion(result)
            }
        }
    }
    
    /**
     Returns a task for fetching and parsing articles specified by provided request.
     
     - Parameter request: An `ArxivRequest` value that specifies the articles to be fetched by the task.
     - Parameter keyPath: A key path that indicates the property to assign.
     - Parameter completion: The object that contains the property.
     
     When the task completes, a result is assigned to property indicated by`keyPath` on the provided object.
     
     - Note: The assignment happens on session's `delegateQueue`.
     */
    func fetchTask<Root>(
        with request: ArxivRequest,
        assignResultTo keyPath: ArxivFetchResultKeypath<Root>,
        on object: Root
    ) -> URLSessionDataTask {
        
        return dataTask(with: URLRequest(url: request.url)) { data, response, error in
                        
            if let error = error as NSError? {
                object[keyPath: keyPath] = .failure(ArxivKitError.urlDomainError(error))
            } else if let data = data {
                let parser = ArxivParser()
                let result = Result { try parser.parse(responseData: data) }
                object[keyPath: keyPath] = result
            }
        }
    }
}
