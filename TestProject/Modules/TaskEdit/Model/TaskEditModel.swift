final class TaskEditModel {
    private let coreDataManager = CoreDataManager.shared
    
    func checkEmptyTask(id: Int) async throws {
        let task = try await coreDataManager.fetchTask(by: id)
        guard let task else { return }
        let isTaskEmpty = (task.titleTask?.isEmpty ?? true) && (task.descriptionTask?.isEmpty ?? true) && true
        if isTaskEmpty { try await coreDataManager.removeTask(id: id) }
    }
    
    func fetchTask(id: Int?) async throws -> TasksData? {
        guard let id else { throw CoreDataError.taskNotFound }
        return try await coreDataManager.fetchTask(by: id)
    }
    
    func updateTask(id: Int?, newTitle: String? = nil, newDescription: String? = nil, newStatus: Bool? = nil) async throws {
        guard let id else { throw CoreDataError.taskNotFound }
        try await coreDataManager.updateTaskData(id: id, newTitle: newTitle, newDescription: newDescription, newStatus: newStatus)
    }
    
    func getIdNewTask() async throws -> Int {
        return try await coreDataManager.getIdNewTask()
    }

    func createNewTask() async throws -> Int {
        return try await coreDataManager.createNewTask()
    }
}
