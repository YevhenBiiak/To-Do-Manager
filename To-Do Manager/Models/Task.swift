//
//  Task.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 25.05.2022.
//

import Foundation

// priority types of task
enum TaskPriority: Int, CaseIterable {
    case important
    case normal
}

// complition status of task
enum TaskStatus: Int, CaseIterable {
    case planned
    case completed
}

struct Task {
    let id = UUID().uuidString
    var title: String
    var priority: TaskPriority
    var status: TaskStatus
}
