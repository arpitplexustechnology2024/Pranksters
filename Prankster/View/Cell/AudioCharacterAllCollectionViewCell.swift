//
//  AudioCharacterAllCollectionViewCell.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import AVFoundation
import CoreImage
import SDWebImage
import UIKit

// MARK: - Video Playback Manager
class AudioPlaybackManager {
    static let shared = AudioPlaybackManager()
    private init() {}
    
    var currentlyPlayingCell: AudioCharacterAllCollectionViewCell?
    var currentlyPlayingIndexPath: IndexPath?
    
    func stopCurrentPlayback() {
        currentlyPlayingCell?.stopAudio()
        currentlyPlayingCell = nil
        currentlyPlayingIndexPath = nil
    }
}

// MARK: - Protocols
protocol AudioAllCollectionViewCellDelegate: AnyObject {
    func didTapDoneButton(for categoryAllData: CategoryAllData)
    func didTapAudioPlayback(at indexPath: IndexPath)
}

// MARK: - Collection View Cell
class AudioCharacterAllCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var audioLabel: UILabel!
    @IBOutlet weak var visualEffectView: UIView!
    
    // MARK: - Properties
    weak var delegate: AudioAllCollectionViewCellDelegate?
    private var categoryAllData: CategoryAllData?
    private var blurredImageView: UIImageView!
    private var audioPlayer: AVAudioPlayer?
    private var imageViewTimer: Timer?
    private var isAudioPlaying = false
    private var currentIndexPath: IndexPath?
    private var audioDownloadTask: URLSessionDataTask?
    private var isAudioLoaded = false
    
    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        layer.cornerRadius = 20
        layer.masksToBounds = false
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        blurredImageView = UIImageView()
        blurredImageView.frame = contentView.bounds
        blurredImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredImageView.contentMode = .scaleAspectFill
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurredImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredImageView.addSubview(blurEffectView)
        
        visualEffectView.layer.cornerRadius = 20
        visualEffectView.layer.maskedCorners = [
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner,
        ]
        visualEffectView.layer.masksToBounds = true
        
        DoneButton.layer.shadowColor = UIColor.black.cgColor
        DoneButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        DoneButton.layer.shadowRadius = 3.24
        DoneButton.layer.shadowOpacity = 0.3
        DoneButton.layer.masksToBounds = false
        
        contentView.insertSubview(blurredImageView, at: 0)
        
        DoneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
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
    
    func configure(with categoryAllData: CategoryAllData, at indexPath: IndexPath) {
        self.categoryAllData = categoryAllData
        self.currentIndexPath = indexPath
        
        let displayName = categoryAllData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "---" : categoryAllData.name
        self.audioLabel.text = displayName
        
        if let imageURL = URL(string: categoryAllData.image) {
            blurredImageView.sd_setImage(with: imageURL)
            imageView.sd_setImage(with: imageURL) { [weak self] image, _, _, _ in
                if categoryAllData.premium && !PremiumManager.shared.isContentUnlocked(itemID: categoryAllData.itemID) {
                    self?.DoneButton.setImage(UIImage(named: "PremiumButton"), for: .normal)
                } else {
                    self?.DoneButton.setImage(UIImage(named: "selectButton"), for: .normal)
                }
            }
        }
        setupAudioPlayback(with: categoryAllData.file)
    }
    
    private func setupAudioPlayback(with audioURLString: String?) {
        stopAudio()
        isAudioLoaded = false
        
        guard let audioURLString = audioURLString,
              let audioURL = URL(string: audioURLString) else { return }
        
        audioDownloadTask?.cancel()
        
        audioDownloadTask = URLSession.shared.dataTask(with: audioURL) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                print("Error downloading audio: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                do {
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.prepareToPlay()
                    self.isAudioLoaded = true
                } catch {
                    print("Error setting up audio player: \(error)")
                }
            }
        }
        
        audioDownloadTask?.resume()
    }
    
    func playAudio() {
        guard isAudioLoaded, let audioPlayer = audioPlayer else {
            return
        }
        
        AudioPlaybackManager.shared.stopCurrentPlayback()
        audioPlayer.play()
        showPlayImage()
        isAudioPlaying = true
        AudioPlaybackManager.shared.currentlyPlayingCell = self
        AudioPlaybackManager.shared.currentlyPlayingIndexPath = currentIndexPath
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        showPauseImage()
        isAudioPlaying = false
        imageViewTimer?.invalidate()
    }
    
    private func toggleAudioPlayback() {
        if !isAudioLoaded {
            return
        }
        
        guard let audioPlayer = audioPlayer,
              let indexPath = currentIndexPath else { return }
        
        delegate?.didTapAudioPlayback(at: indexPath)
    }
    
    // MARK: - UI Update Methods
    private func showPlayImage() {
        imageViewTimer?.invalidate()
        playPauseImageView.image = UIImage(named: "PauseButton")
        playPauseImageView.isHidden = false
        imageViewTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0, repeats: false
        ) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.playPauseImageView.alpha = 0
            } completion: { _ in
                self?.playPauseImageView.isHidden = true
                self?.playPauseImageView.alpha = 1
            }
        }
    }
    
    private func showPauseImage() {
        playPauseImageView.image = UIImage(named: "PlayButton")
        playPauseImageView.isHidden = false
    }
    
    @objc private func doneButtonTapped() {
        stopAudio()
        if let categoryAllData = categoryAllData {
            delegate?.didTapDoneButton(for: categoryAllData)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurredImageView.frame = contentView.bounds
    }
    
    @objc private func imageViewTapped() {
        toggleAudioPlayback()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAudio()
        audioDownloadTask?.cancel()
        audioDownloadTask = nil
        audioPlayer = nil
        isAudioLoaded = false
    }
}

extension AudioCharacterAllCollectionViewCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.stopAudio()
            player.currentTime = 0
        }
    }
}
