//
//  CoverPageCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 10/10/24.
//

import UIKit
import SDWebImage
import CoreImage

// MARK: - AddCoverPageCollectionCell
class AddCoverPageCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addCoverPageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false 
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            
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

// MARK: - CoverPage1CollectionCell
class CoverPage1CollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 3 : 0
            layer.borderColor = isSelected ? UIColor.icon.cgColor : nil
            
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
    
    private var originalImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false
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
            imageView.sd_setImage(with: imageURL) { [weak self] image, _, _, _ in
                self?.originalImage = image
                
                if coverPageData.coverPremium && !PremiumManager.shared.isContentUnlocked(itemID: coverPageData.itemID) {
                    self?.applyBlurEffect()
                    self?.premiumIconImageView.isHidden = false
                } else {
                    self?.removeBlurEffect()
                    self?.premiumIconImageView.isHidden = true
                }
            }
        }
    }
    
    func applyBlurEffect() {
        guard let image = originalImage else { return }
        
        let context = CIContext()
        guard let ciImage = CIImage(image: image) else { return }
        
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(50.0, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return }
        
        imageView.image = UIImage(cgImage: cgImage)
    }
    
    func removeBlurEffect() {
        imageView.image = originalImage
    }
    
    override var isSelected: Bool {
        didSet {
            if !premiumIconImageView.isHidden {
                layer.borderWidth = 0
                layer.borderColor = nil
                layer.shadowOpacity = 0
            } else {
                layer.borderWidth = isSelected ? 3 : 0
                layer.borderColor = isSelected ? UIColor.icon.cgColor : nil
                
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


// MARK: - CoverPage3CollectionCell
class CoverPage3CollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var premiumIconImageView: UIImageView!
    
    private var originalImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.masksToBounds = false
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
            imageView.sd_setImage(with: imageURL) { [weak self] image, _, _, _ in
                self?.originalImage = image
                
                if coverPageData.coverPremium && !PremiumManager.shared.isContentUnlocked(itemID: coverPageData.itemID) {
                    self?.applyBlurEffect()
                    self?.premiumIconImageView.isHidden = false
                } else {
                    self?.removeBlurEffect()
                    self?.premiumIconImageView.isHidden = true
                }
            }
        }
    }
    
    func applyBlurEffect() {
        guard let image = originalImage else { return }
        
        let context = CIContext()
        guard let ciImage = CIImage(image: image) else { return }
        
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(20.0, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: ciImage.extent) else { return }
        
        imageView.image = UIImage(cgImage: cgImage)
    }
    
    func removeBlurEffect() {
        imageView.image = originalImage
    }
    
    override var isSelected: Bool {
        didSet {
            if !premiumIconImageView.isHidden {
                layer.borderWidth = 0
                layer.borderColor = nil
                layer.shadowOpacity = 0
            } else {
                layer.borderWidth = isSelected ? 3 : 0
                layer.borderColor = isSelected ? UIColor.icon.cgColor : nil
                
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
