
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/**
 Fetch task completion handler.
 
 The completion handler takes a single `Result` argument, which is either a succesfuly
 parsed `ArxivResponse` or an error,  if one occurs.
 The error is either `ArxivURLError`, `ArxivServerError`, `ArxivParserError` or `ArxivAPIError`.
 */
public typealias ArxivFetchTaskCompetionHandler = (Result<ArxivResponse, Error>) -> ()

/**
 A keypath for storing fetch task results.
 
 The  result is either a succesfuly
 parsed `ArxivResponse` or an error,  if one occurs.
 The error is either `ArxivURLError`, `ArxivServerError`, `ArxivParserError` or `ArxivAPIError`.
 */
public typealias ArxivFetchResultKeypath<Root> = ReferenceWritableKeyPath<Root, Result<ArxivResponse, Error>>

public extension URLSession {
    
    /**
     Returns a task for fetching and parsing articles specified by provided request.
     
     - Parameter request: An `ArxivRequest` value that specifies the articles to be fetched by the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed `ArxivResponse` or an error,  if one occurs.
     The error is either `ArxivURLError`, `ArxivServerError`, `ArxivParserError` or `ArxivAPIError`.
     
     - Note: Completion handler is called on session's `delegateQueue`.
     */
    func fetchTask(with request: ArxivRequest, completion: @escaping ArxivFetchTaskCompetionHandler) -> URLSessionDataTask {
        
        return dataTask(with: URLRequest(url: request.url)) { data, response, error in
                      
            if let error = error as NSError? {
                completion(.failure(ArxivURLError.urlError(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(ArxivServerError.unexpectedHTTPError))
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                completion(.failure(ArxivServerError.httpResponseError(statusCode: response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(ArxivURLError.unexpectedURLError))
                return
            }
            
            let parser = ArxivParser()
            let result = Result { try parser.parse(responseData: data) }
            completion(result)
        }
    }
    
    /**
     Returns a task for fetching and parsing articles specified by provided request.
     
     - Parameter request: An `ArxivRequest` value that specifies the articles to be fetched by the task.
     - Parameter keyPath: A key path that indicates the property to assign.
     - Parameter object: The object that contains the property.
     
     When the task completes, a result is assigned to property indicated by`keyPath` on the provided object.
     
     The  result is either a succesfuly
     parsed `ArxivResponse` or an error,  if one occurs.
     The error is either `ArxivURLError`, `ArxivServerError`, `ArxivParserError` or `ArxivAPIError`.
     
     - Note: The assignment happens on session's `delegateQueue`.
     */
    func fetchTask<Root>(
        with request: ArxivRequest,
        assignResultTo keyPath: ArxivFetchResultKeypath<Root>,
        on object: Root
    ) -> URLSessionDataTask {
        
        return fetchTask(with: request) {
            object[keyPath: keyPath] = $0
        }
    }
}

public extension ArxivParser {
    
    /**
     Parses provided `URLSessionDataTask` result into `ArxivResponse`.
     
     - Parameter result: A tuple containing `URLSessionDataTask` data and URL response.
     
     This is a convenience method that can be used to process `URLSession.DataTaskPublisher` result.
     
     - Throws: `ArxivServerError`, `ArxivParserError` or `ArxivAPIError`.
     */
    func parse(_ result: (data: Data, response: URLResponse)) throws -> ArxivResponse {
        
        let (data, response) = result
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ArxivServerError.unexpectedHTTPError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ArxivServerError.httpResponseError(statusCode: httpResponse.statusCode)
        }
        
        return try parse(responseData: data)
    }
}
