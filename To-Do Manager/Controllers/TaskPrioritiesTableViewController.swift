//
//  TaskPrioritiesTableViewController.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 18.11.2022.
//

import UIKit

protocol TaskPrioritiesViewControllerPr: NavigatableViewControllerPr {
    var selectedPriority: TaskPriority! { get set }
    var selectionСompletion: ((TaskPriority) -> Void)? { get set }
}

class TaskPrioritiesTableViewController: UITableViewController, TaskPrioritiesViewControllerPr {
    
    var selectedPriority: TaskPriority!
    var selectionСompletion: ((TaskPriority) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: TaskPriorityTableViewCell.reuseId, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TaskPriorityTableViewCell.reuseId)
    }
}

// MARK: - Table view data source

extension TaskPrioritiesTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TaskPriority.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskPriorityTableViewCell.reuseId, for: indexPath)
        let priority = TaskPriority.allCases[indexPath.row]
        
        if let cell = cell as? TaskPriorityTableViewCell {
            cell.titleLabel.text = priority.title
            cell.subtitleLabel.text = priority.subtitle
            cell.accessoryType = .checkmark
        }
        
        if priority == selectedPriority {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - Table view delegate

extension TaskPrioritiesTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPriority = TaskPriority.allCases[indexPath.row]
        tableView.reloadSections(IndexSet([0]), with: .automatic)
        
        selectionСompletion?(selectedPriority)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private extensions for UI

private extension TaskPriority {
    var title: String {
        switch self {
        case .important: return "Important"
        case .normal: return "Normal" }
    }
    
    var subtitle: String {
        switch self {
        case .normal: return "Normal priority task. This type of task has less priority than important"
        case .important: return "This type of task is the highest priority for execution. All important tasks are displayed at the very top of the task list"}
    }
}
