//
//  CoverCardView.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 15/10/24.
//

import UIKit
import Shuffle_iOS
import SDWebImage

struct CardModel {
    let imageURL: String
    var isFavorited: Bool
    let itemId: Int
    let categoryId: Int
    let isPremium: Bool
}

class CoverCardView: SwipeCard {
    
    private let imageView = UIImageView()
    private let premiumBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0
        return view
    }()
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
        
        // Add blur effect view after imageView
        premiumBlurView.layer.masksToBounds = true
        premiumBlurView.layer.cornerRadius = 12
        addSubview(premiumBlurView)
        
        premiumIconView.image = UIImage(named: "premiumIcon")
        premiumIconView.isHidden = true
        addSubview(premiumIconView)
        
        favouriteButton.setImage(UIImage(named: "Heart"), for: .normal)
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        addSubview(favouriteButton)
        
        [imageView, premiumBlurView, premiumIconView, favouriteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            premiumBlurView.topAnchor.constraint(equalTo: topAnchor),
            premiumBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            premiumBlurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            premiumBlurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
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
            imageView.image = customImage
        } else {
            imageView.sd_setImage(with: URL(string: model.imageURL))
        }
        updateFavoriteButton(isFavorited: model.isFavorited)
        
        if model.isPremium {
            premiumBlurView.alpha = 1
            premiumIconView.isHidden = false
        } else {
            premiumBlurView.alpha = 0
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
