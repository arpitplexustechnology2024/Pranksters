//
//  ShareLinkPopup.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 01/12/24.
//

import UIKit
import Alamofire
import AVFAudio
import AVFoundation

class ShareLinkPopup: UIViewController {
    
    @IBOutlet weak var shareLinkPopup: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var playPauseImageView: UIImageView!
    
    var coverImageURL: String?
    var prankDataURL: String?
    var prankName: String?
    var prankLink: String?
    var prankType: String?
    private var isPlaying = false
    private var audioPlayer: AVAudioPlayer?
    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shareLinkPopup.layer.cornerRadius = 18
        self.imageView.layer.cornerRadius = 18
        self.setupScrollView()
        self.setupBlurEffect()
        self.addContentToStackView()
        
        if let coverImageUrl = self.coverImageURL {
            self.loadImage(from: coverImageUrl, into: self.imageView)
        }
        
        self.playPauseImageView.image = UIImage(named: "PlayButton")
        self.playPauseImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayPause))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
        
        let playPauseTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayPause))
        self.playPauseImageView.isUserInteractionEnabled = true
        self.playPauseImageView.addGestureRecognizer(playPauseTapGesture)
        
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewClickDissmiss))
        self.view.addGestureRecognizer(viewTapGesture)
    }
    
    @objc private func viewClickDissmiss() {
        self.dismiss(animated: true)
    }
    
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.9
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
    }
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - setupScrollView
    func setupScrollView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = true
        shareView.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: shareView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: shareView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: shareView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: shareView.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func loadImage(from urlString: String, into imageView: UIImageView) {
        AF.request(urlString).response { response in
            switch response.result {
            case .success(let data):
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            case .failure(let error):
                print("Image download error: \(error)")
                DispatchQueue.main.async {
                    imageView.image = UIImage(named: "placeholder")
                }
            }
        }
    }
    
    @objc private func togglePlayPause() {
        if isConnectedToInternet() {
            isPlaying.toggle()
            
            guard let prankDataUrl = prankDataURL else { return }
            
            if prankType == "audio" {
                if isPlaying {
                    if audioPlayer == nil {
                        do {
                            let audioData = try Data(contentsOf: URL(string: prankDataUrl)!)
                            audioPlayer = try AVAudioPlayer(data: audioData)
                            audioPlayer?.prepareToPlay()
                        } catch {
                            print("Error loading audio: \(error)")
                            isPlaying = false
                            return
                        }
                    }
                    audioPlayer?.play()
                    audioPlayer?.delegate = self
                    imageView.image = UIImage(named: "audioPrankImage")
                    playPauseImageView.isHidden = true
                } else {
                    audioPlayer?.pause()
                    imageView.image = UIImage(named: "audioPrankImage")
                    playPauseImageView.image = UIImage(named: "PlayButton")
                    playPauseImageView.isHidden = false
                }
            } else if prankType == "video" {
                if isPlaying {
                    if videoPlayer == nil {
                        do {
                            let videoData = try Data(contentsOf: URL(string: prankDataUrl)!)
                            let temporaryDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let temporaryFileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
                            
                            try videoData.write(to: temporaryFileURL)
                            
                            videoPlayer = AVPlayer(url: temporaryFileURL)
                            playerLayer = AVPlayerLayer(player: videoPlayer)
                            playerLayer?.videoGravity = .resizeAspectFill
                            playerLayer?.frame = imageView.bounds
                            
                            if let playerLayer = playerLayer {
                                imageView.layer.addSublayer(playerLayer)
                            }
                        } catch {
                            print("Error loading video: \(error)")
                            isPlaying = false
                            return
                        }
                    }
                    
                    videoPlayer?.play()
                    playPauseImageView.isHidden = true
                    NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(videoDidFinishPlaying),
                        name: .AVPlayerItemDidPlayToEndTime,
                        object: videoPlayer?.currentItem
                    )
                } else {
                    videoPlayer?.pause()
                    playPauseImageView.image = UIImage(named: "PlayButton")
                    playPauseImageView.isHidden = false
                }
            } else {
                if isPlaying {
                    loadImage(from: prankDataUrl, into: imageView)
                    playPauseImageView.isHidden = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                        if let coverImageUrl = self.coverImageURL {
                            self.loadImage(from: coverImageUrl, into: self.imageView)
                        }
                        playPauseImageView.image = UIImage(named: "PlayButton")
                        playPauseImageView.isHidden = false
                        isPlaying = false
                    }
                }
            }
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
        }
    }
    
    @objc private func videoDidFinishPlaying() {
        DispatchQueue.main.async {
            self.videoPlayer?.seek(to: .zero)
            self.videoPlayer?.pause()
            self.isPlaying = false
            if let coverImageUrl = self.coverImageURL {
                self.loadImage(from: coverImageUrl, into: self.imageView)
            }
            self.playerLayer?.removeFromSuperlayer()
            self.playerLayer = nil
            self.videoPlayer = nil
            self.playPauseImageView.image = UIImage(named: "PlayButton")
            self.playPauseImageView.isHidden = false
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: nil
            )
        }
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
    }
    
    // MARK: - addContentToStackView
    func addContentToStackView() {
        let items = [
            (icon: UIImage(named: "copylink"), title: "Copy link"),
            (icon: UIImage(named: "instagram"), title: "Message"),
            (icon: UIImage(named: "instagram"), title: "Story"),
            (icon: UIImage(named: "snapchat"), title: "Message"),
            (icon: UIImage(named: "snapchat"), title: "Story"),
            (icon: UIImage(named: "telegram"), title: "Message"),
            (icon: UIImage(named: "whatsapp"), title: "Message"),
            (icon: UIImage(named: "moreShare"), title: "More")
        ]
        
        for (index, item) in items.enumerated() {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.tag = index
            
            let verticalStackView = UIStackView()
            verticalStackView.axis = .vertical
            verticalStackView.alignment = .center
            verticalStackView.spacing = 5
            verticalStackView.translatesAutoresizingMaskIntoConstraints = false
            
            let imageView = UIImageView(image: item.icon)
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .white
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = item.title
            label.textColor = .icon
            label.font = UIFont.systemFont(ofSize: 12)
            label.translatesAutoresizingMaskIntoConstraints = false
            verticalStackView.addArrangedSubview(imageView)
            verticalStackView.addArrangedSubview(label)
            containerView.addSubview(verticalStackView)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 50),
                imageView.heightAnchor.constraint(equalToConstant: 50)
            ])
            NSLayoutConstraint.activate([
                verticalStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                verticalStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            
            containerView.widthAnchor.constraint(equalToConstant: 78).isActive = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
            containerView.addGestureRecognizer(tapGesture)
            containerView.isUserInteractionEnabled = true
            
            
            stackView.addArrangedSubview(containerView)
        }
    }
    
    // MARK: - viewTapped
    @objc func viewTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        
        switch tappedView.tag {
        case 0: // Copy link
            if let prankLink = prankLink {
                UIPasteboard.general.string = prankLink
                let snackbar = CustomSnackbar(message: "Link copied to clipboard!", backgroundColor: .snackbar)
                snackbar.show(in: self.view, duration: 3.0)
            }
        case 1: break  // Instagram Message
            
        case 2: break  // Instagram Story
            
        case 3: break  // Snapchat Message
            
        case 4: break   // Snapchat Story
            
        case 5:    // Telegram Message
            if let prankLink = prankLink {
                    let telegramMessage = "\(prankLink)"
                    let encodedMessage = telegramMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    if let url = URL(string: "tg://msg?text=\(encodedMessage ?? "")"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        let snackbar = CustomSnackbar(message: "Telegram app not installed!", backgroundColor: .snackbar)
                        snackbar.show(in: self.view, duration: 3.0)
                    }
                }
        case 6:  // WhatsApp Message
            shareToTelegram()
        case 7: break // More
            
        default:
            break
        }
    }
    
    private func shareToTelegram() {
        guard let prankLink = prankLink else { return }
        
        // Step 1: Download the image
        guard let coverImageUrl = coverImageURL, let imageUrl = URL(string: coverImageUrl) else {
            print("Invalid cover image URL")
            return
        }
        
        AF.download(imageUrl).responseData { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    // Step 2: Create the sharing items
                    let sharingItems: [Any] = [image, prankLink]
                    
                    // Step 3: Initialize UIActivityViewController
                    let activityVC = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
                    
                    // Limit sharing to Telegram
                    activityVC.excludedActivityTypes = [
                        .postToFacebook,
                        .postToTwitter,
                        .message,
                        .mail,
                        .postToWeibo,
                        .print,
                        .copyToPasteboard,
                        .assignToContact,
                        .saveToCameraRoll
                    ]
                    
                    // Step 4: Present the activity view controller
                    self.present(activityVC, animated: true, completion: nil)
                } else {
                    print("Failed to create image from data")
                }
            case .failure(let error):
                print("Failed to download cover image: \(error)")
            }
        }
    }
}

extension ShareLinkPopup: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            if let coverImageUrl = self.coverImageURL {
                self.loadImage(from: coverImageUrl, into: self.imageView)
            }
            self.playPauseImageView.image = UIImage(named: "PlayButton")
            self.playPauseImageView.isHidden = false
            self.audioPlayer = nil
        }
    }
}
