//
//  CoverCardView.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 15/10/24.
//

import UIKit
import Shuffle_iOS

struct CardModel {
    let imageName: String
    var isFavorited: Bool = false
}

class CoverCardView: SwipeCard {
    
    private let imageView = UIImageView()
    private let favouriteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCard() {
        // Configure image view
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        addSubview(imageView)
        
        // Configure favorite button
        favouriteButton.setImage(UIImage(named: "Heart"), for: .normal) // Default unfavorite state
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        
        addSubview(favouriteButton)
        
        // Set up constraints for image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set up constraints for favorite button
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favouriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            favouriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            favouriteButton.widthAnchor.constraint(equalToConstant: 22),
            favouriteButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    // Method to configure the card with the model
    func configure(withModel model: CardModel) {
        imageView.image = UIImage(named: model.imageName)
        updateFavoriteButton(isFavorited: model.isFavorited)
    }
    
    // Update the button's image based on favorite status
    private func updateFavoriteButton(isFavorited: Bool) {
        let heartImage = isFavorited ? "Heart_Fill" : "Heart" // Heart_Fill for favorite, Heart for unfavorite
        favouriteButton.setImage(UIImage(named: heartImage), for: .normal)
    }
    
    // Handle favorite button tap
    @objc private func favouriteButtonTapped() {
        let isFavorited = (favouriteButton.currentImage == UIImage(named: "Heart")) // Check if it is currently unfavorited
        updateFavoriteButton(isFavorited: isFavorited)
        
        // Add any additional logic you want to perform when the button is tapped
        print(isFavorited ? "Marked as Favorite" : "Unmarked as Favorite")
    }
}
