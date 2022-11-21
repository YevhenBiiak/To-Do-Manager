//
//  Task.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 25.05.2022.
//

import Foundation

// priority types of task
enum TaskPriority: String, CaseIterable, Codable {
    case important
    case normal
}

// complition status of task
enum TaskStatus: String, CaseIterable, Codable {
    case planned
    case completed
}

struct Task: Codable {
    var id = UUID().uuidString
    var title: String
    var priority: TaskPriority
    var status: TaskStatus
}
