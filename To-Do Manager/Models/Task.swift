//
//  Task.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 25.05.2022.
//



// priority types of task
enum TaskPriority {
    case normal
    case important
}

// complition status of task
enum TaskStatus {
    case planned
    case completed
}

// task protocol
protocol TaskProtocol {
    var title:    String       { get set }
    var priority: TaskPriority { get set }
    var status:   TaskStatus   { get set }
}


struct Task: TaskProtocol {
    var title: String
    var priority: TaskPriority
    var status: TaskStatus
}
