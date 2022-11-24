//
//  TasksApi.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 22.11.2022.
//

import Alamofire
import Foundation

private struct ApiResponse: Decodable {

    struct Task: Decodable {
        var id: Int
        var todo: String
        var userId: Int
        var completed: Bool
    }
    
    var limit: Int
    var skip: Int
    var total: Int
    var todos: [Task]
}

private struct UpdatedTask: Decodable {
    var id: String
    var todo: String
    var completed: Bool
    var userId: Int
}

private struct DeletedTask: Decodable {
    var id: Int
    var todo: String
    var userId: Int
    var completed: Bool
    var isDeleted: Bool
    var deletedOn: String
}

class TaskApiClient: TaskRepositoryPr {
    
    private let userId = 1
    private let baseURL = "https://dummyjson.com/todos"
    
    func loadTasks() async throws -> [Task] {
        let url = "\(baseURL)/user/\(userId)"
        let apiResponse = try await AF.request(url).validate().serializingDecodable(ApiResponse.self).value
        return apiResponse.todos.map { $0.convertToTask }
    }
    
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) async throws -> Task {
        let url = "\(baseURL)/add"
        let params: [String: Any] = [
            "todo": title,
            "completed": status == .completed ? true : false,
            "userId": userId ]
        let headers: HTTPHeaders = [.contentType("application/json")]
        
        let addedTask = try await AF.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).validate().serializingDecodable(ApiResponse.Task.self).value
        
        var task = addedTask.convertToTask
        task.priority = priority
        return task
    }
    
    func updateTask(byId id: String, withTitle title: String) async throws {
        let url = "\(baseURL)/\(id)"
        let params: [String: Any] = ["todo": title]
        let headers: HTTPHeaders = [.contentType("application/json")]
        
        _ = try await AF.request(
            url,
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).validate().serializingDecodable(UpdatedTask.self).value
    }
    
    func updateTask(byId id: String, withStatus status: TaskStatus) async throws {
        let url = "\(baseURL)/\(id)"
        let params: [String: Any] = ["completed": true]
        let headers: HTTPHeaders = [.contentType("application/json")]
        
        _ = try await AF.request(
            url,
            method: .put,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).validate().serializingDecodable(UpdatedTask.self).value
    }
    
    func removeTask(byId id: String) async throws -> Bool {
        let url = "\(baseURL)/\(id)"
        let deletedTask = try await AF.request(
            url,
            method: .delete
        ).validate().serializingDecodable(DeletedTask.self).value
        
        return deletedTask.isDeleted
    }
}

private extension ApiResponse.Task {
    var convertToTask: Task {
        Task(id: String(self.id),
             title: self.todo,
             priority: .normal,
             status: self.completed ? .completed : .planned)
    }
}
