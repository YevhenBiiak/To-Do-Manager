//
//  TasksManager.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 26.05.2022.
//



protocol TaskManagerProtocool {
    var statusWeights:   [TaskStatus]   { get set }
    var priorityWeights: [TaskPriority] { get set }
    var countOfPriorityGroups: Int { get }
    
    func loadTasksFromStorage()
    func tasks(withPriority priority: TaskPriority) -> [TaskProtocol]
    func tasks(withPriority priority: TaskPriority, sortedBy order: SortOrder) -> [TaskProtocol]
    func addTask(title: String, priority: TaskPriority, status: TaskStatus)
}


enum SortOrder {case title, status, priority}



class TaskManager: TaskManagerProtocool {
    private var tasks: [TaskProtocol] = []
    
    private var taskStorage: TaskStorageProtocol = TaskStorage()
    
    var statusWeights:   [TaskStatus]   = [.planned, .completed]
    var priorityWeights: [TaskPriority] = [.important, .normal]
    
    var countOfPriorityGroups: Int { Set(tasks.map{$0.priority}).count }
    
    
    
    func loadTasksFromStorage() {
        let tasks = taskStorage.loadTasks()
        self.tasks = sorted(tasks, by: .title)
    }
    
    func tasks(withPriority priority: TaskPriority) -> [TaskProtocol] {
        tasks.filter{$0.priority == priority}
    }
    
    func tasks(withPriority priority: TaskPriority, sortedBy order: SortOrder) -> [TaskProtocol] {
        let tasks = tasks(withPriority: priority)
        return sorted(tasks, by: order)
    }
    
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) {
        tasks.append(Task(title: title, priority: priority, status: status))
    }
    
    
    
    private func sorted(_ tasks: [TaskProtocol], by order: SortOrder) -> [TaskProtocol] {
        return tasks.sorted {
            var weight0, weight1: Int
            switch order {
            case .title:
                return $0.title < $1.title
            case .status:
                weight0 = statusWeights.firstIndex(of: $0.status) ?? 0
                weight1 = statusWeights.firstIndex(of: $1.status) ?? 0
            case .priority:
                weight0 = priorityWeights.firstIndex(of: $0.priority) ?? 0
                weight1 = priorityWeights.firstIndex(of: $1.priority) ?? 0
            }
            guard weight0 != weight1 else { return $0.title < $1.title }
            return weight0 < weight1
        }
    }
}
