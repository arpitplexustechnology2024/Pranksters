//
//  AudioCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import UIKit
import SDWebImage
import CoreImage

// MARK: - AddCoverPageCollectionCell
class AddAudioCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addAudioLabel: UILabel!
    
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

// MARK: - AddCoverPageCollectionCell
class AudioCustomCollectionCell: UICollectionViewCell {
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

// MARK: - AddCoverPageCollectionCell
class AudioCharacterCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 10
        layer.masksToBounds = false
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
