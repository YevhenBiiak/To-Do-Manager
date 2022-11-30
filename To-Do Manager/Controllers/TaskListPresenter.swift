//
//  TaskListPresenter.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 28.11.2022.
//

import Foundation

protocol TaskManagerPr {
    var tasks: [Task] { get }
    func loadTasks() async throws
    func addTask(title: String, priority: TaskPriority, status: TaskStatus) async throws
    func updateTask(byId id: String, withTitle title: String) async throws
    func updateTask(byId id: String, withStatus status: TaskStatus) async throws
    func updateTask(byId id: String, withPriority priority: TaskPriority) async throws
    func removeTask(byId id: String) async throws
}

protocol TaskListPresenterPr {
    func viewDidLoad()
    func didRefreshTable()
    func didTapAddButton()
    func didTapSortButton()
    func didSelectTask(_ task: Task)
    func didRemoveTask(_ task: Task)
    func didMoveTask(_ task: Task, toSection section: Int)
    func didChangeStatus(forTask task: Task, with status: TaskStatus)
    func title(forSection section: Int) -> String?
    
//    func userDidChange(sortOption: SortedBy)
    
//    func userDidTapSaveButton(withTask task: Task)
}

enum SortedBy { case status, priority }

class TaskListPresenter: TaskListPresenterPr {
    
    private weak var taskListView: TaskListViewControllerPr?
    private let taskManger: TaskManagerPr!
    
    private var sortedBy: SortedBy = .status
    private var tasks: [Task] { taskManger.tasks }
    
    init(view: TaskListViewControllerPr, taskManger: TaskManagerPr!) {
        self.taskListView = view
        self.taskManger = taskManger
    }
    
    func viewDidLoad() {
        loadTasks()
    }
    
    func didRefreshTable() {
        loadTasks()
    }
    
    func didTapAddButton() {
        var taskEditViewController = ViewControllerFactory.taskEditViewController
        taskEditViewController.delegate = self
        taskEditViewController.push(toNavigationController: taskListView?.uiViewController?.navigationController)
    }
    
    func didTapSortButton() {
        var sortViewController = ViewControllerFactory.taskSortingViewController
        
        sortViewController.currentSortedBy = sortedBy
        sortViewController.completionHandler = { [weak self] sortedBy in
            guard let self = self else { return }
            self.sortedBy = sortedBy
            self.taskListView?.display(tasks: self.sortedTasks())
        }
        
        if let sortViewController = sortViewController.uiViewController {
            taskListView?.uiViewController?.present(sortViewController, animated: false)
        }
    }
    
    func didSelectTask(_ task: Task) {
        var taskEditViewController = ViewControllerFactory.taskEditViewController
        taskEditViewController.task = task
        taskEditViewController.delegate = self
        taskEditViewController.push(toNavigationController: taskListView?.uiViewController?.navigationController)
    }
    
    func didRemoveTask(_ task: Task) {
        removeTask(byId: task.id)
    }
    
    func didMoveTask(_ task: Task, toSection section: Int) {
        let destinStatus = TaskStatus(section: section)
        let destinPriority = TaskPriority(section: section)
        
        switch sortedBy {
        case .status:   updateTask(byId: task.id, status: destinStatus)
        case .priority: updateTask(byId: task.id, priority: destinPriority) }
    }
    
    func didChangeStatus(forTask task: Task, with status: TaskStatus) {
        updateTask(byId: task.id, status: status)
    }
        
    func title(forSection section: Int) -> String? {
        switch sortedBy {
        case .status:   return TaskStatus(section: section)?.description
        case .priority: return TaskPriority(section: section)?.description }
    }
    
    // MARK: - Private methods
    
    private func sortedTasks() -> [[Task]] {
        switch sortedBy {
        case .status:
            var sortedTasks: [[Task]] = []
            for status in TaskStatus.allCases {
                var tasksWithStatus = tasks.filter({ $0.status == status })
                tasksWithStatus.sort { $0.priority.rawValue < $1.priority.rawValue }
                sortedTasks.append(tasksWithStatus)
            }
            return sortedTasks
        case .priority:
            var sortedTasks: [[Task]] = []
            for priority in TaskPriority.allCases {
                var tasksWithPriority = tasks.filter({ $0.priority == priority })
                tasksWithPriority.sort { $0.status.rawValue < $1.status.rawValue }
                sortedTasks.append(tasksWithPriority)
            }
            return sortedTasks
        }
    }
    
    private func loadTasks() {
        AsyncTask {
            do {
                try await taskManger.loadTasks()
                taskListView?.display(tasks: sortedTasks())
            } catch {
                taskListView?.displayError(title: error.localizedDescription, message: nil)
                // reloadData(animated: true)
            }
        }
    }
    
    private func addTask(title: String, priority: TaskPriority, status: TaskStatus) {
        AsyncTask {
            do {
                try await taskManger.addTask(title: title, priority: priority, status: status)
                taskListView?.display(tasks: sortedTasks())
            } catch {
                taskListView?.displayError(title: error.localizedDescription, message: nil)
            }
        }
    }
    
    private func updateTask(byId id: String, title: String? = nil, status: TaskStatus? = nil, priority: TaskPriority? = nil) {
        AsyncTask {
            do {
                if let title { try await taskManger.updateTask(byId: id, withTitle: title) }
                if let status { try await taskManger.updateTask(byId: id, withStatus: status) }
                if let priority { try await taskManger.updateTask(byId: id, withPriority: priority) }
                
                taskListView?.display(tasks: sortedTasks())
            } catch {
                taskListView?.displayError(title: error.localizedDescription, message: nil)
            }
        }
    }
    
    private func removeTask(byId id: String) {
        AsyncTask {
            do {
                try await taskManger.removeTask(byId: id)
                taskListView?.display(tasks: sortedTasks())
            } catch {
                taskListView?.displayError(title: error.localizedDescription, message: nil)
            }
        }
    }
}

// MARK: - TaskEditViewControllerDelegate

extension TaskListPresenter: TaskEditViewControllerDelegate {

    func viewController(_ viewController: TaskEditViewControllerPr, didTapSaveButtonWithTask task: Task) {
        if tasks.contains(where: { $0.id == task.id }) {
            // if it was an edit operation
            updateTask(byId: task.id, title: task.title, status: task.status, priority: task.priority)
        } else {
            // else it was an create operation
            addTask(title: task.title, priority: task.priority, status: task.status)
        }
        
        viewController.popFromNavigationController()
    }
}

// MARK: - Private extensions for UI

private extension TaskStatus {
    init?(section: Int) {
        self.init(rawValue: section)
    }

    var description: String {
        switch self {
        case .planned: return "planned"
        case .completed: return "completed" }
    }
}

private extension TaskPriority {
    init?(section: Int) {
        self.init(rawValue: section)
    }
    
    var description: String {
        switch self {
        case .important: return "important"
        case .normal: return "normal" }
    }
}
