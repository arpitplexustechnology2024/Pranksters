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
}

class CoverCardView: SwipeCard {
    
    private let imageView = UIImageView()
    private let favouriteButton = UIButton()
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
        
        favouriteButton.setImage(UIImage(named: "Heart"), for: .normal)
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        
        addSubview(favouriteButton)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favouriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            favouriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            favouriteButton.widthAnchor.constraint(equalToConstant: 22),
            favouriteButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    func configure(withModel model: CardModel) {
        self.model = model
        imageView.sd_setImage(with: URL(string: model.imageURL))
        updateFavoriteButton(isFavorited: model.isFavorited)
    }
    
    private func updateFavoriteButton(isFavorited: Bool) {
        let heartImage = isFavorited ? "Heart_Fill" : "Heart"
        favouriteButton.setImage(UIImage(named: heartImage), for: .normal)
    }
    
    @objc private func favouriteButtonTapped() {
        guard var model = model else { return }
        model.isFavorited.toggle()
        updateFavoriteButton(isFavorited: model.isFavorited)
        onFavoriteButtonTapped?(model.itemId, model.isFavorited, model.categoryId)
    }
}
