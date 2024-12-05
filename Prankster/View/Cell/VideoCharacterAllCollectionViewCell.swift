//
//  VideoCharacterAllCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 21/10/24.
//

import UIKit
import SDWebImage
import AVFoundation

// MARK: - Global VideoMute Manager
class GlobalVideoMuteManager {
    static let shared = GlobalVideoMuteManager()
    private init() {}
    
    var isMutedGlobally = true
    var muteStatusChangeHandlers: [() -> Void] = []
    
    func toggleGlobalMuteStatus() {
        isMutedGlobally = !isMutedGlobally
        muteStatusChangeHandlers.forEach { $0() }
    }
}

// MARK: - Video Playback Manager
class VideoPlaybackManager {
    static let shared = VideoPlaybackManager()
    private init() {}
    
    var currentlyPlayingCell: VideoCharacterAllCollectionViewCell?
    var currentlyPlayingIndexPath: IndexPath?
    
    func stopCurrentPlayback() {
        currentlyPlayingCell?.stopVideo()
        currentlyPlayingCell = nil
        currentlyPlayingIndexPath = nil
    }
}

// MARK: - Protocols
protocol VideoCharacterAllCollectionViewCellDelegate: AnyObject {
    func didTapDoneButton(for categoryAllData: CategoryAllData)
    func didTapVideoPlayback(at indexPath: IndexPath)
}

// MARK: - Collection View Cell
class VideoCharacterAllCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var imageName: UILabel!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: VideoCharacterAllCollectionViewCellDelegate?
    private var coverPageData: CategoryAllData?
    private var imageViewTimer: Timer?
    var currentIndexPath: IndexPath?
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var isPlaying = false
    private var isVideoLoaded = false
    private var lastPausedTime: CMTime?
    private var isMuted = false
    
    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGlobalMuteObserver()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = false
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        visualEffectView.layer.cornerRadius = 20
        visualEffectView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        visualEffectView.layer.masksToBounds = true
        
        DoneButton.layer.shadowColor = UIColor.black.cgColor
        DoneButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        DoneButton.layer.shadowRadius = 3.24
        DoneButton.layer.shadowOpacity = 0.3
        DoneButton.layer.masksToBounds = false
        
        DoneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)
        muteButton.setImage(UIImage(named: "UnmuteIcon"), for: .normal)
        muteButton.isHidden = true
        muteButton.layer.cornerRadius = muteButton.frame.height / 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Configuration
    func configure(with coverPageData: CategoryAllData, at indexPath: IndexPath) {
        self.coverPageData = coverPageData
        self.currentIndexPath = indexPath
        let displayName = coverPageData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "---" : coverPageData.name
        self.imageName.text = displayName
        
        if coverPageData.premium && !PremiumManager.shared.isContentUnlocked(itemID: coverPageData.itemID) {
            self.DoneButton.setImage(UIImage(named: "PremiumButton"), for: .normal)
        } else {
            self.DoneButton.setImage(UIImage(named: "selectButton"), for: .normal)
        }
        
        if let videoURL = URL(string: coverPageData.file ?? "N/A") {
            setupVideo(with: videoURL)
        }
        player?.isMuted = GlobalVideoMuteManager.shared.isMutedGlobally
        updateMuteButtonImage()
    }
    
    private func setupVideo(with url: URL) {
        stopVideo()
        playerLayer?.removeFromSuperlayer()
        
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = imageView.bounds
        imageView.layer.addSublayer(playerLayer)
        
        self.player = player
        self.playerLayer = playerLayer
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidStartPlaying),
                                               name: .AVPlayerItemNewAccessLogEntry,
                                               object: player.currentItem)
        
        self.isVideoLoaded = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }
    
    @objc private func playerDidStartPlaying() {
        playerLayer?.videoGravity = .resizeAspect
    }
    
    // MARK: - Video Control Methods
    func playVideo() {
        guard isVideoLoaded, let player = player else {
            return
        }
        player.isMuted = GlobalVideoMuteManager.shared.isMutedGlobally
        AudioPlaybackManager.shared.stopCurrentPlayback()
        
        if let pausedTime = lastPausedTime {
            player.seek(to: pausedTime)
        }
        
        player.play()
        showPlayImage()
        isPlaying = true
        muteButton.isHidden = false
        
        VideoPlaybackManager.shared.currentlyPlayingCell = self
        VideoPlaybackManager.shared.currentlyPlayingIndexPath = currentIndexPath
    }
    
    func stopVideo() {
        let currentTime = player?.currentTime()
        
        player?.pause()
        showPauseImage()
        isPlaying = false
        imageViewTimer?.invalidate()
        muteButton.isHidden = true
        lastPausedTime = currentTime
    }
    
    private func toggleAudioPlayback() {
        if !isVideoLoaded {
            return
        }
        
        if let indexPath = currentIndexPath {
            delegate?.didTapVideoPlayback(at: indexPath)
        }
    }
    
    // MARK: - UI Update Methods
    private func showPlayImage() {
        imageViewTimer?.invalidate()
        playPauseImageView.image = UIImage(named: "PauseButton")
        playPauseImageView.isHidden = false
        imageViewTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0, repeats: false
        ) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.playPauseImageView.alpha = 0
            } completion: { _ in
                self?.playPauseImageView.isHidden = true
                self?.playPauseImageView.alpha = 1
            }
        }
    }
    
    func showPauseImage() {
        playPauseImageView.image = UIImage(named: "PlayButton")
        playPauseImageView.isHidden = false
    }
    
    // MARK: - Action Methods
    @objc private func imageViewTapped() {
        toggleAudioPlayback()
    }
    
    @objc private func doneButtonTapped() {
        stopVideo()
        if let coverPageData = coverPageData {
            delegate?.didTapDoneButton(for: coverPageData)
        }
    }
    
    @objc private func muteButtonTapped() {
        GlobalVideoMuteManager.shared.toggleGlobalMuteStatus()
    }
    
    @objc private func playerDidFinishPlaying() {
        stopVideo()
        lastPausedTime = nil
        player?.seek(to: CMTime.zero)
        playerLayer?.videoGravity = .resizeAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = imageView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        NotificationCenter.default.removeObserver(self)
        
        stopVideo()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        isVideoLoaded = false
        lastPausedTime = nil
        GlobalVideoMuteManager.shared.muteStatusChangeHandlers.removeAll { $0 as? () -> Void == nil }
    }
    
    private func setupGlobalMuteObserver() {
        let handler = { [weak self] in
            guard let self = self, let player = self.player else { return }
            player.isMuted = GlobalVideoMuteManager.shared.isMutedGlobally
            self.updateMuteButtonImage()
        }
        GlobalVideoMuteManager.shared.muteStatusChangeHandlers.append(handler)
    }
    
    private func updateMuteButtonImage() {
        let isMuted = GlobalVideoMuteManager.shared.isMutedGlobally
        muteButton.setImage(UIImage(named: isMuted ? "muteIcon 2" : "UnmuteIcon"), for: .normal)
    }
}
