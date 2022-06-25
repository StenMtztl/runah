import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum URLSessionErrors: Error {
  case incorrectResponse
}

extension URLSession {
  func dataTask<T: Decodable>(
    with request: URLRequest,
    type: T.Type,
    completionHandler: @escaping (Result<T, Error>) -> Void
  ) -> URLSessionDataTask {
    dataTask(with: request)
    { data, _, error in
      if let data = data {
        do {
          let response = try JSONDecoder().decode(T.self, from: data)
          completionHandler(.success(response))
        } catch {
          completionHandler(.failure(error))
        }
      } else {
        completionHandler(.failure(error ?? URLSessionErrors.incorrectResponse))
      }
    }
  }
}
