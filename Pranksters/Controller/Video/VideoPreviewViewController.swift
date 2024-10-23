//
//  VideoPreviewViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 18/10/24.
//

import UIKit
import Shuffle_iOS
import AVKit

class VideoPreviewViewController: UIViewController, SwipeCardStackDataSource, SwipeCardStackDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var allSwipedImageView: UIImageView!
    
    private let cardStack = SwipeCardStack()
    private let favoriteViewModel = FavoriteViewModel()
    var imageData: [CharacterAllData] = []
    var initialIndex: Int = 0
    
    private var currentCardIndex: Int = 0
    private var visibleCards: [VideoCardPreview] = []
    private var currentPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCardStack()
        setupBlurEffect()
        
        allSwipedImageView.isHidden = true
        allSwipedImageView.alpha = 0
        
        self.selectButton.layer.cornerRadius = 13
        currentCardIndex = initialIndex
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visibleCards.forEach { card in
            if let videoCard = card as? VideoCardPreview {
                videoCard.pauseVideo()
            }
        }
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
        return imageData.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = VideoCardPreview()
        let coverPageData = imageData[index]
        
        print("➡️ DEBUG INFO FOR CARD \(index):")
        print("📱 Name: \(coverPageData.name)")
        print("🔗 File URL: \(coverPageData.file ?? "No URL found")")
        print("🎥 Premium Status: \(coverPageData.premium)")
        print("❤️ Favorite Status: \(coverPageData.isFavorite)")
        print("🆔 Item ID: \(coverPageData.itemID)")
        print("------------------")
        
        let cardModel = VideoCardModel(
            file: coverPageData.file ?? "",
            name: coverPageData.name,
            isFavorited: coverPageData.isFavorite,
            itemId: coverPageData.itemID,
            categoryId: 2,
            Premium: coverPageData.premium
        )
        
        card.configure(withModel: cardModel)
        card.swipeDirections = [.left, .right]
        visibleCards.append(card)
        
        card.onPremiumContentTapped = { [weak self] in
            self?.presentPremiumViewController()
        }
        
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
            let swipedCard = visibleCards[index]
            swipedCard.pauseVideo()
            visibleCards.remove(at: index)
        }
        
        currentCardIndex = index + 1
        
        updateSelectButtonState()
    }
    
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        guard currentCardIndex < imageData.count else { return }
        
        let selectedData = imageData[currentCardIndex]
        
        if selectedData.premium {
            print("Premium")
            presentPremiumViewController()
        } else {
            print("Start")
            if let selectedCard = visibleCards.first {
                selectedCard.togglePlayPause()
            }
        }
    }
    
    private func updateSelectButtonState() {
        selectButton.isEnabled = currentCardIndex < imageData.count
    }
    
    // MARK: - Favorite Handling
    private func handleFavoriteButtonTapped(itemId: Int, isFavorite: Bool, categoryId: Int) {
        favoriteViewModel.setFavorite(itemId: itemId, isFavorite: isFavorite, categoryId: categoryId) { [weak self] success, message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    if let index = self.imageData.firstIndex(where: { $0.itemID == itemId }) {
                        self.imageData[index].isFavorite = isFavorite
                        
                        if let visibleCard = self.visibleCards.first(where: { $0.model?.itemId == itemId }) {
                            let updatedModel = VideoCardModel(
                                file: self.imageData[index].file ?? "",
                                name: self.imageData[index].name,
                                isFavorited: isFavorite,
                                itemId: itemId,
                                categoryId: categoryId,
                                Premium: self.imageData[index].premium
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
    
    private func revertFavoriteStatus(for itemId: Int) {
        if let index = imageData.firstIndex(where: { $0.itemID == itemId }) {
            let currentStatus = imageData[index].isFavorite
            imageData[index].isFavorite = !currentStatus
            
            if let cardToUpdate = visibleCards.first(where: { $0.model?.itemId == itemId }) {
                let updatedModel = VideoCardModel(
                    file: imageData[index].file ?? "",
                    name: imageData[index].name,
                    isFavorited: !currentStatus,
                    itemId: itemId,
                    categoryId: 2,
                    Premium: imageData[index].premium
                )
                cardToUpdate.configure(withModel: updatedModel)
            }
        }
    }
    
    @IBAction func btnSelectTapped(_ sender: UIButton) {
        guard currentCardIndex < imageData.count else { return }
        
        let selectedCoverData = imageData[currentCardIndex]
        
        if selectedCoverData.premium {
            presentPremiumViewController()
        } else {
            if let navigationController = self.presentingViewController as? UINavigationController {
                self.dismiss(animated: false) {
                    if let videoVC = navigationController.viewControllers.first(where: { $0 is VideoViewController }) as? VideoViewController {
                        videoVC.updateSelectedVideo(with: selectedCoverData)
                        navigationController.popToViewController(videoVC, animated: true)
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let videoVC = storyboard.instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController {
                            videoVC.updateSelectedVideo(with: selectedCoverData)
                            navigationController.pushViewController(videoVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    private func presentPremiumViewController() {
        let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumViewController") as! PremiumViewController
        present(premiumVC, animated: true, completion: nil)
    }
}
