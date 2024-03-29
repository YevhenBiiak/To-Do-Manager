//
//  Task.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 25.05.2022.
//

import Foundation

// priority types of task
enum TaskPriority: Int, CaseIterable, Codable {
    case important
    case normal
}

// completion status of task
enum TaskStatus: Int, CaseIterable, Codable {
    case planned
    case completed
}

struct Task: Codable {
    var id = UUID().uuidString
    var title: String
    var priority: TaskPriority
    var status: TaskStatus
}
