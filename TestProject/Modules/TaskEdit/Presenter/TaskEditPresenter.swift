protocol TaskEditProtocol {
    @MainActor func configureView(with data: TasksViewData?)
    func showErrorMessage(_ message: String)
}

@MainActor
final class TaskEditPresenter {
    private let model = TaskEditModel()
    var delegate: TaskEditProtocol?
    
    func fetchTask(id: Int?) async {
        do {
            if let task = try await model.fetchTask(id: id) {
                delegate?.configureView(with: TasksViewData.formatCoreDataTask(task: task))
            } else {
                delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.taskNotFound))
                delegate?.configureView(with: nil)
            }
        } catch {
            delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.fetchFailed(error)))
            delegate?.configureView(with: nil)
        }
    }
    
    func checkEmptyTask(_ id: Int?) async {
        guard let id else { return }
        do {
            try await model.checkEmptyTask(id: id)
        } catch {
            delegate?.showErrorMessage(String(localized: "error_try_again"))
        }
    }
    
    func updateTask(id: Int?, newTitle: String? = nil, newDescription: String? = nil, newStatus: Bool? = nil) async {
        do {
            try await model.updateTask(id: id, newTitle: newTitle, newDescription: newDescription, newStatus: newStatus)
        } catch {
            delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.updateFailed(error)))
        }
    }
    
    func getIdNewTask() async -> Int {
        do {
            return try await model.getIdNewTask()
        } catch {
            delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.taskNotFound))
            return 1
        }
    }

    func createNewTask() async -> Int {
        do {
            return try await model.createNewTask()
        } catch {
            delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.saveFailed(error)))
            return -1
        }
    }
}
