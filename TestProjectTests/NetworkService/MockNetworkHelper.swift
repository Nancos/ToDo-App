import Foundation

enum MockNetworkHelperError: Error {
    case noData
    case invalidURL
    case decodingError
}

final class MockNetworkHelper: NetworkHelperProtocol {
    
    var mockData: Data?
    
    func createRequest() throws -> URLRequest {
        guard let url = URL(string: "https://yandex.ru") else {
            throw MockNetworkHelperError.invalidURL
        }
        return URLRequest(url: url)
    }
    
    func fetchData<T: Decodable>(from request: URLRequest) async throws -> T {
        guard let mockData else { throw MockNetworkHelperError.noData }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: mockData)
        }
        catch {
            throw MockNetworkHelperError.decodingError
        }
    }
}
