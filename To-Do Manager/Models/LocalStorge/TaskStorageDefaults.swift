//
//  TaskStorageDefaults.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 25.05.2022.
//

import UIKit

@MainActor
class TaskStorageDefaults: TaskRepositoryPr {
    
    private let defaults = UserDefaults.standard
    private let taskKey = "tasks"
    
    private var tasks: [Task] = []
    
    func loadTasks() async throws -> [Task] {
        let tasksData = defaults.array(forKey: taskKey) as? [Data] ?? []
        tasks = tasksData.compactMap { try? JSONDecoder().decode(Task.self, from: $0) }
        return tasks
    }
    
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) async throws -> Task {
        let task = Task(title: title, priority: priority, status: status)
        tasks.append(task)
        try saveTasks(tasks)
        return task
    }
    
    func updateTask(byId id: String, withTitle title: String) async throws {
        if let taskIndex = tasks.firstIndex(where: { $0.id == id }) {
            tasks[taskIndex].title = title
            try saveTasks(tasks)
        }
    }
    
    func updateTask(byId id: String, withStatus status: TaskStatus) async throws {
        if let taskIndex = tasks.firstIndex(where: { $0.id == id }) {
            tasks[taskIndex].status = status
            try saveTasks(tasks)
        }
    }
    
    func updateTask(byId id: String, withPriority priority: TaskPriority) async throws {
        if let taskIndex = tasks.firstIndex(where: { $0.id == id }) {
            tasks[taskIndex].priority = priority
            try saveTasks(tasks)
        }
    }
    
    func removeTask(byId id: String) async throws {
        if let taskIndex = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: taskIndex)
            try saveTasks(tasks)
        }
    }
    
    private func saveTasks(_ tasks: [Task]) throws {
        let tasksData = try tasks.compactMap { try JSONEncoder().encode($0) }
        defaults.set(tasksData, forKey: taskKey)
    }
}

extension TaskStorageDefaults {
    private var testTasks: [Task] {
        [ Task(title: "Купить хлеб", priority: .normal, status: .planned),
        Task(title: "Помыть кота", priority: .important, status: .planned),
        Task(title: "Отдать долг Арнольду", priority: .normal, status: .completed),
        Task(title: "Купить новый пылесос", priority: .normal, status: .completed),
        Task(title: "Подарить цветы супруге", priority: .important, status: .planned),
        Task(title: "Позвонить родителям", priority: .important, status: .completed),
        Task(title: "Пригласить на вечеринку Дольфа, Джеки, Леонардо, Уилла", priority: .important, status: .planned) ]
    }
}
