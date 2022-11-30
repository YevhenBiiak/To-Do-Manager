//
//  TaskStorageRealm.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 21.11.2022.
//

import RealmSwift
import Foundation

class TaskObject: Object {
    @Persisted var id: String
    @Persisted var title: String
    @Persisted var priority: String
    @Persisted var status: String
    
    convenience init(id: String, title: String, priority: String, status: String) {
        self.init()
        self.id = id
        self.title = title
        self.priority = priority
        self.status = status
    }
}

@MainActor
class TaskStorageRealm: TaskStoragePr {
    
    private let realm: Realm! = try? Realm()
    private var taskObjects: Results<TaskObject>!
    
    init() {
        taskObjects = realm.objects(TaskObject.self)
    }
    
    func loadTasks() -> [Task] {
        taskObjects.compactMap { $0.convertToTask }
    }
    
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) async throws -> Task {
        let task = Task(title: title, priority: priority, status: status)
        try realm.write {
            realm.add(task.convertToTaskObject)
        }
        return task
    }
    
    func updateTask(byId id: String, withTitle title: String) async throws {
        let taskToUpdate = taskObjects.where { query in
            query.id == id
        }
        try realm.write {
            taskToUpdate.first?.title = title
        }
    }
    
    func updateTask(byId id: String, withStatus status: TaskStatus) async throws {
        let taskToUpdate = taskObjects.where { query in
            query.id == id
        }
        try realm.write {
            taskToUpdate.first?.status = status.string
        }
    }
    
    func updateTask(byId id: String, withPriority priority: TaskPriority) async throws {
        let taskToUpdate = taskObjects.where { query in
            query.id == id
        }
        try realm.write {
            taskToUpdate.first?.priority = priority.string
        }
    }
    
    func removeTask(byId id: String) async throws {
        let taskToDelete = taskObjects.where { query in
            query.id == id
        }
        try realm.write {
            realm.delete(taskToDelete)
        }
    }
}

private extension TaskObject {
    var convertToTask: Task? {
        guard let priority = TaskPriority(string: self.priority),
              let status = TaskStatus(string: self.status) else { return nil }
        
        return Task(id: self.id, title: self.title, priority: priority, status: status)
    }
}

private extension Task {
    var convertToTaskObject: TaskObject {
        TaskObject(id: self.id, title: self.title, priority: self.priority.string, status: self.status.string)
    }
}

private extension TaskStatus {
    var string: String {
        switch self {
        case .planned: return "planned"
        case .completed: return "completed" }
    }
    init?(string: String) {
        switch string {
        case "planned": self = .planned
        case "completed": self = .completed
        default: return nil }
    }
}

private extension TaskPriority {
    var string: String {
        switch self {
        case .important: return "important"
        case .normal: return "normal" }
    }
    init?(string: String) {
        switch string {
        case "important": self = .important
        case "normal": self = .normal
        default: return nil }
    }
}
