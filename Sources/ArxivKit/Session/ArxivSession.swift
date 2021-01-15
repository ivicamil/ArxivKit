
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias ArxivFetchTaskCompetionHandler = (Result<ArxivResponse, Error>) -> ()

public extension URLSession {
    
    /**
     Returns a task for fetching and parsing articles specified by provided request.
     
     - Parameter request: An `ArxivRequest` value that specifies the articles to be fetched by the task.
     - Parameter completion: A function to be called after the task finishes.
     
     The completion handler takes a single `Result` argument, which is either a succesfuly
     parsed `ArxivResponse`, or an `ArxivKitError`, if one occurs.
     
     */
    func fethTask(with request: ArxivRequest, completion: @escaping ArxivFetchTaskCompetionHandler) -> URLSessionDataTask {
        
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
}
