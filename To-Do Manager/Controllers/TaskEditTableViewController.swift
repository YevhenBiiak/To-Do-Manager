//
//  TaskEditTableViewController.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 16.11.2022.
//

import UIKit

class TaskEditTableViewController: UITableViewController {
    
    @IBOutlet weak var taskTitleTextFiled: UITextField!
    @IBOutlet weak var taskPriorityLabel: UILabel!
    @IBOutlet weak var taskStatusSwitch: UISwitch!
    
    var task: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if task == nil {
            task = Task(title: "", priority: .important, status: .planned)
        }
        
        taskTitleTextFiled.text = task?.title
        taskPriorityLabel.text = task?.priority.description
        taskStatusSwitch.isOn = task?.status == .completed
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        task?.title = sender.text ?? ""
    }
    
    @IBAction func switchDidChangeState(_ sender: UISwitch) {
        task?.status = sender.isOn ? .completed : .planned
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let taskPrioritiesVC = segue.destination as? TaskPrioritiesTableViewController
        taskPrioritiesVC?.selectedPriority = task?.priority
        taskPrioritiesVC?.selectionСompletion = { [weak self] priority in
            self?.task?.priority = priority
            self?.taskPriorityLabel.text = priority.description
        }
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
        // if the task status row is selected
        if indexPath.row == 2 {
            taskStatusSwitch.setOn(!taskStatusSwitch.isOn, animated: true)
            switchDidChangeState(taskStatusSwitch)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
