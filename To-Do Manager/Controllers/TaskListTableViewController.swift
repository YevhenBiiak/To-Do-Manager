//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 22.05.2022.
//

import UIKit

typealias AsyncTask = _Concurrency.Task

protocol TaskListViewControllerPr: AnyObject, NavigatableViewControllerPr {
    var presenter: TaskListPresenterPr! { get set }
    func display(tasks: [[Task]])
    func displayError(title: String?, message: String?)
}

class TaskListTableViewController: UITableViewController, TaskListViewControllerPr {
    
    var presenter: TaskListPresenterPr!
        
    private var tasks: [[Task]] = []
    
    // MARK: - Life Cycle and overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        
        presenter.viewDidLoad()
    }
    
    func display(tasks: [[Task]]) {
        DispatchQueue.main.async {
            self.tasks = tasks
            self.reloadData(animated: false)
        }
    }
    
    func displayError(title: String?, message: String?) {
        DispatchQueue.main.async {
            self.showAlert(title: title, message: message)
        }
    }
    
    // MARK: - Private Actions
    
    @objc private func refreshControlAction(refreshControl: UIRefreshControl) {
        presenter.didRefreshTable()
        refreshControl.endRefreshing()
    }
    
    @IBAction private func sortButtonTapped(_ sender: UIBarButtonItem) {
        presenter.didTapSortButton()
    }
    
    @IBAction private func addButtonTapped(_ sender: UIBarButtonItem) {
        presenter.didTapAddButton()
    }

    private func reloadData(animated: Bool = false) {
        if animated {
            let indexSet = IndexSet(integersIn: 0..<self.tableView.numberOfSections)
            self.tableView.reloadSections(indexSet, with: .automatic)
        } else {
            self.tableView.reloadData()
        }
    }
    
    private func numberOfTasks(inSection section: Int) -> Int {
        tasks[section].count
    }
}

// MARK: - UITableViewDataSource

extension TaskListTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfTasks = numberOfTasks(inSection: section)
        return numberOfTasks > 0 ? numberOfTasks : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseId, for: indexPath) as? TaskCell
        
        if numberOfTasks(inSection: indexPath.section) > 0 {
            let task = tasks[indexPath.section][indexPath.row]
            cell?.configure(withTask: task)
        } else {
            cell?.configureNoTasksCell()
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        presenter.title(forSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

// MARK: - UITableViewDelegate

extension TaskListTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard numberOfTasks(inSection: indexPath.section) > 0 else { return }
        
        let task = tasks[indexPath.section][indexPath.row]
        presenter.didSelectTask(task)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard numberOfTasks(inSection: indexPath.section) > 0 else { return nil }
        
        let task = tasks[indexPath.section][indexPath.row]
        var changeStatus: UIContextualAction
        
        if task.status == .planned {
            changeStatus = UIContextualAction(style: .normal, title: "Completed") { [weak self] _, _, _ in
                self?.presenter.didChangeStatus(forTask: task, with: .completed)
            }
            changeStatus.backgroundColor = .systemGreen
        } else {
            changeStatus = UIContextualAction(style: .normal, title: "Planned") { [weak self] _, _, _ in
                self?.presenter.didChangeStatus(forTask: task, with: .planned)
            }
            changeStatus.backgroundColor = .systemBlue
        }
        
        return UISwipeActionsConfiguration(actions: [changeStatus])
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return numberOfTasks(inSection: indexPath.section) > 0 ? .delete : .none
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return numberOfTasks(inSection: indexPath.section) > 0 ? true : false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.section][indexPath.row]
        if case .delete = editingStyle { presenter.didRemoveTask(task) }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath.section != destinationIndexPath.section else { return }
        
        let task = tasks[sourceIndexPath.section][sourceIndexPath.row]
        presenter.didMoveTask(task, toSection: destinationIndexPath.section)
    }
}
