//
//  VideoViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 18/10/24.
//

import UIKit
import Alamofire
import SDWebImage
import Lottie
import AVFoundation
import MobileCoreServices
import Photos

class VideoViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var AudioShowView: UIView!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet var floatingCollectionButton: [UIButton]!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var pauseImageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var videoCustomCollectionView: UICollectionView!
    @IBOutlet weak var videoCharacterCollectionView: UICollectionView!
    @IBOutlet weak var lottieLoader: LottieAnimationView!
    @IBOutlet weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoCustomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoCharacterHeightConstraint: NSLayoutConstraint!
    
    let plusImage = UIImage(named: "Plus")
    let cancelImage = UIImage(named: "Cancel")
    
    var selectedVideoIndex: Int?
    
    var favoriteVideos: [String] = []
    
    var selectedVideos: [URL] = []
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaying = false
    
    var audioSession: AVAudioSession?
    
    private var viewModel: CharacterViewModel!
    var isLoading = true
    private var noDataView: NoDataBottomBarView!
    private var noInternetView: NoInternetBottombarView!
    
    init(viewModel: CharacterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = CharacterViewModel(apiService: CharacterAPIService.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
        stopVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        setupNoDataView()
        setupLottieLoader()
        showSkeletonLoader()
        setupNoInternetView()
        setupFloatingButtons()
        checkInternetAndFetchData()
        addBottomShadow(to: navigationbarView)
        
        setupVideoImageView()
        setupAudioSession()
        
        self.pauseImageView.image = UIImage(named: "pause")
        self.videoImageView.image = UIImage(named: "MusicAudio01")
        self.pauseImageView.isHidden = true
        
        loadFavoriteVideos()
        
    }
    
    private func stopVideo() {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        isPlaying = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupVideoImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoImageViewTapped))
        videoImageView.addGestureRecognizer(tapGesture)
        videoImageView.isUserInteractionEnabled = true
    }
    
    @objc private func videoImageViewTapped() {
        if isPlaying {
            pauseVideo()
        } else {
            playVideo()
        }
    }
    
    private func playVideo() {
        player?.play()
        isPlaying = true
        pauseImageView.isHidden = true
    }
    
    private func pauseVideo() {
        player?.pause()
        isPlaying = false
        pauseImageView.isHidden = false
    }
    
    private func setupAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .moviePlayback)
            try audioSession?.setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }
    }
    
    
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            viewModel.fetchCharacters(categoryId: 2)
            self.noInternetView?.isHidden = true
        } else {
            self.showNoInternetView()
            self.hideSkeletonLoader()
        }
    }
    
    func setupUI() {
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowOffset = CGSize(width: 0, height: 5)
        bottomView.layer.shadowRadius = 12
        bottomView.layer.cornerRadius = 28
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomScrollView.layer.cornerRadius = 28
        bottomScrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        floatingButton.setImage(plusImage, for: .normal)
        floatingButton.layer.cornerRadius = 19
        videoImageView.layer.cornerRadius = 8
        AudioShowView.layer.cornerRadius = 8
        self.videoCharacterCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        videoCustomCollectionView.delegate = self
        videoCustomCollectionView.dataSource = self
        videoCharacterCollectionView.delegate = self
        videoCharacterCollectionView.dataSource = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            coverImageViewHeightConstraint.constant = 280
            coverImageViewWidthConstraint.constant = 245
            scrollViewHeightConstraint.constant = 680
            videoCustomHeightConstraint.constant = 180
            videoCharacterHeightConstraint.constant = 360
        } else {
            coverImageViewHeightConstraint.constant = 240
            coverImageViewWidthConstraint.constant = 205
            scrollViewHeightConstraint.constant = 530
            videoCustomHeightConstraint.constant = 140
            videoCharacterHeightConstraint.constant = 280
        }
        self.view.layoutIfNeeded()
    }
    
    func setupViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.hideSkeletonLoader()
                self?.noDataView.isHidden = true
                self?.videoCharacterCollectionView.reloadData()
                
            }
        }
        
        viewModel.onError = { error in
            self.hideSkeletonLoader()
            self.noDataView.isHidden = false
            print("Error fetching cover pages: \(error)")
        }
    }
    
    private func setupNoDataView() {
        noDataView = NoDataBottomBarView()
        noDataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        noDataView.isHidden = true
        self.view.addSubview(noDataView)
        
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: videoImageView.bottomAnchor, constant: 16),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        noDataView.layer.cornerRadius = 28
        noDataView.layer.masksToBounds = true
        
        noDataView.layoutIfNeeded()
    }
    
    func setupNoInternetView() {
        noInternetView = NoInternetBottombarView()
        noInternetView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        
        noInternetView.isHidden = true
        self.view.addSubview(noInternetView)
        
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noInternetView.topAnchor.constraint(equalTo: videoImageView.bottomAnchor, constant: 16),
            noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        noInternetView.layer.cornerRadius = 28
        noInternetView.layer.masksToBounds = true
        
        noInternetView.layoutIfNeeded()
    }
    
    @objc func retryButtonTapped() {
        if isConnectedToInternet() {
            noInternetView.isHidden = true
            noDataView.isHidden = true
            checkInternetAndFetchData()
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
        }
    }
    
    func showSkeletonLoader() {
        isLoading = true
        videoCharacterCollectionView.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        videoCharacterCollectionView.reloadData()
    }
    
    func showNoInternetView() {
        self.noInternetView.isHidden = false
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
    }
    
    func showLottieLoader() {
        lottieLoader.isHidden = false
        videoImageView.isHidden = true
        favouriteButton.isHidden = true
        lottieLoader.play()
    }
    
    func hideLottieLoader() {
        lottieLoader.stop()
        lottieLoader.isHidden = true
        videoImageView.isHidden = false
        favouriteButton.isHidden = false
    }
    
    private func setupLottieLoader() {
        lottieLoader.isHidden = true
        lottieLoader.loopMode = .loop
        lottieLoader.contentMode = .scaleAspectFill
        lottieLoader.animation = LottieAnimation.named("Loader")
    }
    
    private func setupFloatingButtons() {
        for button in floatingCollectionButton {
            button.layer.cornerRadius = 19
            button.clipsToBounds = true
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.25
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
            button.isHidden = true
            button.alpha = 0
        }
    }
    
    func addBottomShadow(to view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 7)
        view.layer.shadowRadius = 12
        view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: view.bounds.maxY - 4, width: view.bounds.width, height: 4)).cgPath
    }
    
    @IBAction func btnFloatingTapped(_ sender: UIButton) {
        floatingCollectionButton.forEach { btn in
            UIView.animate(withDuration: 0.5) {
                btn.isHidden = !btn.isHidden
                btn.alpha = btn.alpha == 0 ? 1 : 0
            }
        }
        if floatingButton.currentImage == plusImage {
            floatingButton.setImage(cancelImage, for: .normal)
        } else {
            floatingButton.setImage(plusImage, for: .normal)
        }
    }
    
    @IBAction func btnMoreAppTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MoreAppViewController") as! MoreAppViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFavouriteTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
    }
    
    @IBAction func btnPremiumTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
    }
    
    func animate(toggel: Bool) {
        if toggel {
            floatingCollectionButton.forEach { btn in
                UIView.animate(withDuration: 0.5) {
                    btn.isHidden = false
                    btn.alpha = btn.alpha == 0 ? 1 : 0
                }
            }
        } else {
            floatingCollectionButton.forEach { btn in
                UIView.animate(withDuration: 0.5) {
                    btn.isHidden = true
                    btn.alpha = btn.alpha == 0 ? 1 : 0
                }
            }
        }
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        // Implement your logic here
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func loadFavoriteVideos() {
        if let savedFavorites = UserDefaults.standard.array(forKey: "FavoriteVideos") as? [String] {
            favoriteVideos = savedFavorites
        }
    }
    
    private func saveFavoriteVideos() {
        UserDefaults.standard.set(favoriteVideos, forKey: "FavoriteVideos")
    }
    
    private func toggleFavorite(for videoURL: URL) {
        let urlString = videoURL.absoluteString
        
        if favoriteVideos.contains(urlString) {
            // Remove from favorites
            if let index = favoriteVideos.firstIndex(of: urlString) {
                favoriteVideos.remove(at: index)
                favouriteButton.setImage(UIImage(named: "Heart"), for: .normal)
            }
        } else {
            // Add to favorites
            favoriteVideos.append(urlString)
            favouriteButton.setImage(UIImage(named: "Heart_Fill"), for: .normal)
        }
        
        saveFavoriteVideos()
    }
    
    private func updateFavoriteButtonState(for videoURL: URL) {
        let urlString = videoURL.absoluteString
        let isFavorite = favoriteVideos.contains(urlString)
        favouriteButton.setImage(UIImage(named: isFavorite ? "Heart_Fill" : "Heart"), for: .normal)
    }
    
    @IBAction func btnFavouriteSetTapped(_ sender: UIButton) {
        guard let selectedIndex = selectedVideoIndex,
              selectedVideos.indices.contains(selectedIndex) else {
            return
        }
        
        let videoURL = selectedVideos[selectedIndex]
        toggleFavorite(for: videoURL)
    }
}

extension VideoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == videoCustomCollectionView {
            return selectedVideos.count + 1
        } else if collectionView == videoCharacterCollectionView {
            return isLoading ? 6 : viewModel.characters.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == videoCustomCollectionView {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddVideoCollectionViewCell", for: indexPath) as! AddVideoCollectionViewCell
                cell.imageView.image = UIImage(named: "AddVideo")
                cell.addAudioLabel.text = "Add Video"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCustomCollectionViewCell", for: indexPath) as! VideoCustomCollectionViewCell
                let videoURL = selectedVideos[indexPath.item - 1]
                cell.setThumbnail(for: videoURL)
                return cell
            }
        } else if collectionView == videoCharacterCollectionView {
            if isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCharacterCollectionViewCell", for: indexPath) as! VideoCharacterCollectionViewCell
                let character = viewModel.characters[indexPath.item]
                if let url = URL(string: character.characterImage) {
                    cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == videoCustomCollectionView {
            if indexPath.item == 0 {
                showVideoOptionsActionSheet(sourceView: collectionView.cellForItem(at: indexPath)!)
            } else {
                
                let videoURL = selectedVideos[indexPath.item - 1]
                playVideo(url: videoURL)
                selectedVideoIndex = indexPath.item - 1
            }
        } else if collectionView == videoCharacterCollectionView {
            let character = viewModel.characters[indexPath.item]
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VideoCharacterAllViewController") as! VideoCharacterAllViewController
            vc.characterId = character.characterID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 155 : 115
        let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 165 : 125
        
        if collectionView == videoCustomCollectionView {
            if indexPath.item == 0 {
                return CGSize(width: width, height: height)
            }
            return CGSize(width: width, height: height)
        } else if collectionView == videoCharacterCollectionView {
            return CGSize(width: width, height: height)
        }
        return CGSize(width: width, height: height)
    }
}

extension VideoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showVideoOptionsActionSheet(sourceView: UIView) {
        let titleString = NSAttributedString(string: "Select Video", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ])
        
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(titleString, forKey: "attributedTitle")
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.openVideoCamera()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openVideoGallery()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        
        present(alertController, animated: true)
    }
    
    private func openVideoCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.showVideoPicker(for: .camera)
                    } else {
                        self?.showPermissionSnackbar(for: "camera")
                    }
                }
            }
        case .authorized:
            showVideoPicker(for: .camera)
        case .denied, .restricted:
            showPermissionSnackbar(for: "camera")
        @unknown default:
            break
        }
    }
    
    private func openVideoGallery() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.showVideoPicker(for: .photoLibrary)
                    } else {
                        self?.showPermissionSnackbar(for: "photo library")
                    }
                }
            }
        case .authorized, .limited:
            showVideoPicker(for: .photoLibrary)
        case .denied, .restricted:
            showPermissionSnackbar(for: "photo library")
        @unknown default:
            break
        }
    }
    
    private func showVideoPicker(for sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("Source type \(sourceType) is not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.videoQuality = .typeHigh
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
    private func showPermissionSnackbar(for feature: String) {
        let messageKey: String
        
        switch feature {
        case "camera":
            messageKey = "We need access to your camera to record a video."
        case "photo library":
            messageKey = "We need access to your photo library to select a video."
        default:
            messageKey = "SnackbarDefaultPermissionAccess"
        }
        
        let localizedMessage = NSLocalizedString(messageKey, comment: "")
        let settingsText = NSLocalizedString("Settings", comment: "")
        
        let snackbar = Snackbar(message: localizedMessage, backgroundColor: .snackbar)
        snackbar.setAction(title: settingsText) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        
        snackbar.show(in: self.view, duration: 5.0)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let mediaType = info[.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[.mediaURL] as? URL else {
            return
        }
        
        selectedVideos.append(url)
        let newIndex = selectedVideos.count
        videoCustomCollectionView.reloadData()
        
        let indexPath = IndexPath(item: newIndex, section: 0)
        videoCustomCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        playVideo(url: url)
        
        selectedVideoIndex = newIndex - 1
    }
    
    func playVideo(url: URL) {
        showLottieLoader()
        playerLayer?.removeFromSuperlayer()
        
        let playerItem = AVPlayerItem(url: url)
        
        player = AVPlayer(playerItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoImageView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer = playerLayer {
            videoImageView.layer.addSublayer(playerLayer)
        }
        
        player?.volume = 1.0
        
        hideLottieLoader()
        playVideo()
        
        updateFavoriteButtonState(for: url)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        if let index = selectedVideoIndex {
            let indexPath = IndexPath(item: index + 1, section: 0)
            videoCustomCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        player?.seek(to: CMTime.zero)
        playVideo()
    }
    
    func isVideoFavorite(_ url: URL) -> Bool {
        return favoriteVideos.contains(url.absoluteString)
    }
}
