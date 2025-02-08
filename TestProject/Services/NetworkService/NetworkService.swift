import UIKit

final class NetworkService {
    static let shared = NetworkService()
    
    private let networkHelper: NetworkHelperProtocol
    
    init(networkHelper: NetworkHelperProtocol = NetworkHelper()) {
        self.networkHelper = networkHelper
    }
      
    func fetchTasks<T: Decodable>() async throws -> T {
        let request = try networkHelper.createRequest()
        return try await networkHelper.fetchData(from: request)
    }
}
