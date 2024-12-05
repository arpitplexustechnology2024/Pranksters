//
//  ShareLinkVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 27/11/24.
//

import UIKit
import Alamofire
import AVFAudio
import AVFoundation

class ShareLinkVC: UIViewController, UITextViewDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var scrollViewView: UIView!
    @IBOutlet weak var prankImageView: UIImageView!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var prankNameLabel: UITextView!
    @IBOutlet weak var nameChangeButton: UIButton!
    
    // MARK: - Properties
    var selectedURL: String?
    var selectedFile: Data?
    var selectedName: String?
    var selectedCoverURL: String?
    var selectedCoverFile: Data?
    var selectedPranktype: String?
    private var isPlaying = false
    var coverImageURL: String?
    var prankDataURL: String?
    var prankName: String?
    var prankLink: String?
    var sharePrank: Bool = false
    private var audioPlayer: AVAudioPlayer?
    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var bannerAdUtility = BannerAdUtility()
    private var viewModel = PrankViewModel()
    private var noDataView: NoDataBottomBarView!
    let interstitialAdUtility = InterstitialAdUtility()
    private var noInternetView: NoInternetBottombarView!
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupNoDataView()
        self.setupScrollView()
        self.setupSwipeGesture()
        self.setupNoInternetView()
        self.addContentToStackView()
        self.setupKeyboardObservers()
        self.hideKeyboardTappedAround()
    }
    
    // MARK: - setupUI
    func setupUI() {
        self.shareView.layer.cornerRadius = 15
        self.prankImageView.layer.cornerRadius = 15
        self.nameChangeButton.layer.cornerRadius = nameChangeButton.frame.height / 2
        self.playPauseImageView.image = UIImage(named: "PlayButton")
        self.playPauseImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayPause))
        self.prankImageView.isUserInteractionEnabled = true
        self.prankImageView.addGestureRecognizer(tapGesture)
        
        let playPauseTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayPause))
        self.playPauseImageView.isUserInteractionEnabled = true
        self.playPauseImageView.addGestureRecognizer(playPauseTapGesture)
        
        if sharePrank {
            self.checkInternetAndFetchData()
            self.nameChangeButton.isHidden = false
        } else {
            self.nameChangeButton.isHidden = true
            self.prankNameLabel.text = self.prankName
            
            if let coverImageUrl = self.coverImageURL {
                self.loadImage(from: coverImageUrl, into: self.prankImageView)
            }
        }
        if isConnectedToInternet() {
            bannerAdUtility.setupBannerAd(in: self, adUnitID: "ca-app-pub-3940256099942544/2435281174")
            Task {
                await interstitialAdUtility.loadInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
            }
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
        }
        interstitialAdUtility.delegate = self
        
        self.prankNameLabel.isEditable = false
        self.prankNameLabel.delegate = self
        self.prankNameLabel.returnKeyType = .done
    }
    
    // MARK: - checkInternetAndFetchData
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            createPrank()
            self.noInternetView?.isHidden = true
            self.scrollViewView.isHidden = false
            self.playPauseImageView.isHidden = false
            self.hideNoDataView()
        } else {
            self.showNoInternetView()
        }
    }
    
    // MARK: - setupScrollView
    func setupScrollView() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollViewView.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: scrollViewView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: scrollViewView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: scrollViewView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: scrollViewView.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    // MARK: - createPrank
    func createPrank() {
        let coverImageURL = selectedCoverURL ?? ""
        let coverImageFile = selectedCoverFile ?? Data()
        let fileURL = selectedURL ?? ""
        let file = selectedFile ?? Data()
        let name = selectedName ?? "Unnamed Prank"
        let type = selectedPranktype ?? "Unknown"
        
        prankImageView.showShimmer()
        prankNameLabel.showShimmer()
        nameChangeButton.showShimmer()
        
        viewModel.createPrank(coverImage: coverImageFile, coverImageURL: coverImageURL, type: type, name: name, file: file, fileURL: fileURL) { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.savePrankToUserDefaults()
                    self.prankImageView.hideShimmer()
                    self.prankNameLabel.hideShimmer()
                    self.nameChangeButton.hideShimmer()
                    
                    print("Prank Link :- \(self.viewModel.createPrankLink ?? "")")
                    print("Prank Link :- \(self.viewModel.createPrankData ?? "")")
                    print("Prank ID :- \(self.viewModel.createPrankID ?? "")")
                    
                    if let fileResponse = self.viewModel.createPrankResponse?.file {
                        // Print CoverImage details
                        print("\nCover Image Details:")
                        fileResponse.coverImage.forEach { coverImage in
                            print("Fieldname: \(coverImage.fieldname)")
                            print("Original Name: \(coverImage.originalname)")
                            print("Encoding: \(coverImage.encoding)")
                            print("Mimetype: \(coverImage.mimetype)")
                            print("Destination: \(coverImage.destination)")
                            print("Filename: \(coverImage.filename)")
                            print("Path: \(coverImage.path)")
                            print("Size: \(coverImage.size) bytes")
                            print("---")
                        }
                        
                        // Print File details
                        print("\nFile Details:")
                        fileResponse.file.forEach { file in
                            print("Fieldname: \(file.fieldname)")
                            print("Original Name: \(file.originalname)")
                            print("Encoding: \(file.encoding)")
                            print("Mimetype: \(file.mimetype)")
                            print("Destination: \(file.destination)")
                            print("Filename: \(file.filename)")
                            print("Path: \(file.path)")
                            print("Size: \(file.size) bytes")
                            print("---")
                        }
                    }
                    
                    self.coverImageURL = self.viewModel.createPrankCoverImage
                    self.prankDataURL = self.viewModel.createPrankData
                    self.prankName = self.viewModel.createPrankName
                    self.prankLink = self.viewModel.createPrankLink
                    self.prankNameLabel.text = self.prankName
                    
                    if let coverImageUrl = self.coverImageURL {
                        self.loadImage(from: coverImageUrl, into: self.prankImageView)
                    }
                    
                    self.playPauseImageView.image = UIImage(named: "PlayButton")
                    self.playPauseImageView.isUserInteractionEnabled = true
                    
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayPause))
                    self.prankImageView.isUserInteractionEnabled = true
                    self.prankImageView.addGestureRecognizer(tapGesture)
                    
                    let playPauseTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayPause))
                    self.playPauseImageView.isUserInteractionEnabled = true
                    self.playPauseImageView.addGestureRecognizer(playPauseTapGesture)
                } else {
                    if let error = self.viewModel.errorMessage {
                        print("Prank failed: \(error)")
                        self.showNoDataView()
                    }
                }
            }
        }
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
            
            if selectedPranktype == "audio" {
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
                    prankImageView.image = UIImage(named: "audioPrankImage")
                    playPauseImageView.isHidden = true
                } else {
                    audioPlayer?.pause()
                    prankImageView.image = UIImage(named: "audioPrankImage")
                    playPauseImageView.image = UIImage(named: "PlayButton")
                    playPauseImageView.isHidden = false
                }
            } else if selectedPranktype == "video" {
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
                            playerLayer?.frame = prankImageView.bounds
                            
                            if let playerLayer = playerLayer {
                                prankImageView.layer.addSublayer(playerLayer)
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
                    loadImage(from: prankDataUrl, into: prankImageView)
                    playPauseImageView.isHidden = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
                        if let coverImageUrl = self.coverImageURL {
                            self.loadImage(from: coverImageUrl, into: self.prankImageView)
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
                self.loadImage(from: coverImageUrl, into: self.prankImageView)
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
    
    // MARK: - setupNoDataView
    private func setupNoDataView() {
        noDataView = NoDataBottomBarView()
        noDataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noDataView.isHidden = true
        self.shareView.addSubview(noDataView)
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataView.leadingAnchor.constraint(equalTo: shareView.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: shareView.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: shareView.topAnchor),
            noDataView.bottomAnchor.constraint(equalTo: shareView.bottomAnchor)
        ])
        noDataView.layer.cornerRadius = 15
        noDataView.layer.masksToBounds = true
        noDataView.layoutIfNeeded()
    }
    
    // MARK: - setupNoInternetView
    func setupNoInternetView() {
        noInternetView = NoInternetBottombarView()
        noInternetView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        noInternetView.isHidden = true
        self.shareView.addSubview(noInternetView)
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noInternetView.leadingAnchor.constraint(equalTo: shareView.leadingAnchor),
            noInternetView.trailingAnchor.constraint(equalTo: shareView.trailingAnchor),
            noInternetView.topAnchor.constraint(equalTo: shareView.topAnchor),
            noInternetView.bottomAnchor.constraint(equalTo: shareView.bottomAnchor)
        ])
        noInternetView.layer.cornerRadius = 15
        noInternetView.layer.masksToBounds = true
        noInternetView.layoutIfNeeded()
    }
    
    // MARK: - retryButtonTapped
    @objc func retryButtonTapped() {
        if isConnectedToInternet() {
            noInternetView.isHidden = true
            hideNoDataView()
            checkInternetAndFetchData()
            bannerAdUtility.setupBannerAd(in: self, adUnitID: "ca-app-pub-3940256099942544/2435281174")
            Task {
                await interstitialAdUtility.loadInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
            }
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
        }
    }
    
    func showNoInternetView() {
        self.noInternetView.isHidden = false
        self.scrollViewView.isHidden = true
        self.playPauseImageView.isHidden = true
    }
    
    private func showNoDataView() {
        noDataView?.isHidden = false
        scrollViewView.isHidden = true
        self.playPauseImageView.isHidden = true
    }
    
    private func hideNoDataView() {
        noDataView?.isHidden = true
        scrollViewView.isHidden = false
        self.playPauseImageView.isHidden = false
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
    }
    
    // MARK: - setupSwipeGesture
    private func setupSwipeGesture() {
        let swipeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGesture.edges = .left
        self.view.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            self.navigationController?.popViewController(animated: true)
        }
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
            label.textColor = .white
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
        case 1:  // Instagram Message
            guard let prankLink = prankLink,
                  let prankName = prankName else { return }
            let message = "\(prankName)\n\n🔗 Check it out: \(prankLink)"
            if let url = URL(string: "instagram://sharesheet?text=\(message)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case 2:  // Instagram Story
            interstitialAdUtility.presentInterstitial(from: self)
        case 3: break  // Snapchat Message
        case 4: break   // Snapchat Story
        case 5: break   // Telegram Message
        case 6: // WhatsApp Message
            guard let prankLink = prankLink,
                  let prankName = prankName,
                  let coverImageURL = coverImageURL else { return }
            
            AF.request(coverImageURL).responseData { [weak self] response in
                switch response.result {
                case .success(let imageData):
                    guard let image = UIImage(data: imageData) else { return }
                    
                    let message = "\(prankName)\n\n🔗 Check it out: \(prankLink)"
                    self?.openShareSheetWithImageAndLink(image: image, link: message)
                case .failure:
                    self?.openShareSheetWithLink(prankLink)
                }
            }
        case 7:  // More
            shareViaWhatsAppMessage()
        default:
            break
        }
    }
    
    private func openShareSheetWithImageAndLink(image: UIImage, link: String) {
        let activityViewController = UIActivityViewController(
            activityItems: [image, link],
            applicationActivities: nil
        )
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func openShareSheetWithLink(_ link: String) {
        let activityViewController = UIActivityViewController(
            activityItems: [link],
            applicationActivities: nil
        )
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func shareViaWhatsAppMessage() {
        guard let prankLink = prankLink,
              let prankName = prankName,
              let coverImageURL = coverImageURL else { return }
        
        AF.request(coverImageURL).responseData { [weak self] response in
            switch response.result {
            case .success(let imageData):
                guard let image = UIImage(data: imageData) else { return }
                
                let message = "\(prankName)\n\n🔗 Check it out: \(prankLink)"
                
                if let imageURL = self?.saveImageToTemporaryFile(image: image) {
                    let whatsappURL = URL(string: "whatsapp://send?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
                    
                    if let url = whatsappURL, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
            case .failure:
                self?.openShareSheetWithLink(prankLink)
            }
        }
    }
    
    private func saveImageToTemporaryFile(image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        
        do {
            try data.write(to: tempFileURL)
            return tempFileURL
        } catch {
            print("Error saving image to temporary file: \(error)")
            return nil
        }
    }
    
    // MARK: - btnNameChangeTapped
    @IBAction func btnNameChangeTapped(_ sender: UIButton) {
        if isConnectedToInternet() {
            prankNameLabel.isEditable = true
            prankNameLabel.becomeFirstResponder()
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            textView.isEditable = false
            guard let updatedName = prankNameLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !updatedName.isEmpty else {
                print("Name cannot be empty")
                return false
            }
            
            guard let prankID = viewModel.createPrankID else {
                print("Prank ID not available")
                return false
            }
            
            viewModel.updatePrankName(id: prankID, name: updatedName) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        print(success.message)
                        self.prankName = updatedName
                    case .failure(let failure):
                        print(failure.localizedDescription)
                        self.prankNameLabel.text = self.viewModel.createPrankName
                    }
                }
            }
            return false
        }
        return true
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let textViewBottomY = prankNameLabel.convert(prankNameLabel.bounds, to: view).maxY
        let overlap = textViewBottomY - (view.frame.height - keyboardHeight)
        
        let additionalSpace: CGFloat = 50
        
        if overlap > 0 {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -(overlap + additionalSpace)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - btnBackTapped
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ShareLinkVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            if let coverImageUrl = self.coverImageURL {
                self.loadImage(from: coverImageUrl, into: self.prankImageView)
            }
            self.playPauseImageView.image = UIImage(named: "PlayButton")
            self.playPauseImageView.isHidden = false
            self.audioPlayer = nil
        }
    }
}

extension ShareLinkVC: InterstitialAdUtilityDelegate {
    
    // MARK: - InterstitialAdUtilityDelegate
    func didFailToLoadInterstitial() {
        navigateToSecondViewController()
    }
    
    func didFailToPresentInterstitial() {
        navigateToSecondViewController()
    }
    
    func didDismissInterstitial() {
        navigateToSecondViewController()
    }
    
    private func navigateToSecondViewController() {
    }
}

extension ShareLinkVC {
    func savePrankToUserDefaults() {
        var savedPranks = fetchSavedPranks()
        
        let newPrank = PrankCreateData(
            id: viewModel.createPrankID ?? "",
            link: viewModel.createPrankLink ?? "",
            coverImage: viewModel.createPrankCoverImage ?? "",
            file: viewModel.createPrankData ?? "",
            type: selectedPranktype ?? "",
            name: viewModel.createPrankName ?? ""
        )
        savedPranks.append(newPrank)
        
        if let encodedData = try? JSONEncoder().encode(savedPranks) {
            UserDefaults.standard.set(encodedData, forKey: "SavedPranks")
        }
    }
    
    func fetchSavedPranks() -> [PrankCreateData] {
        if let savedPranksData = UserDefaults.standard.data(forKey: "SavedPranks"),
           let savedPranks = try? JSONDecoder().decode([PrankCreateData].self, from: savedPranksData) {
            return savedPranks
        }
        return []
    }
}
