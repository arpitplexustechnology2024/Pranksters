//
//  AudioPreviewViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 18/10/24.
//


import UIKit
import Shuffle_iOS
import AVFoundation

class AudioPreviewViewController: UIViewController, SwipeCardStackDataSource, SwipeCardStackDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var allSwipedImageView: UIImageView!
    
    private let cardStack = SwipeCardStack()
    var audioData: [CharacterAllData] = []
    var initialIndex: Int = 0
    private var currentCardIndex: Int = 0
    private var visibleCards: [AudioCardPreview] = []
    private let favoriteViewModel = FavoriteViewModel()
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCardStack()
        setupBlurEffect()
        setupAudioSession()
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
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Audio Control Methods
    func setupAudioPlayer(for audioFile: String) {
        guard let url = URL(string: audioFile) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Failed to download audio: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                do {
                    self?.audioPlayer = try AVAudioPlayer(data: data)
                    self?.audioPlayer?.delegate = self
                    self?.audioPlayer?.prepareToPlay()
                    if let currentCard = self?.visibleCards.first {
                        self?.updateDurationLabel(currentCard)
                    }
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
        }.resume()
    }
    
    private func updateDurationLabel(_ card: AudioCardPreview) {
        guard let duration = audioPlayer?.duration else { return }
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        card.updateDurationLabel(text: String(format: "%02d:%02d", minutes, seconds))
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.isPlaying = false
                self.stopTimer()
                
                if let currentCard = self.visibleCards.first {
                    currentCard.updatePlayButtonImage(isPlaying: false)
                    currentCard.updateSliderValue(0)
                    
                    if let duration = self.audioPlayer?.duration {
                        let minutes = Int(duration) / 60
                        let seconds = Int(duration) % 60
                        currentCard.updateDurationLabel(text: String(format: "%02d:%02d", minutes, seconds))
                    }
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer,
                  let currentCard = self.visibleCards.first else { return }
            
            let progress = Float(player.currentTime / player.duration)
            currentCard.updateSliderValue(progress)
            
            _ = Int(player.currentTime)
            let duration = Int(player.duration)
            currentCard.updateDurationLabel(text: "\(timeString(from: duration))")
        }
    }
    
    private func timeString(from timeInterval: Int) -> String {
        let minutes = timeInterval / 60
        let seconds = timeInterval % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func playPauseAudio(_ card: AudioCardPreview) {
        if isPlaying {
            audioPlayer?.pause()
            card.updatePlayButtonImage(isPlaying: false)
            stopTimer()
        } else {
            audioPlayer?.play()
            card.updatePlayButtonImage(isPlaying: true)
            startTimer()
        }
        isPlaying = !isPlaying
    }
    
    func seekAudio(to value: Float) {
        guard let player = audioPlayer else { return }
        let time = Double(value) * player.duration
        player.currentTime = time
        
        if !isPlaying {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            visibleCards.first?.updateDurationLabel(text: String(format: "%02d:%02d", minutes, seconds))
        }
    }
    
    // MARK: - SwipeCardStackDataSource
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return audioData.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let card = AudioCardPreview()
        let audioPageData = audioData[index]
        
        let cardModel = AudioCardModel(file: audioPageData.file, name: audioPageData.name, image: audioPageData.image, isFavorited: audioPageData.isFavorite, itemId: audioPageData.itemID, categoryId: 1, Premium: audioPageData.premium)
        card.configure(withModel: cardModel)
        
        setupAudioPlayer(for: audioPageData.file)
        
        card.onPlayButtonTapped = { [weak self] in
            self?.playPauseAudio(card)
        }
        
        card.onSliderValueChanged = { [weak self] value in
            self?.seekAudio(to: value)
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
        stopAndResetAudio()
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
        stopAndResetAudio()
        if index < visibleCards.count {
            visibleCards.remove(at: index)
        }
        
        currentCardIndex = index + 1
        updateSelectButtonState()
        
        if currentCardIndex < audioData.count {
            setupAudioPlayer(for: audioData[currentCardIndex].file)
        }
    }
    
    private func stopAndResetAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        stopTimer()
        
        visibleCards.first?.updatePlayButtonImage(isPlaying: false)
        visibleCards.first?.updateSliderValue(0)
    }
    
    private func updateSelectButtonState() {
        selectButton.isEnabled = currentCardIndex < audioData.count
    }
    
    private func handleFavoriteButtonTapped(itemId: Int, isFavorite: Bool, categoryId: Int) {
        favoriteViewModel.setFavorite(itemId: itemId, isFavorite: isFavorite, categoryId: categoryId) { [weak self] success, message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    print(message ?? "")
                    if let index = self.audioData.firstIndex(where: { $0.itemID == itemId }) {
                        self.audioData[index].isFavorite = isFavorite
                    }
                } else {
                    print("Failed to update favorite status: \(message ?? "Unknown error")")
                    self.revertFavoriteStatus(for: itemId)
                }
            }
        }
    }
    
    private func revertFavoriteStatus(for itemId: Int) {
        if let index = audioData.firstIndex(where: { $0.itemID == itemId }) {
            let audioPageData = audioData[index]
            let updatedCardModel = AudioCardModel(file: audioPageData.file, name: audioPageData.name, image: audioPageData.image, isFavorited: !audioPageData.isFavorite, itemId: audioPageData.itemID, categoryId: 1, Premium: audioPageData.premium)
            
            if let cardToUpdate = visibleCards.first(where: { $0.model?.itemId == itemId }) {
                cardToUpdate.configure(withModel: updatedCardModel)
            }
        }
    }
    
    @IBAction func btnSelectTapped(_ sender: UIButton) {
        guard currentCardIndex < audioData.count else { return }
        let selectedAudio = audioData[currentCardIndex]
        
        if selectedAudio.premium {
            presentPremiumViewController()
        } else {
            audioPlayer?.stop()
            timer?.invalidate()
            
            if let navigationController = self.presentingViewController as? UINavigationController {
                self.dismiss(animated: false) {
                    if let audioVC = navigationController.viewControllers.first(where: { $0 is AudioViewController }) as? AudioViewController {
                        navigationController.popToViewController(audioVC, animated: true)
                        audioVC.playSelectedAudio(selectedAudio)
                    } else {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let audioVC = storyboard.instantiateViewController(withIdentifier: "AudioViewController") as? AudioViewController {
                            audioVC.initialAudioData = selectedAudio
                            navigationController.pushViewController(audioVC, animated: true)
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
    
    deinit {
        stopAndResetAudio()
    }
}
