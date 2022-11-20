//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 22.05.2022.
//

import UIKit

enum SortedBy { case status, priority }

protocol TaskListViewControllerPr: NavigatableViewControllerPr {
    var taskManger: TaskManagerPr! { get set }
}

protocol TaskEditViewControllerDelegate: AnyObject {
    func viewController(_ viewController: UIViewController, didTapSaveButtonWithTask task: Task)
}

class TaskListTableViewController: UITableViewController, TaskListViewControllerPr {
    
    var taskManger: TaskManagerPr!
    
    private var cellIdentifier = "TaskCell"
    private var tasksSortedBy: SortedBy = .status
    private var tasks: [Task] {
        taskManger.getTasks()
    }
    
    // MARK: - Life Cycle and overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        var sortViewController = ViewControllerFactory.taskSortingViewController
        
        sortViewController.currentSortOption = tasksSortedBy
        sortViewController.completionHandler = { [weak self] sortOption in
            self?.tasksSortedBy = sortOption
            self?.reloadDataWithAnimation()
        }
        
        sortViewController.present(inNavigationController: navigationController)
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var taskEditViewController = ViewControllerFactory.taskEditViewController
        taskEditViewController.delegate = self
        taskEditViewController.push(toNavigationController: navigationController)
    }
    
    // MARK: - Private methods
    
    private func numberOfSections() -> Int {
        switch tasksSortedBy {
        case .status: return TaskStatus.allCases.count
            case .priority: return TaskPriority.allCases.count }
    }
    
    private func numberOfRows(inSection section: Int) -> Int {
        switch tasksSortedBy {
        case .status:
            let status = TaskStatus(rawValue: section)
            return tasks.filter({ $0.status == status }).count
        case .priority:
            let priority = TaskPriority(rawValue: section)
            return tasks.filter({ $0.priority == priority }).count
        }
    }
    
    private func titleForHeader(inSection section: Int) -> String? {
        switch tasksSortedBy {
        case .status:
            return TaskStatus(rawValue: section)?.description
        case .priority:
            return TaskPriority(rawValue: section)?.description
        }
    }
    
    private func task(forIndexPath indexPath: IndexPath) -> Task {
        switch tasksSortedBy {
        case .status:
            let status = TaskStatus(rawValue: indexPath.section)
            var tasksWithStatus = tasks.filter({ $0.status == status })
            tasksWithStatus.sort { $0.priority.rawValue < $1.priority.rawValue }
            return tasksWithStatus[indexPath.row]
        case .priority:
            let priority = TaskPriority(rawValue: indexPath.section)
            var tasksWithPriority = tasks.filter({ $0.priority == priority })
            tasksWithPriority.sort { $0.status.rawValue < $1.status.rawValue }
            return tasksWithPriority[indexPath.row]
        }
    }
    
    private func reloadDataWithAnimation() {
        let indexSet = IndexSet(integersIn: 0..<tableView.numberOfSections)
        tableView.reloadSections(indexSet, with: .automatic)
    }
}

// MARK: - UITableViewDataSource

extension TaskListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let task = task(forIndexPath: indexPath)
        
        (cell as? TaskCell)?.configure(withTask: task)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeader(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

// MARK: - UITableViewDelegate

extension TaskListTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = task(forIndexPath: indexPath)
        guard task.status != .completed else { return }
        taskManger.update(taskId: task.id, withStatus: .completed)
        reloadDataWithAnimation()
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = task(forIndexPath: indexPath)
        
        let changeStatus = UIContextualAction(style: .normal, title: "Planned") { [weak self] _, _, _ in
            self?.taskManger.update(taskId: task.id, withStatus: .planned)
            self?.reloadDataWithAnimation()
        }
        
        let editTask = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, _ in
            var taskEditViewController = ViewControllerFactory.taskEditViewController
            taskEditViewController.task = task
            taskEditViewController.delegate = self
            taskEditViewController.push(toNavigationController: self?.navigationController)
        }
        
        if task.status == .planned {
            return UISwipeActionsConfiguration(actions: [editTask])
        } else {
            return UISwipeActionsConfiguration(actions: [changeStatus])
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = task(forIndexPath: indexPath)
        
        if case .delete = editingStyle {
            taskManger.remove(taskId: task.id)
            reloadDataWithAnimation()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceTask = task(forIndexPath: sourceIndexPath)
        let destinStatus = TaskStatus(rawValue: destinationIndexPath.section)
        let destinPriority = TaskPriority(rawValue: destinationIndexPath.section)
        
        switch tasksSortedBy {
        case .status:
            if let destinStatus, sourceTask.status != destinStatus {
                taskManger.update(taskId: sourceTask.id, withStatus: destinStatus)
            }
        case .priority:
            if let destinPriority, sourceTask.priority != destinPriority {
                taskManger.update(taskId: sourceTask.id, withPriority: destinPriority)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - TaskEditViewControllerDelegate

extension TaskListTableViewController: TaskEditViewControllerDelegate {
    
    func viewController(_ viewController: UIViewController, didTapSaveButtonWithTask task: Task) {
        if tasks.contains(where: { $0.id == task.id }) {
            taskManger.update(taskId: task.id, withTitle: task.title)
            taskManger.update(taskId: task.id, withStatus: task.status)
            taskManger.update(taskId: task.id, withPriority: task.priority)
        } else {
            taskManger.addTask(title: task.title, priority: task.priority, status: task.status)
        }
        
        viewController.navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
}

// MARK: - fileprivate extensions for UI

fileprivate extension TaskStatus {
    var description: String {
        switch self {
        case .planned: return "planned"
        case .completed: return "completed"}
    }
}

fileprivate extension TaskPriority {
    var description: String {
        switch self {
        case .normal: return "normal"
        case .important: return "important"}
    }
}
