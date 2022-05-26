//
//  TaskCell.swift
//  To-Do Manager
//
//  Created by Евгений Бияк on 25.05.2022.
//

import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
