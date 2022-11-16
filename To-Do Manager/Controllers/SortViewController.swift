//
//  SortViewController.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 16.11.2022.
//

import UIKit

class SortViewController: UIViewController {
    
    @IBOutlet weak var sortView: UIView! {
        didSet { sortView.layer.cornerRadius = 20 }
    }
    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var priorityStackView: UIStackView!
    
    var currentSortOption: SortedBy!
    var completionHandler: ((SortedBy) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        addGestureRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startShowAnimation()
    }
    
    @objc private func viewDidTap() {
        startHideAnimation()
    }
    
    @objc private func statusSortOptionTapped() {
        currentSortOption = .status
        completionHandler?(currentSortOption)
        startHideAnimation()
        updateUI()
    }
    
    @objc private func prioritySortOptionTapped() {
        currentSortOption = .priority
        completionHandler?(currentSortOption)
        startHideAnimation()
        updateUI()
    }
    
    // MARK: - Private methods
    
    private func updateUI() {
        switch currentSortOption {
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
            UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
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

}
