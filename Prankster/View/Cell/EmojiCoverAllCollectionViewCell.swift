//
//  EmojiCoverAllCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 10/10/24.
//

import UIKit
import SDWebImage

protocol EmojiCoverAllCollectionViewCellDelegate: AnyObject {
    func didTapDoneButton(for coverPageData: CoverPageData)
}

class EmojiCoverAllCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var imageName: UILabel!
    @IBOutlet weak var visualEffectView: UIView!
    weak var delegate: EmojiCoverAllCollectionViewCellDelegate?
    private var coverPageData: CoverPageData?
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
    
    func configure(with coverPageData: CoverPageData) {
        self.coverPageData = coverPageData
        let displayName = coverPageData.coverName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "---" : coverPageData.coverName
        self.imageName.text = displayName
        if let imageURL = URL(string: coverPageData.coverURL) {
            blurredImageView.sd_setImage(with: imageURL)
            imageView.sd_setImage(with: imageURL) { [weak self] image, _, _, _ in
                if coverPageData.coverPremium && !PremiumManager.shared.isContentUnlocked(itemID: coverPageData.itemID) {
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
