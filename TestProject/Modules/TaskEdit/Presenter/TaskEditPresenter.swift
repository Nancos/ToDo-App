@MainActor
protocol TaskEditProtocol: AnyObject {
    func configureView(with data: TasksViewData?)
    func setupNewID(with id: Int)
    func showErrorMessage(_ message: String)
}

final class TaskEditPresenter {
    private let model = TaskEditModel()
    weak var delegate: TaskEditProtocol?

    func loadTaskData(id: Int?) {
        Task {
            if let id { await fetchTask(id: id) }
            else {
                let newID = await createNewTask()
                await fetchTask(id: newID)
                await delegate?.setupNewID(with: newID)
            }
        }
    }

    func fetchTask(id: Int?) async {
        do {
            if let task = try await model.fetchTask(id: id) {
                await delegate?.configureView(with: TasksViewData.formatCoreDataTask(task: task))
            } else {
                await delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.taskNotFound))
                await delegate?.configureView(with: nil)
            }
        } catch {
            await delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.fetchFailed(error)))
            await delegate?.configureView(with: nil)
        }
    }

    func checkEmptyTask(_ id: Int?) {
        Task {
            guard let id else { return }
            do {
                try await model.checkEmptyTask(id: id)
            } catch {
                await delegate?.showErrorMessage(String(localized: "error_try_again"))
            }
        }
    }

    func updateTask(id: Int?, newTitle: String? = nil, newDescription: String? = nil, newStatus: Bool? = nil) {
        Task {
            do {
                try await model.updateTask(id: id, newTitle: newTitle, newDescription: newDescription, newStatus: newStatus)
            } catch {
                await delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.updateFailed(error)))
            }
        }
    }

    func getIdNewTask() async -> Int {
        do {
            return try await model.getIdNewTask()
        } catch {
            await delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.taskNotFound))
            return -1
        }
    }

    func createNewTask() async -> Int {
        do {
            return try await model.createNewTask()
        } catch {
            await delegate?.showErrorMessage(CoreDataError.description(for: CoreDataError.saveFailed(error)))
            return -1
        }
    }
}
