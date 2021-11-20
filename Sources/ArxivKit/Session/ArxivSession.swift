
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
        
        return dataTask(with: URLRequest(url: request.url)) { [weak self] data, response, error in
                      
            if let error = error as NSError? {
                completion(.failure(ArxivURLError.urlError(error)))
                return
            }
            
            if let responseError = self?.validateResponse(response) {
                completion(.failure(responseError))
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
     Downloads and parses articles specified by provided request and delivers the result asynchronously.
     
     - Parameter request: An `ArxivRequest` value that specifies the articles to be fetched asynchronously.
     - Parameter delegate: A delegate that receives life cycle and authentication challenge callbacks as the transfer progresses.
     
     - Throws: An error which is either `ArxivURLError`, `ArxivServerError`, `ArxivParserError` or `ArxivAPIError`.
     */
    @available(macOS 12.0.0, iOS 15.0.0, macCatalyst 15.0.0, *)
    func arxivResponse(for request: ArxivRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> ArxivResponse {
        
        do {
            let (data, response) = try await data(from: request.url, delegate: delegate)
            
            if let responseError = validateResponse(response) {
                 throw responseError
            }
            
            let parser = ArxivParser()
            return try parser.parse(responseData: data)
        } catch {
            throw ArxivURLError.urlError(error)
        }
    }
    
    private func validateResponse(_ response: URLResponse?) -> Error? {
        
        guard let response = response as? HTTPURLResponse else {
            return ArxivServerError.unexpectedHTTPError
        }
        
        guard (200...299).contains(response.statusCode) else {
            return ArxivServerError.httpResponseError(statusCode: response.statusCode)
        }
        
        return nil
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
     
     - Parameter urlDataTaskResult: A tuple containing raw data and URL response returned by a task.
     
     This is a convenience method that can be used to process `URLSession.DataTaskPublisher` result.
     
     - Throws: `ArxivServerError`, `ArxivParserError` or `ArxivAPIError`.
     */
    func parse(urlDataTaskResult: (data: Data, response: URLResponse)) throws -> ArxivResponse {
        
        let (data, response) = urlDataTaskResult
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ArxivServerError.unexpectedHTTPError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ArxivServerError.httpResponseError(statusCode: httpResponse.statusCode)
        }
        
        return try parse(responseData: data)
    }
}

