//
//  TasksManager.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 26.05.2022.
//

protocol TaskManagerPr {
    func getTasks() -> [Task]
    func addTask(title: String, priority: TaskPriority, status: TaskStatus)
    func update(taskId: String, withTitle title: String)
    func update(taskId: String, withStatus status: TaskStatus)
    func update(taskId: String, withPriority priority: TaskPriority)
    func remove(taskId: String)
}

class TaskManager: TaskManagerPr {
    
    private var taskStorage: TaskStoragePr!
    private var tasks: [Task] = []
    
    init(taskStorage: TaskStoragePr = TaskStorage()) {
        self.taskStorage = taskStorage
        tasks = taskStorage.loadTasks()
    }
    
    func getTasks() -> [Task] {
        tasks.sorted(by: { $0.title < $1.title })
    }
    
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) {
        tasks.append(Task(title: title, priority: priority, status: status))
    }
    
    func update(taskId: String, withTitle title: String) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId })
        else { return print("Wrong taskId") }
        tasks[taskIndex].title = title
    }
    
    func update(taskId: String, withStatus status: TaskStatus) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId })
        else { return print("Wrong taskId") }
        tasks[taskIndex].status = status
    }
    
    func update(taskId: String, withPriority priority: TaskPriority) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId })
        else { return print("Wrong taskId") }
        tasks[taskIndex].priority = priority
    }
    
    func remove(taskId: String) {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == taskId })
        else { return print("Wrong taskId") }
        tasks.remove(at: taskIndex)
    }
}
