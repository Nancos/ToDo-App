import XCTest
@testable import TestProject

final class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    
    let tasks = [
        TasksViewData(id: 1, dateTask: "01/01/2023", nameTask: "First", descriptionTask: "Description 1", completed: false),
        TasksViewData(id: 2, dateTask: "01/02/2023", nameTask: "Second", descriptionTask: "Description 2", completed: true),
        TasksViewData(id: 3, dateTask: "01/03/2023", nameTask: "First Second", descriptionTask: "Description 3", completed: false),
        TasksViewData(id: 4, dateTask: "01/04/2023", nameTask: "Second Firs", descriptionTask: "Description 4", completed: false),
        TasksViewData(id: 5, dateTask: "01/05/2023", nameTask: "Hello", descriptionTask: "Description 5", completed: false),
        TasksViewData(id: 6, dateTask: "01/06/2023", nameTask: "Create", descriptionTask: "Description 6", completed: true),
        TasksViewData(id: 7, dateTask: "01/07/2023", nameTask: "Test", descriptionTask: "Description 7", completed: false),
        TasksViewData(id: 8, dateTask: "01/08/2023", nameTask: "Task 1", descriptionTask: "Description 8", completed: true),
        TasksViewData(id: 9, dateTask: "01/09/2023", nameTask: "Task 2", descriptionTask: "Description 9", completed: false),
        TasksViewData(id: 10, dateTask: "01/10/2023", nameTask: "Task 3", descriptionTask: "Description 10", completed: true),
        TasksViewData(id: 11, dateTask: "01/11/2023", nameTask: "Task 4", descriptionTask: "Description 11", completed: true),
        TasksViewData(id: 12, dateTask: "01/12/2023", nameTask: "Task 5", descriptionTask: "", completed: true)
    ]
        
    override func setUp() async throws {
        try await super.setUp()
        coreDataManager = CoreDataManager()
        try await coreDataManager.deleteAllTasks()
    }
        
    override func tearDown() async throws {
        coreDataManager = nil
        try await super.tearDown()
    }
    
    func testDeleteAllTasks() async throws {
        try await coreDataManager.deleteAllTasks()
        let savedTasks = try await coreDataManager.fetchSavedTasks()
        XCTAssertEqual(savedTasks.count, 0, "Список задач не пуст после удаления")
    }
    
    func testSaveTasks() async throws {
        try await coreDataManager.saveTasks(tasks: tasks)
        let savedTasks = try await coreDataManager.fetchSavedTasks()
        XCTAssertEqual(savedTasks.count, tasks.count, "Ожидалось \(tasks.count) задач, но получено \(savedTasks.count)")
    }
    
    func testCreateNewTask() async throws {
        let newTaskId = try await coreDataManager.createNewTask()
        XCTAssertEqual(newTaskId, 1, "Ожидался id новой задачи равный 1, но получено \(newTaskId)")
        let savedTasks = try await coreDataManager.fetchSavedTasks()
        XCTAssertEqual(savedTasks.count, 1, "Ожидалась 1 задача, но получено \(savedTasks.count)")
    }
    
    func testFetchTaskWithText() async throws {
        try await coreDataManager.saveTasks(tasks: tasks)
        
        let resultFetch1 = try await coreDataManager.fetchTaskWithText("Description")
        XCTAssertEqual(resultFetch1.count, 11, "Ожидалось 11 задач, но получено \(resultFetch1.count)")
        
        let resultFetch2 = try await coreDataManager.fetchTaskWithText("Second")
        XCTAssertEqual(resultFetch2.count, 3, "Ожидалось 3 задачи, но получено \(resultFetch2.count)")
        
        let resultFetch3 = try await coreDataManager.fetchTaskWithText("First")
        XCTAssertEqual(resultFetch3.count, 2, "Ожидалось 2 задачи, но получено \(resultFetch3.count)")
    }
    
    func testFetchTaskWithTextEmpty() async throws {
        try await coreDataManager.saveTasks(tasks: tasks)
        let resultFetch1 = try await coreDataManager.fetchTaskWithText("")
        XCTAssertEqual(resultFetch1.count, 0, "Поиск по пустому запросу должен вернуть 0 задач, но получено \(resultFetch1.count)")
    }
    
    func testFetchTaskById() async throws {
        try await coreDataManager.saveTasks(tasks: tasks)
        
        let resultFetch1 = try await coreDataManager.fetchTask(by: 0)
        XCTAssertNil(resultFetch1, "Ожидалось, что задачи с ID 0 не существует")
        
        let resultFetch2 = try await coreDataManager.fetchTask(by: 2)
        XCTAssertEqual(resultFetch2?.id, 2, "Ожидалась задача с ID 2, но получено \(resultFetch2?.id ?? -1)")
    }
    
    func testUpdateTaskData() async throws {
        try await coreDataManager.saveTasks(tasks: tasks)

        try await coreDataManager.updateTaskData(id: 1, newTitle: "testUpdateTaskData")
        let updatedTask = try await coreDataManager.fetchTask(by: 1)
        XCTAssertEqual(updatedTask?.titleTask, "testUpdateTaskData", "Название задачи не обновилось")
    }
    
    func testRemoveTask() async throws {
        try await coreDataManager.saveTasks(tasks: tasks)
        let countBefore = try await coreDataManager.fetchSavedTasks().count
        
        try await coreDataManager.removeTask(id: 1)
        let result = try await coreDataManager.fetchTask(by: 1)
        let countAfter = try await coreDataManager.fetchSavedTasks().count

        XCTAssertNil(result, "Задача не удалена")
        XCTAssertEqual(countAfter, countBefore - 1, "Удаление задачи не уменьшило количество задач")
    }
    
    func testGetIdForNewTask() async throws {
        try await coreDataManager.saveTasks(tasks: tasks)
        let currentMaxId = tasks.max(by: { $0.id < $1.id })?.id ?? 0
        let result = try await coreDataManager.getIdNewTask()
        XCTAssertEqual(result, currentMaxId + 1, "Выдан неверный новый ID: \(result)")
    }
}
