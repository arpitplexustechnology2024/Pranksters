//
//  MoreAppCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 08/10/24.
//

import UIKit
import SDWebImage

class MoreAppCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var More_App_LogoImage: UIImageView!
    @IBOutlet weak var More_App_Label: UILabel!
    @IBOutlet weak var More_App_DownloadButton: UIButton!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            imageViewHeightConstraint.constant = 174
        } else {
            imageViewHeightConstraint.constant = 119
        }
        
        layoutIfNeeded()
        
        self.contentView.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.moreApp : UIColor.moreApp
        }
        self.layer.shadowColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        }.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4.0
        self.layer.masksToBounds = false
        
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        self.More_App_LogoImage.layer.cornerRadius = 16
        self.More_App_LogoImage.clipsToBounds = true
        
        self.More_App_DownloadButton.layer.cornerRadius = More_App_DownloadButton.layer.frame.height / 2
        self.More_App_DownloadButton.clipsToBounds = true
    }
    
    func configure(with moreData: MoreData) {
        More_App_Label.text = moreData.appName
        
        if let logoURL = URL(string: moreData.logo) {
            More_App_LogoImage.sd_setImage(with: logoURL, placeholderImage: UIImage(named: "Pranksters"))
        } else {
            More_App_LogoImage.image = UIImage(named: "Pranksters")
        }
    }
}
