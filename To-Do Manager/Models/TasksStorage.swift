//
//  TasksStorage.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 25.05.2022.
//

import UIKit

protocol TaskStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}



class TaskStorage: TaskStorageProtocol {
    
    private let testTasks: [TaskProtocol] = [
        Task(title: "Купить хлеб", priority: .normal, status: .planned),
        Task(title: "Помыть кота", priority: .important, status: .planned),
        Task(title: "Отдать долг Арнольду", priority: .important, status: .completed),
        Task(title: "Купить новый пылесос", priority: .normal, status: .completed),
        Task(title: "Подарить цветы супруге", priority: .important, status: .planned),
        Task(title: "Позвонить родителям", priority: .important, status: .planned)]
    
    func loadTasks() -> [TaskProtocol] {
        return testTasks
    }
    
    func saveTasks(_ tasks: [TaskProtocol]) {
        
    }
}
