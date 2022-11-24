//
//  TasksManager.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 26.05.2022.
//

import Foundation

protocol TaskRepositoryPr {
    func loadTasks() async throws -> [Task]
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) async throws -> Task
    func updateTask(byId id: String, withTitle title: String) async throws
    func updateTask(byId id: String, withStatus status: TaskStatus) async throws
    func updateTask(byId id: String, withPriority priority: TaskPriority) async throws
    func removeTask(byId id: String) async throws
}

protocol TaskManagerPr {
    var tasks: [Task] { get }
    func loadTasks() async throws
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) async throws
    func updateTask(byId id: String, withTitle title: String) async throws
    func updateTask(byId id: String, withStatus status: TaskStatus) async throws
    func updateTask(byId id: String, withPriority priority: TaskPriority) async throws
    func removeTask(byId id: String) async throws
}

enum TaskManagerError: Error, LocalizedError {
    case wrongTaskId
    var errorDescription: String? {
        switch self {
        case .wrongTaskId: return "Wrong task id." }
    }
}

class TaskManager: TaskManagerPr {
    
    private(set) var tasks: [Task] = [] {
        didSet { tasks.sort(by: { $0.title < $1.title }) }
    }
    
    private let taskRepository: TaskRepositoryPr
    
    init(taskRepository: TaskRepositoryPr) {
        self.taskRepository = taskRepository
    }
    
    func loadTasks() async throws {
        tasks = try await taskRepository.loadTasks()
    }
    
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) async throws {
        let task = try await taskRepository.addTask(title: title, priority: priority, status: status)
        tasks.append(task)
    }
    
    func updateTask(byId id: String, withTitle title: String) async throws {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == id }) else {
            throw TaskManagerError.wrongTaskId
        }
        try await taskRepository.updateTask(byId: id, withTitle: title)
        tasks[taskIndex].title = title
    }
    
    func updateTask(byId id: String, withStatus status: TaskStatus) async throws {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == id }) else {
            throw TaskManagerError.wrongTaskId
        }
        try await taskRepository.updateTask(byId: id, withStatus: status)
        tasks[taskIndex].status = status
    }
    
    func updateTask(byId id: String, withPriority priority: TaskPriority) async throws {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == id }) else {
            throw TaskManagerError.wrongTaskId
        }
        try await taskRepository.updateTask(byId: id, withPriority: priority)
        tasks[taskIndex].priority = priority
    }
    
    func removeTask(byId id: String) async throws {
        guard let taskIndex = tasks.firstIndex(where: { $0.id == id }) else {
            throw TaskManagerError.wrongTaskId
        }
        try await taskRepository.removeTask(byId: id)
        tasks.remove(at: taskIndex)
    }
}
