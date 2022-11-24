//
//  TaskStorageDefaults.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 25.05.2022.
//

import UIKit

class TaskStorageDefaults {
    
    private let taskKey = "tasks"
    private let defaults = UserDefaults.standard
    
    func loadTasks() -> [Task] {
        let tasksData = defaults.array(forKey: taskKey) as? [Data]
        let tasks = tasksData?.compactMap { try? JSONDecoder().decode(Task.self, from: $0) }
        return tasks ?? []
    }
    
    func saveTasks(_ tasks: [Task]) {
        let tasksData = tasks.compactMap { try? JSONEncoder().encode($0) }
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
