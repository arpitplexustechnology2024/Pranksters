//
//  RealisticCoverAllCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/10/24.
//

import UIKit
import SDWebImage

class RealisticCoverAllCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var premiumIconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupPremiumIconImageView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupPremiumIconImageView()
        }
    
    private func setupPremiumIconImageView() {
            premiumIconImageView = UIImageView(image: UIImage(named: "premiumIcon"))
            premiumIconImageView.translatesAutoresizingMaskIntoConstraints = false
            premiumIconImageView.isHidden = true
            contentView.addSubview(premiumIconImageView)
            
            NSLayoutConstraint.activate([
                premiumIconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                premiumIconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                premiumIconImageView.widthAnchor.constraint(equalToConstant: 60),
                premiumIconImageView.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        
        func configure(with coverPageData: CoverPageData) {
            if let imageURL = URL(string: coverPageData.coverURL) {
                imageView.sd_setImage(with: imageURL, completed: nil)
            }
            
            if coverPageData.coverPremium {
                applyBlurEffect()
                premiumIconImageView.isHidden = false
            } else {
                removeBlurEffect()
                premiumIconImageView.isHidden = true
            }
        }

        func applyBlurEffect() {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = imageView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            imageView.addSubview(blurEffectView)
        }

        func removeBlurEffect() {
            imageView.subviews.forEach { subview in
                if let effectView = subview as? UIVisualEffectView {
                    effectView.removeFromSuperview()
                }
            }
        }
}
