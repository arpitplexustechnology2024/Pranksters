//
//  CustomCoverAllCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 19/11/24.
//

import UIKit
import SDWebImage

protocol CustomCoverAllCollectionViewCellDelegate: AnyObject {
    func didTapDoneButton(with image: UIImage)
}

class CustomCoverAllCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var visualEffectView: UIView!
    weak var delegate: CustomCoverAllCollectionViewCellDelegate?
    var blurredImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 20
        layer.masksToBounds = false
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        blurredImageView = UIImageView()
        blurredImageView.frame = contentView.bounds
        blurredImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredImageView.contentMode = .scaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurredImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredImageView.addSubview(blurEffectView)
        
        visualEffectView.layer.cornerRadius = 20
        visualEffectView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        visualEffectView.layer.masksToBounds = true
        
        DoneButton.layer.shadowColor = UIColor.black.cgColor
        DoneButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        DoneButton.layer.shadowRadius = 3.24
        DoneButton.layer.shadowOpacity = 0.3
        DoneButton.layer.masksToBounds = false
        
        contentView.insertSubview(blurredImageView, at: 0)

        DoneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        self.DoneButton.setImage(UIImage(named: "selectButton"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func doneButtonTapped() {
        if let image = imageView.image {
            delegate?.didTapDoneButton(with: image)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurredImageView.frame = contentView.bounds
    }
}
