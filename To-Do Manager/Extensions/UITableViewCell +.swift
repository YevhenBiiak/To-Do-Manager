//
//  UITableViewCell +.swift
//  To-Do Manager
//
//  Created by Yevhen Biiak on 18.11.2022.
//

import UIKit

extension UITableViewCell {
    static var reuseId: String {
        String(describing: self)
    }
}
