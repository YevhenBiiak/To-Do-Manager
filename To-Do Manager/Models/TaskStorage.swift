//
//  TaskStorage.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 25.05.2022.
//

import UIKit

protocol TaskStoragePr {
    func loadTasks() -> [Task]
    func saveTasks(_ tasks: [Task])
}

class TaskStorage: TaskStoragePr {
    
    private let testTasks: [Task] = [
        Task(title: "Купить хлеб", priority: .normal, status: .planned),
        Task(title: "Помыть кота", priority: .important, status: .planned),
        Task(title: "Отдать долг Арнольду", priority: .normal, status: .completed),
        Task(title: "Купить новый пылесос", priority: .normal, status: .completed),
        Task(title: "Подарить цветы супруге", priority: .important, status: .planned),
        Task(title: "Позвонить родителям", priority: .important, status: .completed),
        Task(title: "Пригласить на вечеринку Дольфа, Джеки, Леонардо, Уилла", priority: .important, status: .planned)]
    
    func loadTasks() -> [Task] {
        return testTasks
    }
    
    func saveTasks(_ tasks: [Task]) {
        
    }
}
