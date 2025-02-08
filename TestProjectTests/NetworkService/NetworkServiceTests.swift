import XCTest
@testable import TestProject

struct MockTask: Codable, Equatable {
    let id: Int
    let todo: String
    
    static func getMockTask() -> [MockTask] { return [MockTask(id: 1, todo: "Test Task")] }
}

final class NetworkServiceTests: XCTestCase {
    
    var networkService: NetworkService!
    var mockNetworkHelper: MockNetworkHelper!
    
    override func setUp() {
        super.setUp()
        mockNetworkHelper = MockNetworkHelper()
        networkService = NetworkService(networkHelper: mockNetworkHelper)
    }
    
    override func tearDown() {
        mockNetworkHelper = nil
        networkService = nil
        super.tearDown()
    }
    
    func testFetchTasksSuccess() async throws {
        let jsonData = try JSONEncoder().encode(MockTask.getMockTask())
        mockNetworkHelper.mockData = jsonData
        let tasks: [MockTask] = try await networkService.fetchTasks()
        XCTAssertEqual(tasks, MockTask.getMockTask(), "Полученные данные не соответствуют ожидаемым")
    }
    
    func testFetchTasksFailure() async {
        do {
            let _: [MockTask] = try await networkService.fetchTasks()
            XCTFail("Ожидалось ошибка, но ее не было")
        } catch {
            XCTAssertNotNil(error, "Ошибка должна была быть не nil")
        }
    }
}
