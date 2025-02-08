import Foundation

struct TasksViewData {
    var id: Int
    var dateTask: String
    var nameTask: String
    var descriptionTask: String
    var completed: Bool
}

extension TasksViewData {
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: Date())
    }
    
    static func formatAPITasks(tasks: [Todo]?) -> [TasksViewData] {
        guard let tasks else { return []}
        return tasks.map { task in
            return TasksViewData(
                id: task.id,
                dateTask: getCurrentDate(),
                nameTask: task.todo ?? String(localized: "empty_title"),
                descriptionTask: String(localized: "empty_description"),
                completed: task.completed ?? false)
        }
    }
    
    static func formatCoreDataTasks(tasks: [TasksData]?) -> [TasksViewData] {
        guard let tasks else { return [] }
        return tasks.map { task in
            return TasksViewData(
                id: Int(task.id),
                dateTask: task.dateString ?? getCurrentDate(),
                nameTask: task.titleTask ?? String(localized: "empty_title"),
                descriptionTask: task.descriptionTask ?? String(localized: "empty_description"),
                completed: task.completed)
        }
    }
    
    static func formatCoreDataTask(task: TasksData) -> TasksViewData {
        return TasksViewData(
            id: Int(task.id),
            dateTask: task.dateString ?? getCurrentDate(),
            nameTask: task.titleTask ?? String(localized: "empty_title"),
            descriptionTask: task.descriptionTask ?? String(localized: "empty_description"),
            completed: task.completed)
    }
}
