//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 22.05.2022.
//

import UIKit

typealias AsyncTask = _Concurrency.Task

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
        taskManger.tasks
    }
    
    // MARK: - Life Cycle and overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
        
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
    }
    
    @objc func refreshControlAction(refreshControl: UIRefreshControl) {
        loadTasks()
        refreshControl.endRefreshing()
    }
    
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        var sortViewController = ViewControllerFactory.taskSortingViewController
        
        sortViewController.currentSortOption = tasksSortedBy
        sortViewController.completionHandler = { [weak self] sortOption in
            self?.tasksSortedBy = sortOption
            self?.reloadData(animated: true)
        }
        
        if let viewController = sortViewController.uiViewController {
            present(viewController, animated: false)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var taskEditViewController = ViewControllerFactory.taskEditViewController
        taskEditViewController.delegate = self
        taskEditViewController.push(toNavigationController: navigationController)
    }
    
    // MARK: - Private methods
    
    private func loadTasks() {
        AsyncTask {
            do {
                try await taskManger.loadTasks()
                reloadData(animated: false)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func addTask(title: String, priority: TaskPriority, status: TaskStatus) {
        AsyncTask {
            do {
                try await taskManger.addTask(title: title, priority: priority, status: status)
                reloadData(animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateTask(byId id: String, withTitle title: String) {
        AsyncTask {
            do {
                try await taskManger.updateTask(byId: id, withTitle: title)
                reloadData(animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateTask(byId id: String, withStatus status: TaskStatus) {
        AsyncTask {
            do {
                try await taskManger.updateTask(byId: id, withStatus: status)
                reloadData(animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateTask(byId id: String, withPriority priority: TaskPriority) {
        AsyncTask {
            do {
                try await taskManger.updateTask(byId: id, withPriority: priority)
                reloadData(animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func removeTask(byId id: String) {
        AsyncTask {
            do {
                try await taskManger.removeTask(byId: id)
                reloadData(animated: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    private func reloadData(animated: Bool = false) {
        if animated {
            let indexSet = IndexSet(integersIn: 0..<tableView.numberOfSections)
            tableView.reloadSections(indexSet, with: .automatic)
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: - Helper methods for TableView DataSource
    
    private func numberOfSections() -> Int {
        switch tasksSortedBy {
        case .status: return TaskStatus.allCases.count
        case .priority: return TaskPriority.allCases.count }
    }
    
    private func numberOfRows(inSection section: Int) -> Int {
        switch tasksSortedBy {
        case .status:
            let status = TaskStatus(section: section)
            return tasks.filter({ $0.status == status }).count
        case .priority:
            let priority = TaskPriority(section: section)
            return tasks.filter({ $0.priority == priority }).count
        }
    }
    
    private func titleForHeader(inSection section: Int) -> String {
        switch tasksSortedBy {
        case .status:
            return TaskStatus(section: section).description
        case .priority:
            return TaskPriority(section: section).description
        }
    }
    
    private func task(forIndexPath indexPath: IndexPath) -> Task {
        switch tasksSortedBy {
        case .status:
            let status = TaskStatus(section: indexPath.section)
            var tasksWithStatus = tasks.filter({ $0.status == status })
            tasksWithStatus.sort { $0.priority.rawValue < $1.priority.rawValue }
            return tasksWithStatus[indexPath.row]
        case .priority:
            let priority = TaskPriority(section: indexPath.section)
            var tasksWithPriority = tasks.filter({ $0.priority == priority })
            tasksWithPriority.sort { $0.status.rawValue < $1.status.rawValue }
            return tasksWithPriority[indexPath.row]
        }
    }
}

// MARK: - UITableViewDataSource

extension TaskListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(inSection: section) > 0 ? numberOfRows(inSection: section) : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        guard let cell = cell as? TaskCell else { return cell }
        
        if numberOfRows(inSection: indexPath.section) > 0 {
            let task = task(forIndexPath: indexPath)
            cell.configure(withTask: task)
        } else {
            cell.configure(withText: "No Tasks")
        }
        
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
        guard numberOfRows(inSection: indexPath.section) > 0 else { return }
        
        let task = task(forIndexPath: indexPath)
        guard task.status != .completed else { return }
        updateTask(byId: task.id, withStatus: .completed)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard numberOfRows(inSection: indexPath.section) > 0 else { return nil }
        
        let task = task(forIndexPath: indexPath)
        
        let changeStatus = UIContextualAction(style: .normal, title: "Planned") { [weak self] _, _, _ in
            self?.updateTask(byId: task.id, withStatus: .planned)
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return numberOfRows(inSection: indexPath.section) > 0 ? .delete : .none
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return numberOfRows(inSection: indexPath.section) > 0 ? true : false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = task(forIndexPath: indexPath)
        
        if case .delete = editingStyle {
            removeTask(byId: task.id)
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let sourceTask = task(forIndexPath: sourceIndexPath)
        let destinStatus = TaskStatus(section: destinationIndexPath.section)
        let destinPriority = TaskPriority(section: destinationIndexPath.section)
        
        switch tasksSortedBy {
        case .status where sourceTask.status != destinStatus:
            updateTask(byId: sourceTask.id, withStatus: destinStatus)
        case .priority where sourceTask.priority != destinPriority:
            updateTask(byId: sourceTask.id, withPriority: destinPriority)
        default: return }
        
        reloadData()
    }
}

// MARK: - TaskEditViewControllerDelegate

extension TaskListTableViewController: TaskEditViewControllerDelegate {
    
    func viewController(_ viewController: UIViewController, didTapSaveButtonWithTask task: Task) {
        if tasks.contains(where: { $0.id == task.id }) {
            // if it was an edit operation
            updateTask(byId: task.id, withTitle: task.title)
            updateTask(byId: task.id, withStatus: task.status)
            updateTask(byId: task.id, withPriority: task.priority)
        } else {
            // else it was an create operation
            addTask(title: task.title, priority: task.priority, status: task.status)
        }
        
        viewController.navigationController?.popViewController(animated: true)
        reloadData()
    }
}

// MARK: - fileprivate extensions for UI

fileprivate extension TaskStatus {
    init(section: Int) {
        switch section {
        case 0: self = .planned
        case 1: self = .completed
        default: fatalError() }
    }
    
    var description: String { rawValue }
}

fileprivate extension TaskPriority {
    init(section: Int) {
        switch section {
        case 0: self = .normal
        case 1: self = .important
        default: fatalError() }
    }
    
    var description: String { rawValue }
}
