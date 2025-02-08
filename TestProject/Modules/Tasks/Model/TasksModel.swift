import UIKit

final class TasksModel {
    
    private let coreDataManager = CoreDataManager.shared
    private let networkService = NetworkService.shared
    
    func fetchTask(with id: Int) async throws -> TasksData {
        guard let task = try await coreDataManager.fetchTask(by: id) else {
            throw CoreDataError.taskNotFound
        }
        return task
    }
    
    func fetchTasks() async throws -> [TasksViewData] {
        let tasks: Tasks = try await networkService.fetchTasks()
        return TasksViewData.formatAPITasks(tasks: tasks.todos)
    }
    
    func fetchTaskWithText(_ text: String) async throws -> [TasksData] { 
        return try await coreDataManager.fetchTaskWithText(text)
    }
    
    func deleteAllTasks() async throws {
        try await coreDataManager.deleteAllTasks()
    }
    
    func saveTasks(tasks: [TasksViewData]) async throws {
        try await coreDataManager.saveTasks(tasks: tasks)
    }
    
    func fetchSavedTasks() async throws -> [TasksData] {
        return try await coreDataManager.fetchSavedTasks()
    }
    
    func updateTaskData(id: Int, newStatus: Bool) async throws {
        try await coreDataManager.updateTaskData(id: id, newStatus: newStatus)
    }
    
    func removeTask(id: Int) async throws {
        try await coreDataManager.removeTask(id: id)
    }
}
