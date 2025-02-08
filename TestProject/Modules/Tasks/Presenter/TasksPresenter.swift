import UIKit
import CoreData

protocol TasksPresenterProtocol {
    func showStatus(message: String)
    func configureView(with data: [TasksViewData], countTasks: String)
    func updateSearchResults(with data: [TasksViewData], countTasks: String)
}

import UIKit

class TasksPresenter {
    private let model = TasksModel()
    var delegate: TasksPresenterProtocol?
}

@MainActor
extension TasksPresenter {
    
    func getSharedString(with id: Int) async -> String {
        do {
            let task = try await model.fetchTask(with: id)
            let sharedString = """
                    \(String(localized: "task_title")): \(task.titleTask ?? String(localized:"empty_title"))
                    \(String(localized: "description")): \(task.descriptionTask ?? String(localized:"empty_description"))
                    \(String(localized: "date")): \(task.dateString ?? String(localized:"empty_date"))
                    """
            return sharedString
        } catch {
            delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.taskNotFound))
            return ""
        }
    }
    
    func searchTasks(with text: String) async {
        do {
            let tasks = try await model.fetchTaskWithText(text)
            delegate?.updateSearchResults(with: TasksViewData.formatCoreDataTasks(tasks: tasks),
                                          countTasks: (String(localized: "\(tasks.count) tasks")))
        } catch {
            print("Error fetching tasks:", error)
        }
    }
    
    func fetchTasks(_ isFirstLaunch: Bool) async {
        if isFirstLaunch { await firstLaunchFetchTasks() }
        else { await regularLaunch() }
    }
    
    func firstLaunchFetchTasks() async {
        do {
            try await model.deleteAllTasks()
            let tasks = try await model.fetchTasks()
            if tasks.isEmpty {
                delegate?.configureView(with: [],
                                        countTasks: (String(localized: "\(tasks.count) tasks")))
                return
            }
            try await model.saveTasks(tasks: tasks)
            delegate?.configureView(with: tasks,
                                    countTasks: (String(localized: "\(tasks.count) tasks")))
        } catch {
            delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.fetchFailed(error)))
        }
    }
    
    func regularLaunch() async {
        do {
            let savedTasks = try await model.fetchSavedTasks()
            delegate?.configureView(with: TasksViewData.formatCoreDataTasks(tasks: savedTasks),
                                    countTasks: (String(localized: "\(savedTasks.count) tasks")))
        } catch {
            delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.fetchFailed(error)))
        }
    }
    
    func updateCompletedStatus(id: Int, completed: Bool) async {
        do {
            try await model.updateTaskData(id: id, newStatus: completed)
        } catch {
            delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.updateFailed(error)))
        }
    }
    
    func removeTask(id: Int) async {
        do {
            try await model.removeTask(id: id)
        } catch {
            delegate?.showStatus(message: CoreDataError.description(for: CoreDataError.deleteFailed(error)))
        }
    }
}
