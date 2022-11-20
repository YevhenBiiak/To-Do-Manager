//
//  ViewControllerFactory.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 20.11.2022.
//

import UIKit

class ViewControllerFactory {
    
    enum ViewControllerType {
        case taskList
        case taskEdit
        case taskPriority
        case taskSorting
        
        var identifier: String {
            switch self {
            case .taskList:     return "TaskListTableViewController"
            case .taskEdit:     return "TaskEditTableViewController"
            case .taskPriority: return "TaskPrioritiesTableViewController"
            case .taskSorting:  return "TaskSortingViewController" }
        }
    }
    
    static func getViewController(type: ViewControllerType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: type.identifier)
    }
    
    static var taskListViewController: TaskListViewControllerPr {
        let viewController = getViewController(type: .taskList)
        return (viewController as? TaskListViewControllerPr)!
    }
    
    static var taskEditViewController: TaskEditViewControllerPr {
        let viewController = getViewController(type: .taskEdit)
        return (viewController as? TaskEditViewControllerPr)!
    }
    
    static var taskPrioritiesViewController: TaskPrioritiesViewControllerPr {
        let viewController = getViewController(type: .taskPriority)
        return (viewController as? TaskPrioritiesViewControllerPr)!
    }
    
    static var taskSortingViewController: TaskSortingViewControllerPr {
        let viewController = getViewController(type: .taskSorting)
        return (viewController as? TaskSortingViewControllerPr)!
    }
}
