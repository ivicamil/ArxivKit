
import Foundation


public final class FetchTask {
    
    public let request: Request
        
    private weak var urlSession: URLSession?
    
    private weak var dataTask: URLSessionDataTask?
    
    private let parser = Parser()
    
    private let parserQueue = DispatchQueue(label: "io.polifonia.ArticlesKit.parserQueue")

    private let id = UUID()
    
    let completion: (Result<Response, ArxivKitError>) -> ()
    
    init(request: Request, urlSession: URLSession, completion: @escaping (Result<Response, ArxivKitError>) -> ()) {
        self.request = request
        self.urlSession = urlSession
        self.completion = completion
    }
    
    public func run() {
        
        guard let requestURL = request.url else {
            completion(.failure(.invalidRequest))
            return
        }
                
        dataTask = urlSession?.dataTask(with: URLRequest(url: requestURL)) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error as NSError? {
                if !(error.domain == NSURLErrorDomain  && error.code == NSURLErrorCancelled) {
                    self.completion(.failure(.urlDomainError(error)))
                }
            } else if let data = data {
                self.parserQueue.async {
                    self.parser.parse(responseData: data, completion: self.completion)
                }
            }
            self.dataTask = nil
        }
        dataTask?.resume()
    }
    
    public func cancel() {
        dataTask?.cancel()
        parserQueue.async { [weak self] in
            guard let self = self else { return }
            self.parser.abort()
            self.completion(.failure(.taskCanceled))
        }
    }
}

extension FetchTask: Hashable {
    
    public static func == (lhs: FetchTask, rhs: FetchTask) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
