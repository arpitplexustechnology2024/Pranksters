//
//  sideMenuCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 07/10/24.
//

import UIKit

class sideMenuCell: UITableViewCell {
    
    @IBOutlet weak var sideMenuIcon: UIImageView!
    @IBOutlet weak var sideMenuLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
