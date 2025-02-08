import Foundation

protocol NetworkHelperProtocol {
    func createRequest() throws -> URLRequest
    func fetchData<T: Decodable>(from request: URLRequest) async throws -> T
}

final class NetworkHelper: NetworkHelperProtocol {
    
    private let baseURL = "https://dummyjson.com/todos"
    
    lazy var session = URLSession.shared
    
    func createRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        return URLRequest(url: url)
    }
    
    func fetchData<T: Decodable>(from request: URLRequest) async throws -> T {
        do {
            let (data, responce) = try await session.data(for: request)
            
            guard let httpResponse = responce as? HTTPURLResponse else {
                throw NetworkError.invalidResponce
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error: error)
            }
        }
    }
}
