//
//  TaskEditTableViewController.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 16.11.2022.
//

import UIKit

protocol TaskEditViewControllerPr: NavigatableViewControllerPr {
    var delegate: TaskEditViewControllerDelegate? { get set }
    var task: Task? { get set }
}

class TaskEditTableViewController: UITableViewController, TaskEditViewControllerPr {
    
    @IBOutlet weak var taskTitleTextFiled: UITextField!
    @IBOutlet weak var taskPriorityLabel: UILabel!
    @IBOutlet weak var taskStatusSwitch: UISwitch!
    
    var task: Task?
    var delegate: TaskEditViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if task == nil {
            task = Task(title: "", priority: .important, status: .planned)
        }
        
        taskTitleTextFiled.text = task?.title
        taskPriorityLabel.text = task?.priority.description
        taskStatusSwitch.isOn = task?.status == .completed
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let task {
            delegate?.viewController(self, didTapSaveButtonWithTask: task)
        }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        task?.title = sender.text ?? ""
    }
    
    @IBAction func switchDidChangeState(_ sender: UISwitch) {
        task?.status = sender.isOn ? .completed : .planned
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1: // task priority row selected
            presentTaskPrioritiesViewController()
        case 2: // task status row selected
            toggleTaskStatus()
        default: break }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func toggleTaskStatus() {
        taskStatusSwitch.setOn(!taskStatusSwitch.isOn, animated: true)
        switchDidChangeState(taskStatusSwitch)
    }
    
    private func presentTaskPrioritiesViewController() {
        var taskPrioritiesVC = ViewControllerFactory.taskPrioritiesViewController
        
        taskPrioritiesVC.selectedPriority = task?.priority
        taskPrioritiesVC.selectionСompletion = { [weak self] priority in
            self?.task?.priority = priority
            self?.taskPriorityLabel.text = priority.description
        }
        
        taskPrioritiesVC.push(toNavigationController: navigationController)
    }
    
}

// MARK: - fileprivate extensions for UI

fileprivate extension TaskPriority {
    var description: String {
        switch self {
        case .normal: return "normal"
        case .important: return "important"}
    }
}
