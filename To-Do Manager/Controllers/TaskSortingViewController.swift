//
//  TaskSortingViewController.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 16.11.2022.
//

import UIKit

protocol TaskSortingViewControllerPr: NavigatableViewControllerPr {
    var currentSortedBy: SortedBy! { get set }
    var completionHandler: ((SortedBy) -> Void)? { get set }
}

class TaskSortingViewController: UIViewController, TaskSortingViewControllerPr {
    
    @IBOutlet weak var sortView: UIView! {
        didSet { sortView.layer.cornerRadius = 20 }
    }
    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var priorityStackView: UIStackView!
    
    var currentSortedBy: SortedBy!
    var completionHandler: ((SortedBy) -> Void)?
    
    // MARK: - Life Cycle and overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        addGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startShowAnimation()
    }
    
    // MARK: - Private methods
    
    private func updateUI() {
        switch currentSortedBy {
        case .status:
            priorityStackView.arrangedSubviews.first?.alpha = 0
            statusStackView.arrangedSubviews.first?.alpha = 1
        case .priority:
            statusStackView.arrangedSubviews.first?.alpha = 0
            priorityStackView.arrangedSubviews.first?.alpha = 1
        default:
            statusStackView.arrangedSubviews.first?.alpha = 0
            priorityStackView.arrangedSubviews.first?.alpha = 0
        }
    }
    
    private func addGestureRecognizers() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapOutside))
        )
        
        let statusTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(statusSortOptionTapped))
        let priorityTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(prioritySortOptionTapped))
        
        statusStackView.addGestureRecognizer(statusTapRecognizer)
        priorityStackView.addGestureRecognizer(priorityTapRecognizer)
    }
    
    private func startShowAnimation() {
        view.backgroundColor = .black.withAlphaComponent(0.0)
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = .black.withAlphaComponent(0.5)
        }
    }
    
    private func startHideAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .black.withAlphaComponent(0.0)
            self.view.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
    
    @objc private func didTapOutside() {
        startHideAnimation()
    }
    
    @objc private func statusSortOptionTapped() {
        currentSortedBy = .status
        completionHandler?(currentSortedBy)
        startHideAnimation()
        updateUI()
    }
    
    @objc private func prioritySortOptionTapped() {
        currentSortedBy = .priority
        completionHandler?(currentSortedBy)
        startHideAnimation()
        updateUI()
    }
}
