//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 22.05.2022.
//

import UIKit

class TaskListTableViewController: UITableViewController {
    
    let taskManager: TaskManagerProtocool = TaskManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskManager.loadTasksFromStorage()
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return taskManager.countOfPriorityGroups
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // get preority from priorityWeights as index of array
        let priority = taskManager.priorityWeights[section]
        
        // return count of tasks with this priority
        return taskManager.tasks(withPriority: priority).count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // get preority from priorityWeights as index of array
        let priority = taskManager.priorityWeights[section]
        
        switch priority {
        case .normal:
            return "Normal priority"
        case .important:
            return "Important priority"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return getConfiguredTaskCell_constrains(for: indexPath)
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    // Configure Task Cell from prototype with tags
    private func getConfiguredTaskCell_constrains(for indexPath: IndexPath) -> UITableViewCell {
        // load prototype of cell by identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        
        // get preority from priorityWeights as index of array
        let priority = taskManager.priorityWeights[indexPath.section]
        
        // get current task by current row in table view
        let currentTask = taskManager.tasks(withPriority: priority, sortedBy: .status)[indexPath.row]
        
        // get view by tag
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        let titleLabel = cell.viewWithTag(2) as? UILabel
        
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        titleLabel?.text = currentTask.title
        
        // set text color and symbol
        if currentTask.status == .planned {
            titleLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            titleLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
    
        return cell
    }
    // Configure Custop Task Cell from prototype with stack 
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        // load prototype of cell by identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        
        // get preority from priorityWeights as index of array
        let priority = taskManager.priorityWeights[indexPath.section]
        
        // get current task by current row in table view
        let currentTask = taskManager.tasks(withPriority: priority, sortedBy: .status)[indexPath.row]
        
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        cell.title.text = currentTask.title
        
        // set text color and symbol
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
    
        return cell
        
    }
    
    // return the symbol for the corresponding task type
    private func getSymbolForTask(with status: TaskStatus) -> String {
        switch status {
        case .planned:
            return "\u{25CB}" // ○
        case .completed:
            return "\u{25C9}" // ◉
        }
    }
 
}

