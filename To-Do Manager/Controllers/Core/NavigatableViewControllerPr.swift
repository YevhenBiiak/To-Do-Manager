//
//  NavigatableViewControllerPr.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 20.11.2022.
//

import UIKit

protocol NavigatableViewControllerPr {}

extension NavigatableViewControllerPr {
    
    func push(toNavigationController navigationController: UINavigationController?) {
        if let viewController = self as? UIViewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func popFromNavigationController() {
        if let viewController = self as? UIViewController {
            viewController.navigationController?.popViewController(animated: true)
        }
    }
    
    func present(inNavigationController navigationController: UINavigationController?) {
        if let viewController = self as? UIViewController {
            navigationController?.topViewController?.present(viewController, animated: true)
        }
    }
}
