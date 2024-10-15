//
//  CoverPreviewViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 15/10/24.
//

import UIKit
import Shuffle_iOS

class CoverPreviewViewController: UIViewController, SwipeCardStackDataSource, SwipeCardStackDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var allSwipedImageView: UIImageView!
    
    private let cardStack = SwipeCardStack()
    
    private var cardModels: [CardModel] = [
        CardModel(imageName: "Pranksters"),
        CardModel(imageName: "Pranksters"),
        CardModel(imageName: "Pranksters"),
        CardModel(imageName: "Pranksters"),
        CardModel(imageName: "Pranksters"),
        CardModel(imageName: "Pranksters"),
        CardModel(imageName: "Pranksters"),
        CardModel(imageName: "Pranksters"),
        CardModel(imageName: "Pranksters")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCardStack()
        setupBlurEffect()
        
        allSwipedImageView.isHidden = true
        allSwipedImageView.alpha = 0
        
        self.selectButton.layer.cornerRadius = 13
    }
    
    private func setupCardStack() {
        cardStack.dataSource = self
        cardStack.delegate = self
        
        containerView.addSubview(cardStack)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardStack.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            cardStack.heightAnchor.constraint(equalTo: containerView.heightAnchor),
            cardStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cardStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    // MARK: - SwipeCardStackDataSource
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return cardModels.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = CoverCardView()
        card.configure(withModel: cardModels[index])
        card.swipeDirections = [.left, .right]
        return card
    }
    
    // MARK: - SwipeCardStackDelegate
    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("All cards swiped")
        allSwipedImageView.isHidden = false
        selectButton.isHidden = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.allSwipedImageView.alpha = 1.0
            self.selectButton.alpha = 0
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                UIView.animate(withDuration: 0.5, animations: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        if direction == .left {
            print("Swiped card at index \(index) to the left")
        } else if direction == .right {
            print("Swiped card at index \(index) to the right")
        }
    }
    
    func cardStack(_ cardStack: SwipeCardStack, shouldSwipeCardAt index: Int, in direction: SwipeDirection) -> Bool {
        return direction == .left || direction == .right
    }
}
