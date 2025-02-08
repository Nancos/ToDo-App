import UIKit
import CoreData

@MainActor
protocol TasksPresenterProtocol {
    func showStatus(message: String)
    func shareMessage(message: String)
    func configureView(with data: [TasksViewData], countTasks: String)
    func updateSearchResults(with data: [TasksViewData], countTasks: String)
}

final class TasksPresenter {
    private let model = TasksModel()
    var delegate: TasksPresenterProtocol?
}

extension TasksPresenter {
    func getSharedString(with id: Int) {
        Task {
            do {
                let task = try await model.fetchTask(with: id)
                await delegate?.shareMessage(message: formatSharedString(task: task))
            } catch {
                await delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.taskNotFound))
            }
        }
    }

    func searchTasks(with text: String) {
        Task {
            do {
                let tasks = try await model.fetchTaskWithText(text)
                await delegate?.updateSearchResults(with: TasksViewData.formatCoreDataTasks(tasks: tasks),
                                                     countTasks: String(localized: "\(tasks.count) tasks"))
            } catch {
                await delegate?.showStatus(message: "Error fetching tasks: \(error.localizedDescription)")
            }
        }
    }

    func fetchTasks(_ isFirstLaunch: Bool) {
        Task {
            if isFirstLaunch {
                firstLaunchFetchTasks()
            } else {
                regularLaunch()
            }
        }
    }

    func regularLaunch() {
        Task {
            do {
                let savedTasks = try await model.fetchSavedTasks()
                await delegate?.configureView(with: TasksViewData.formatCoreDataTasks(tasks: savedTasks),
                                              countTasks: String(localized: "\(savedTasks.count) tasks"))
            } catch {
                await delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.fetchFailed(error)))
            }
        }
    }

    func updateCompletedStatus(id: Int, completed: Bool) {
        Task {
            do {
                try await model.updateTaskData(id: id, newStatus: completed)
            } catch {
                await delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.updateFailed(error)))
            }
        }
    }

    func removeTask(id: Int) {
        Task {
            do {
                try await model.removeTask(id: id)
            } catch {
                await delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.deleteFailed(error)))
            }
        }
    }
}


private extension TasksPresenter {
    func firstLaunchFetchTasks() {
        Task {
            do {
                try await model.deleteAllTasks()
                let tasks = try await model.fetchTasks()
                if tasks.isEmpty {
                    await delegate?.configureView(with: [],
                                                  countTasks: String(localized: "\(tasks.count) tasks"))
                    return
                }
                try await model.saveTasks(tasks: tasks)
                await delegate?.configureView(with: tasks,
                                              countTasks: String(localized: "\(tasks.count) tasks"))
            } catch {
                await delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.fetchFailed(error)))
            }
        }
    }
    
    func formatSharedString(task: TasksData) -> String {
        """
        \(String(localized: "task_title")): \(task.titleTask ?? String(localized:"empty_title"))
        \(String(localized: "description")): \(task.descriptionTask ?? String(localized:"empty_description"))
        \(String(localized: "date")): \(task.dateString ?? String(localized:"empty_date"))
        """
    }
}
