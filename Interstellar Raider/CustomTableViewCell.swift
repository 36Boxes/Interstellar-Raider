//
//  CustomTableViewCell.swift
//  Interstellar Raider
//
//  Created by Josh Manik on 02/06/2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var score: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
