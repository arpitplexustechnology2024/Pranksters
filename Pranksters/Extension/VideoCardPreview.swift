//
//  VideoCardPreview.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 21/10/24.
//

import UIKit
import Shuffle_iOS
import SDWebImage
import CoreImage
import AVKit
import Lottie

struct VideoCardModel {
    let file: String
    let name: String
    var isFavorited: Bool
    let itemId: Int
    let categoryId: Int
    let Premium: Bool
}

class VideoCardPreview: SwipeCard {
    
    private let videoContainer = UIView()
    private let videoPlayer = AVPlayer()
    private let playerLayer = AVPlayerLayer()
    private let imageLabel = UILabel()
    private let favouriteButton = UIButton()
    private let premiumIconView = UIImageView()
    private let pauseOverlayImageView = UIImageView()
    
    private let blurContainer = UIView()
    private let blurEffect = UIBlurEffect(style: .dark)
    private let blurEffectView: UIVisualEffectView
    
    private let loadingAnimation = LottieAnimationView(name: "LoadData")
    private var playerItemStatusObserver: NSKeyValueObservation?
    
    var model: VideoCardModel?
    var onFavoriteButtonTapped: ((Int, Bool, Int) -> Void)?
    var onPremiumContentTapped: (() -> Void)?
    private var isPlaying = false
    
    override init(frame: CGRect) {
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(frame: frame)
        configureCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCard() {
        videoContainer.layer.cornerRadius = 12
        videoContainer.layer.backgroundColor = UIColor.black.cgColor
        videoContainer.layer.masksToBounds = true
        addSubview(videoContainer)
        
        playerLayer.videoGravity = .resizeAspect
        videoContainer.layer.addSublayer(playerLayer)
        
        pauseOverlayImageView.contentMode = .scaleAspectFit
        pauseOverlayImageView.image = UIImage(named: "pause")
        pauseOverlayImageView.tintColor = .white
        pauseOverlayImageView.alpha = 0
        videoContainer.addSubview(pauseOverlayImageView)
        
        loadingAnimation.loopMode = .loop
        loadingAnimation.contentMode = .scaleAspectFit
        addSubview(loadingAnimation)
        
        imageLabel.textColor = .white
        imageLabel.textAlignment = .left
        imageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addSubview(imageLabel)
        
        blurContainer.layer.cornerRadius = 12
        blurContainer.layer.masksToBounds = true
        videoContainer.addSubview(blurContainer)
        
        blurEffectView.alpha = 0
        blurContainer.addSubview(blurEffectView)
        
        premiumIconView.image = UIImage(named: "premiumIcon")
        premiumIconView.contentMode = .scaleAspectFit
        premiumIconView.isHidden = true
        addSubview(premiumIconView)
        
        favouriteButton.setImage(UIImage(named: "Heart"), for: .normal)
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        addSubview(favouriteButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap))
        videoContainer.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [videoContainer, loadingAnimation, imageLabel, blurContainer, premiumIconView, favouriteButton, pauseOverlayImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            videoContainer.topAnchor.constraint(equalTo: topAnchor),
            videoContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            videoContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            videoContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            blurContainer.topAnchor.constraint(equalTo: topAnchor),
            blurContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: blurContainer.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: blurContainer.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: blurContainer.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: blurContainer.bottomAnchor),
            
            premiumIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            premiumIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            premiumIconView.widthAnchor.constraint(equalToConstant: 60),
            premiumIconView.heightAnchor.constraint(equalToConstant: 60),
            
            loadingAnimation.topAnchor.constraint(equalTo: topAnchor),
            loadingAnimation.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingAnimation.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingAnimation.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            imageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            favouriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            favouriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            favouriteButton.widthAnchor.constraint(equalToConstant: 22),
            favouriteButton.heightAnchor.constraint(equalToConstant: 20),
            
            pauseOverlayImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pauseOverlayImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            pauseOverlayImageView.widthAnchor.constraint(equalToConstant: 80),
            pauseOverlayImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = videoContainer.bounds
    }
    
    func configure(withModel model: VideoCardModel) {
        self.model = model
        
        loadingAnimation.play()
        
        guard let videoURL = URL(string: model.file) else {
            print("❌ Invalid video URL: \(model.file)")
            return
        }
        
        print("🎥 Attempting to load video from URL: \(videoURL)")
        
        let asset = AVAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        playerItemStatusObserver = playerItem.observe(\.status, options: [.new, .old]) { [weak self] playerItem, _ in
            DispatchQueue.main.async {
                self?.handlePlayerItemStatusChange(playerItem)
            }
        }
        
        videoPlayer.replaceCurrentItem(with: playerItem)
        playerLayer.player = videoPlayer
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        
        updateFavoriteButton(isFavorited: model.isFavorited)
        imageLabel.text = model.name
        
        if model.Premium {
            UIView.animate(withDuration: 0.3) {
                self.blurEffectView.alpha = 1
            }
            premiumIconView.isHidden = false
            pauseVideo()
            pauseOverlayImageView.alpha = 0
        } else {
            UIView.animate(withDuration: 0.3) {
                self.blurEffectView.alpha = 0
            }
            premiumIconView.isHidden = true
            pauseVideo()
        }
        
        favouriteButton.isHidden = false
    }
    
    private func handlePlayerItemStatusChange(_ playerItem: AVPlayerItem) {
        switch playerItem.status {
        case .readyToPlay:
            loadingAnimation.stop()
            loadingAnimation.isHidden = true
            isPlaying = false
            pauseOverlayImageView.alpha = 1
            
        case .failed:
            print("❌ Video failed to load: \(String(describing: playerItem.error))")
            
        case .unknown:
            print("⚠️ Video status unknown")
            
        @unknown default:
            print("⚠️ Unexpected video status")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        playerItemStatusObserver?.invalidate()
        videoPlayer.pause()
    }
    
    @objc private func handleVideoTap() {
        guard let model = model else { return }
        
        if model.Premium {
            onPremiumContentTapped?()
        } else {
            toggleePlayPause()
        }
    }
    
    func toggleePlayPause() {
        if isPlaying {
            videoPlayer.pause()
            UIView.animate(withDuration: 0.3) {
                self.pauseOverlayImageView.alpha = 1
            }
        } else {
            videoPlayer.play()
            UIView.animate(withDuration: 0.3) {
                self.pauseOverlayImageView.alpha = 0
            }
        }
        isPlaying = !isPlaying
    }
    
    @objc private func playerDidFinishPlaying() {
        videoPlayer.seek(to: .zero)
        videoPlayer.play()
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
    
    func playVideo() {
        videoPlayer.play()
        isPlaying = true
        self.pauseOverlayImageView.alpha = 0
    }
    
    func pauseVideo() {
        videoPlayer.pause()
        isPlaying = false
    }
    
    func togglePlayPause() {
        if isPlaying {
            pauseVideo()
        } else {
            playVideo()
        }
    }
}
