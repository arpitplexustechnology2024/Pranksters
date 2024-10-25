//
//  ImageCardPreview.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 19/10/24.
//

import UIKit
import Shuffle_iOS
import SDWebImage

struct ImageCardModel {
    let name: String
    let image: String
    var isFavorited: Bool
    let itemId: Int
    let categoryId: Int
    let Premium: Bool
}

class ImageCardPreview: SwipeCard {
    
    private let imageView = UIImageView()
    private let imageLabel = UILabel()
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0
        return view
    }()
    private let favouriteButton = UIButton()
    private let premiumIconView = UIImageView()
    var model: ImageCardModel?
    var onFavoriteButtonTapped: ((Int, Bool, Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCard() {
        imageView.contentMode = .scaleAspectFit
        imageView.layer.backgroundColor = UIColor.black.cgColor
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        addSubview(imageView)
        
        // Add blur effect view after imageView
        blurEffectView.layer.masksToBounds = true
        blurEffectView.layer.cornerRadius = 12
        addSubview(blurEffectView)
        
        imageLabel.textColor = .white
        imageLabel.textAlignment = .left
        imageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addSubview(imageLabel)
        
        premiumIconView.image = UIImage(named: "premiumIcon")
        premiumIconView.isHidden = true
        addSubview(premiumIconView)
        
        favouriteButton.setImage(UIImage(named: "Heart"), for: .normal)
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        addSubview(favouriteButton)
        
        [imageView, blurEffectView, imageLabel, premiumIconView, favouriteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
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
    
    func configure(withModel model: ImageCardModel, customImage: UIImage? = nil) {
        self.model = model
        if let customImage = customImage {
            imageView.image = customImage
        } else {
            imageView.sd_setImage(with: URL(string: model.image))
        }
        updateFavoriteButton(isFavorited: model.isFavorited)
        imageLabel.text = model.name
        
        if model.Premium {
            blurEffectView.alpha = 1
            premiumIconView.isHidden = false
        } else {
            blurEffectView.alpha = 0
            premiumIconView.isHidden = true
        }
        favouriteButton.isHidden = false
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
