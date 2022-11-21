//
//  RealmTaskStorage.swift
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

class RealmTaskStorage: TaskStoragePr {
    
    private let realm = try? Realm()
    
    func loadTasks() -> [Task] {
        let results = realm!.objects(TaskObject.self)
        let taskObjects = Array(results)
        
        return taskObjects.map { taskObject in
            Task(id: taskObject.id,
                 title: taskObject.title,
                 priority: TaskPriority(rawValue: taskObject.priority)!,
                 status: TaskStatus(rawValue: taskObject.status)!)
        }
    }
    
    func saveTasks(_ tasks: [Task]) {
        let tasksObjects = tasks.map { task in
            TaskObject(id: task.id,
                       title: task.title,
                       priority: task.priority.rawValue,
                       status: task.status.rawValue)
        }
        
        try? realm?.write {
            realm?.deleteAll()
            realm?.add(tasksObjects)
        }
    }
}
