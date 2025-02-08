import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init() {
        persistentContainer = NSPersistentContainer(name: "TasksData")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error { fatalError(CoreDataError.persistentStoreLoadingFailed(error).localizedDescription) }
        }
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func deleteAllTasks() async throws {
        try await backgroundContext.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TasksData.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.backgroundContext.execute(deleteRequest)
                try self.backgroundContext.save()
            } catch {
                throw CoreDataError.saveFailed(error)
            }
        }
    }
    
    func saveTasks(tasks: [TasksViewData]) async throws {
        try await backgroundContext.perform {
            tasks.forEach { [weak self] task in
                
                guard let `self` else { return }
                
                let taskEntity = TasksData(context: self.backgroundContext)
                taskEntity.id = Int32(task.id)
                taskEntity.descriptionTask = task.descriptionTask
                taskEntity.dateString = task.dateTask
                taskEntity.titleTask = task.nameTask
                taskEntity.completed = task.completed
            }
            try self.backgroundContext.save()
        }
    }
    
    func createNewTask() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform { [weak self] in
                guard let `self` else { return }
                
                Task {
                    do {
                        let id = try await self.getIdNewTask()

                        let newTask = TasksData(context: self.backgroundContext)
                        newTask.id = Int32(id)
                        newTask.titleTask = ""
                        newTask.descriptionTask = ""
                        newTask.completed = false
                        newTask.dateString = TasksViewData.getCurrentDate()

                        try self.backgroundContext.save()
                        continuation.resume(returning: id)
                    } catch {
                        continuation.resume(throwing: CoreDataError.saveFailed(error))
                    }
                }
            }
        }
    }
    
    private func fetchTasks(byPredicate predicate: NSPredicate, sortedBy sortDescriptor: NSSortDescriptor? = nil) async throws -> [TasksData] {
        return try await backgroundContext.perform {
            let fetchRequest: NSFetchRequest<TasksData> = TasksData.fetchRequest()
            fetchRequest.predicate = predicate
            
            if let sortDescriptor { fetchRequest.sortDescriptors = [sortDescriptor] }
            
            do {
                return try self.backgroundContext.fetch(fetchRequest)
            } catch {
                throw CoreDataError.fetchFailed(error)
            }
        }
    }
    
    func fetchTaskWithText(_ text: String) async throws -> [TasksData] {
        let predicate = NSPredicate(format: "titleTask CONTAINS[cd] %@ OR descriptionTask CONTAINS[cd] %@", text, text)
        return try await fetchTasks(byPredicate: predicate)
    }
    
    func fetchSavedTasks() async throws -> [TasksData] {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        return try await fetchTasks(byPredicate: NSPredicate(value: true), sortedBy: sortDescriptor)
    }
    
    func fetchTask(by id: Int) async throws -> TasksData? {
        let predicate = NSPredicate(format: "id == %d", Int32(id))
        let tasks = try await fetchTasks(byPredicate: predicate)
        return tasks.first
    }
    
    func updateTaskData(id: Int, newTitle: String? = nil, newDescription: String? = nil, newStatus: Bool? = nil) async throws {
        try await backgroundContext.perform {
            let fetchRequest: NSFetchRequest<TasksData> = TasksData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", Int32(id))
            
            do {
                guard let task = try self.backgroundContext.fetch(fetchRequest).first else {
                    throw CoreDataError.taskNotFound
                }
                
                if let newTitle { task.titleTask = newTitle }
                if let newDescription { task.descriptionTask = newDescription }
                if let newStatus { task.completed = newStatus }
                
                try self.backgroundContext.save()
            } catch {
                throw CoreDataError.saveFailed(error)
            }
        }
    }
    
    func removeTask(id: Int) async throws {
        try await backgroundContext.perform {
            let fetchRequest: NSFetchRequest<TasksData> = TasksData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", Int32(id))
            
            do {
                guard let task = try self.backgroundContext.fetch(fetchRequest).first
                else { throw CoreDataError.taskNotFound }
                
                self.backgroundContext.delete(task)
                try self.backgroundContext.save()
            } catch {
                throw CoreDataError.saveFailed(error)
            }
        }
    }
    
    func getIdNewTask() async throws -> Int {
        return try await backgroundContext.perform {
            let fetchRequest: NSFetchRequest<TasksData> = TasksData.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchLimit = 1
            
            do {
                if let result = try self.backgroundContext.fetch(fetchRequest).first {
                    return Int(result.id) + 1
                } else { return 1 }
            } catch {
                throw CoreDataError.fetchFailed(error)
            }
        }
    }
}
