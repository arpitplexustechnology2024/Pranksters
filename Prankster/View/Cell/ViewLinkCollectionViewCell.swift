//
//  ViewLinkCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 01/12/24.
//

import UIKit

class ViewLinkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.imageView.layer.cornerRadius = 10
        self.imageView.clipsToBounds = true
        
    }
}
