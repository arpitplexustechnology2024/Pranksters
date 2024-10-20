//
//  CoverCardView.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 15/10/24.
//

import UIKit
import Shuffle_iOS
import SDWebImage
import CoreImage

struct CardModel {
    let imageURL: String
    var isFavorited: Bool
    let itemId: Int
    let categoryId: Int
    let isPremium: Bool
}

class CoverCardView: SwipeCard {
    
    private let imageView = UIImageView()
    private let blurredImageView = UIImageView()
    private let favouriteButton = UIButton()
    private let premiumIconView = UIImageView()
    var model: CardModel?
    var onFavoriteButtonTapped: ((Int, Bool, Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCard() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        addSubview(imageView)
        
        blurredImageView.contentMode = .scaleAspectFill
        blurredImageView.layer.masksToBounds = true
        blurredImageView.layer.cornerRadius = 12
        blurredImageView.alpha = 0
        addSubview(blurredImageView)
        
        premiumIconView.image = UIImage(named: "premiumIcon")
        premiumIconView.isHidden = true
        addSubview(premiumIconView)
        
        favouriteButton.setImage(UIImage(named: "Heart"), for: .normal)
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        addSubview(favouriteButton)
        
        [imageView, blurredImageView, premiumIconView, favouriteButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            blurredImageView.topAnchor.constraint(equalTo: topAnchor),
            blurredImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurredImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            premiumIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            premiumIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            premiumIconView.widthAnchor.constraint(equalToConstant: 60),
            premiumIconView.heightAnchor.constraint(equalToConstant: 60),
            
            favouriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            favouriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            favouriteButton.widthAnchor.constraint(equalToConstant: 22),
            favouriteButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(withModel model: CardModel, customImage: UIImage? = nil) {
        self.model = model
        if let customImage = customImage {
            setImage(customImage)
        } else {
            imageView.sd_setImage(with: URL(string: model.imageURL)) { [weak self] image, _, _, _ in
                if let image = image {
                    self?.setImage(image)
                }
            }
        }
        updateFavoriteButton(isFavorited: model.isFavorited)
        
        if model.isPremium {
            blurredImageView.alpha = 1
            premiumIconView.isHidden = false
        } else {
            blurredImageView.alpha = 0
            premiumIconView.isHidden = true
        }
        favouriteButton.isHidden = false
    }
    
    private func setImage(_ image: UIImage) {
        imageView.image = image
        if let blurredImage = applyGaussianBlur(to: image) {
            blurredImageView.image = blurredImage
        }
    }
    
    private func applyGaussianBlur(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(50, forKey: kCIInputRadiusKey)
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    @objc private func favouriteButtonTapped() {
        guard let model = model else { return }
        let newFavoriteStatus = !model.isFavorited
        updateFavoriteButton(isFavorited: newFavoriteStatus)
        onFavoriteButtonTapped?(model.itemId, newFavoriteStatus, model.categoryId)
    }
    
    private func updateFavoriteButton(isFavorited: Bool) {
        let heartImage = isFavorited ? "Heart_Fill" : "Heart"
        favouriteButton.setImage(UIImage(named: heartImage), for: .normal)
    }
}
