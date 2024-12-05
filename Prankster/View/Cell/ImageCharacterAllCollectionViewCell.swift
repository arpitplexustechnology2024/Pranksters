//
//  ImageCharacterAllCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 19/10/24.
//

import UIKit
import SDWebImage

protocol ImageCharacterAllCollectionViewCellDelegate: AnyObject {
    func didTapDoneButton(for categoryAllData: CategoryAllData)
}

class ImageCharacterAllCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var imageName: UILabel!
    @IBOutlet weak var visualEffectView: UIView!
    weak var delegate: ImageCharacterAllCollectionViewCellDelegate?
    private var coverPageData: CategoryAllData?
    private var blurredImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
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
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with coverPageData: CategoryAllData) {
        self.coverPageData = coverPageData
        let displayName = coverPageData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "---" : coverPageData.name
        self.imageName.text = displayName
        if let imageURL = URL(string: coverPageData.image) {
            blurredImageView.sd_setImage(with: imageURL)
            imageView.sd_setImage(with: imageURL) { [weak self] image, _, _, _ in
                if coverPageData.premium && !PremiumManager.shared.isContentUnlocked(itemID: coverPageData.itemID) {
                    self?.DoneButton.setImage(UIImage(named: "PremiumButton"), for: .normal)
                } else {
                    self?.DoneButton.setImage(UIImage(named: "selectButton"), for: .normal)
                }
            }
        }
    }
    
    @objc private func doneButtonTapped() {
        if let coverPageData = coverPageData {
            delegate?.didTapDoneButton(for: coverPageData)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurredImageView.frame = contentView.bounds
    }
}
