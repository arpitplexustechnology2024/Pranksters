//
//  CoverPreviewViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 15/10/24.
//

import UIKit
import Shuffle_iOS

protocol CoverPreviewViewControllerDelegate: AnyObject {
    func coverPreviewViewController(_ viewController: CoverPreviewViewController, didUpdateFavoriteStatusForItemAt index: Int, isFavorite: Bool)
    func coverPreviewViewController(_ viewController: CoverPreviewViewController, didSelectCoverAt index: Int, coverData: CoverPageData)
}

class CoverPreviewViewController: UIViewController, SwipeCardStackDataSource, SwipeCardStackDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var allSwipedImageView: UIImageView!
    
    weak var delegate: CoverPreviewViewControllerDelegate?
    var isCustomCover: Bool = false
    var customImages: [UIImage] = []
    
    private let cardStack = SwipeCardStack()
    private let favoriteViewModel = FavoriteViewModel()
    var onDismiss: (() -> Void)?
    var coverPages: [CoverPageData] = []
    var initialIndex: Int = 0
    
    private var currentCardIndex: Int = 0
    private var visibleCards: [CoverCardView] = []
    
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
        return coverPages.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = CoverCardView()
        let coverPageData = coverPages[index]
        
        if isCustomCover {
            let cardModel = CardModel(imageURL: "", isFavorited: coverPageData.isFavorite, itemId: coverPageData.itemID, categoryId: 4, isPremium: coverPageData.coverPremium)
            card.configure(withModel: cardModel, customImage: customImages[index])
        } else {
            let cardModel = CardModel(imageURL: coverPageData.coverURL, isFavorited: coverPageData.isFavorite, itemId: coverPageData.itemID, categoryId: 4, isPremium: coverPageData.coverPremium)
            card.configure(withModel: cardModel)
        }
        
        card.swipeDirections = [.left, .right]
        visibleCards.append(card)
        
        card.onFavoriteButtonTapped = { [weak self] itemId, isFavorite, categoryId in
            self?.handleFavoriteButtonTapped(itemId: itemId, isFavorite: isFavorite, categoryId: categoryId)
        }
        
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
        if index < visibleCards.count {
            visibleCards.remove(at: index)
        }
        
        currentCardIndex = index + 1
        updateSelectButtonState()
    }
    
    private func updateSelectButtonState() {
        selectButton.isEnabled = currentCardIndex < coverPages.count
    }
    
    // MARK: - Favorite Handling
    private func handleFavoriteButtonTapped(itemId: Int, isFavorite: Bool, categoryId: Int) {
        if isCustomCover {
            if let index = coverPages.firstIndex(where: { $0.itemID == itemId }) {
                coverPages[index].isFavorite = isFavorite
                delegate?.coverPreviewViewController(self, didUpdateFavoriteStatusForItemAt: index, isFavorite: isFavorite)
            }
        } else {
            favoriteViewModel.setFavorite(itemId: itemId, isFavorite: isFavorite, categoryId: categoryId) { [weak self] success, message in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if success {
                        if let index = self.coverPages.firstIndex(where: { $0.itemID == itemId }) {
                            self.coverPages[index].isFavorite = isFavorite
                            if let visibleCard = self.visibleCards.first(where: { $0.model?.itemId == itemId }) {
                                let updatedModel = CardModel(
                                    imageURL: self.coverPages[index].coverURL,
                                    isFavorited: isFavorite,
                                    itemId: itemId,
                                    categoryId: categoryId,
                                    isPremium: self.coverPages[index].coverPremium
                                )
                                visibleCard.configure(withModel: updatedModel)
                            }
                        }
                        print(message ?? "Favorite status updated successfully")
                    } else {
                        print("Failed to update favorite status: \(message ?? "Unknown error")")
                        self.revertFavoriteStatus(for: itemId)
                    }
                }
            }
        }
    }
    
    private func revertFavoriteStatus(for itemId: Int) {
        if let index = coverPages.firstIndex(where: { $0.itemID == itemId }) {
            let currentStatus = coverPages[index].isFavorite
            coverPages[index].isFavorite = !currentStatus
            
            if let cardToUpdate = visibleCards.first(where: { $0.model?.itemId == itemId }) {
                let updatedCardModel = CardModel(imageURL: coverPages[index].coverURL, isFavorited: !currentStatus, itemId: coverPages[index].itemID, categoryId: 4, isPremium: coverPages[index].coverPremium)
                
                cardToUpdate.configure(withModel: updatedCardModel)
            }
        }
    }
    
    @IBAction func btnSelectTapped(_ sender: UIButton) {
        guard currentCardIndex < coverPages.count else { return }
        
        let selectedCoverData = coverPages[currentCardIndex]
        
        if selectedCoverData.coverPremium {
            presentPremiumViewController()
        } else {
            delegate?.coverPreviewViewController(self, didSelectCoverAt: currentCardIndex, coverData: selectedCoverData)
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func presentPremiumViewController() {
        let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumViewController") as! PremiumViewController
        present(premiumVC, animated: true, completion: nil)
    }
}
