//
//  CoverPageCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 10/10/24.
//

import UIKit
import SDWebImage

// MARK: - AddCoverPageCollectionCell
class AddCoverPageCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addCoverPageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false // Changed to false to allow shadow
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
}

// MARK: - CoverPage1CollectionCell
class CoverPage1CollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false // Changed to false to allow shadow
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 3 : 0
            layer.borderColor = isSelected ? UIColor.systemYellow.cgColor : nil
            
            if isSelected {
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOffset = CGSize(width: 0, height: 2)
                layer.shadowRadius = 4
                layer.shadowOpacity = 0.3
            } else {
                layer.shadowOpacity = 0
            }
        }
    }
}

// MARK: - CoverPage2CollectionCell
class CoverPage2CollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var premiumIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false // Changed to false to allow shadow
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
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
            premiumIconImageView.widthAnchor.constraint(equalToConstant: 40),
            premiumIconImageView.heightAnchor.constraint(equalToConstant: 40)
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
        let blurEffect = UIBlurEffect(style: .regular)
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
    
    override var isSelected: Bool {
        didSet {
            if !premiumIconImageView.isHidden {
                layer.borderWidth = 0
                layer.borderColor = nil
                layer.shadowOpacity = 0
            } else {
                layer.borderWidth = isSelected ? 3 : 0
                layer.borderColor = isSelected ? UIColor.systemYellow.cgColor : nil
                
                if isSelected {
                    layer.shadowColor = UIColor.black.cgColor
                    layer.shadowOffset = CGSize(width: 0, height: 2)
                    layer.shadowRadius = 4
                    layer.shadowOpacity = 0.3
                } else {
                    layer.shadowOpacity = 0
                }
            }
        }
    }
}

// MARK: - CoverPage2CollectionCell
class CoverPage3CollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var premiumIconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false // Changed to false to allow shadow
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
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
            premiumIconImageView.widthAnchor.constraint(equalToConstant: 40),
            premiumIconImageView.heightAnchor.constraint(equalToConstant: 40)
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
        let blurEffect = UIBlurEffect(style: .regular)
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
    
    override var isSelected: Bool {
        didSet {
            if !premiumIconImageView.isHidden {
                layer.borderWidth = 0
                layer.borderColor = nil
                layer.shadowOpacity = 0
            } else {
                layer.borderWidth = isSelected ? 3 : 0
                layer.borderColor = isSelected ? UIColor.systemYellow.cgColor : nil
                
                if isSelected {
                    layer.shadowColor = UIColor.black.cgColor
                    layer.shadowOffset = CGSize(width: 0, height: 2)
                    layer.shadowRadius = 4
                    layer.shadowOpacity = 0.3
                } else {
                    layer.shadowOpacity = 0
                }
            }
        }
    }
}
