//
//  AudioVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 16/10/24.
//

import UIKit
import Alamofire
import SDWebImage
import Lottie
import AVFoundation
import MobileCoreServices

struct CustomAudio: Codable {
    let fileName: String
    let imageFileName: String
    
    init(fileName: String, imageFileName: String) {
        self.fileName = fileName
        self.imageFileName = imageFileName
    }
}

class AudioVC: UIViewController {
    
    // MARK: - outlet
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var audioShowView: UIView!
    @IBOutlet weak var oneTimeBlurView: UIView!
    @IBOutlet weak var PauseImageView: UIImageView!
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var lottieLoader: LottieAnimationView!
    @IBOutlet weak var audioCustomCollectionView: UICollectionView!
    @IBOutlet weak var audioCharacterCollectionView: UICollectionView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioCustomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioCharacterHeightConstraint: NSLayoutConstraint!
    
    // MARK: - variable
    private var timer: Timer?
    private var isLoading = true
    private var isPlaying = false
    var selectedCoverImageURL: String?
    var selectedCoverImageFile: Data?
    private var selectedAudioIndex: Int?
    private var audioPlayer: AVAudioPlayer?
    var initialAudioData: CategoryAllData?
    private var viewModel: CategoryViewModel!
    private var noDataView: NoDataBottomBarView!
    private var selectedAudioCustomCell: IndexPath?
    private var selectedAudioData: CategoryAllData?
    private var selectedAudioCharacterCell: IndexPath?
    private var noInternetView: NoInternetBottombarView!
    private let defaultImages = ["MusicAudio01", "MusicAudio02", "MusicAudio03", "MusicAudio04", "MusicAudio05"]
    private var customAudios: [(url: URL, image: UIImage?)] = [] {
        didSet {
            saveAudios()
        }
    }
    
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = CategoryViewModel(apiService: CategoryAPIService.shared)
    }
    
    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.stop()
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        setupNoDataView()
        loadSavedAudios()
        setupAudioSession()
        setupLottieLoader()
        setupSwipeGesture()
        showSkeletonLoader()
        setupNoInternetView()
        checkInternetAndFetchData()
        setupAudioImageViewGesture()
        self.navigationbarView.addBottomShadow()
        self.PauseImageView.isHidden = true
        if let audioData = initialAudioData {
            playSelectedAudio(audioData)
        }
    }
    
    // MARK: - checkInternetAndFetchData
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            viewModel.fetchCategorys(typeId: 1)
            self.noInternetView?.isHidden = true
        } else {
            self.showNoInternetView()
            self.hideSkeletonLoader()
        }
    }
    
    // MARK: - setupUI
    func setupUI() {
        self.bottomView.layer.shadowColor = UIColor.black.cgColor
        self.bottomView.layer.shadowOpacity = 0.5
        self.bottomView.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.bottomView.layer.shadowRadius = 12
        self.bottomView.layer.cornerRadius = 28
        self.bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.bottomScrollView.layer.cornerRadius = 28
        self.bottomScrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        self.audioImageView.loadGif(name: "CoverGIF")
        self.audioImageView.layer.cornerRadius = 8
        
        self.audioShowView.layer.cornerRadius = 8
        self.audioShowView.layer.shadowColor = UIColor.black.cgColor
        self.audioShowView.layer.shadowOpacity = 0.1
        self.audioShowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.audioShowView.layer.shadowRadius = 12
        
        self.audioCharacterCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        self.audioCustomCollectionView.delegate = self
        self.audioCustomCollectionView.dataSource = self
        self.audioCharacterCollectionView.delegate = self
        self.audioCharacterCollectionView.dataSource = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.oneTimeBlurView.addGestureRecognizer(tapGesture)
        self.oneTimeBlurView.isUserInteractionEnabled = true
        self.oneTimeBlurView.isHidden = true
        if isFirstLaunch() {
            self.oneTimeBlurView.isHidden = false
        } else {
            self.oneTimeBlurView.isHidden = true
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.coverImageViewHeightConstraint.constant = 280
            self.coverImageViewWidthConstraint.constant = 245
            self.scrollViewHeightConstraint.constant = 680
            self.audioCustomHeightConstraint.constant = 180
            self.audioCharacterHeightConstraint.constant = 360
        } else {
            self.coverImageViewHeightConstraint.constant = 240
            self.coverImageViewWidthConstraint.constant = 205
            self.scrollViewHeightConstraint.constant = 530
            self.audioCustomHeightConstraint.constant = 140
            self.audioCharacterHeightConstraint.constant = 280
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: - setupViewModel
    func setupViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                if self?.viewModel.categorys.isEmpty ?? true {
                    self?.noDataView.isHidden = false
                } else {
                    self?.hideSkeletonLoader()
                    self?.noDataView.isHidden = true
                    self?.audioCharacterCollectionView.reloadData()
                }
            }
        }
        viewModel.onError = { error in
            self.hideSkeletonLoader()
            self.noDataView.isHidden = false
            print("Error fetching cover pages: \(error)")
        }
    }
    
    // MARK: - setupNoDataView
    private func setupNoDataView() {
        noDataView = NoDataBottomBarView()
        noDataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noDataView.isHidden = true
        self.view.addSubview(noDataView)
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: audioImageView.bottomAnchor, constant: 16),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        noDataView.layer.cornerRadius = 28
        noDataView.layer.masksToBounds = true
        noDataView.layoutIfNeeded()
    }
    
    // MARK: - setupNoInternetView
    func setupNoInternetView() {
        noInternetView = NoInternetBottombarView()
        noInternetView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        noInternetView.isHidden = true
        self.view.addSubview(noInternetView)
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noInternetView.topAnchor.constraint(equalTo: audioImageView.bottomAnchor, constant: 16),
            noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        noInternetView.layer.cornerRadius = 28
        noInternetView.layer.masksToBounds = true
        noInternetView.layoutIfNeeded()
    }
    
    // MARK: - retryButtonTapped
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
    
    private func showSkeletonLoader() {
        isLoading = true
        audioCharacterCollectionView.reloadData()
    }
    
    private func hideSkeletonLoader() {
        isLoading = false
        audioCharacterCollectionView.reloadData()
    }
    
    private func showNoInternetView() {
        self.noInternetView.isHidden = false
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
    }
    
    // MARK: - showLottieLoader
    private func showLottieLoader() {
        lottieLoader.isHidden = false
        audioImageView.isHidden = true
        lottieLoader.play()
    }
    
    // MARK: - hideLottieLoader
    private func hideLottieLoader() {
        lottieLoader.stop()
        lottieLoader.isHidden = true
        audioImageView.isHidden = false
    }
    
    // MARK: - setupLottieLoader
    private func setupLottieLoader() {
        lottieLoader.isHidden = true
        lottieLoader.loopMode = .loop
        lottieLoader.contentMode = .scaleAspectFill
        lottieLoader.animation = LottieAnimation.named("Loader")
    }
    
    // MARK: - btnDoneTapped
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        if isConnectedToInternet() {
            var audioURLToPass: String?
            var audioFileToPass: Data?
            var audioNameToPass: String?
            
            if let selectedIndex = selectedAudioIndex {
                let audioData = customAudios[selectedIndex]
                audioNameToPass = audioData.url.lastPathComponent
                if let fileData = try? Data(contentsOf: audioData.url) {
                    audioFileToPass = fileData
                    audioURLToPass = nil
                }
            }
            else if let selectedData = selectedAudioData {
                audioURLToPass = selectedData.file
                audioNameToPass = selectedData.name
                audioFileToPass = nil
            }
            
            if audioURLToPass != nil || audioFileToPass != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let nextVC = storyboard.instantiateViewController(withIdentifier: "ShareLinkVC") as? ShareLinkVC {
                    nextVC.selectedURL = audioURLToPass
                    nextVC.selectedFile = audioFileToPass
                    nextVC.selectedName = audioNameToPass
                    nextVC.selectedCoverURL = selectedCoverImageURL
                    nextVC.selectedCoverFile = selectedCoverImageFile
                    nextVC.selectedPranktype = "audio"
                    nextVC.sharePrank = true
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "No Audio Selected",
                                              message: "Please select an audio before proceeding.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
        }
    }
    
    // MARK: - btnBackTapped
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupAudioImageViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(audioImageViewTapped))
        audioImageView.isUserInteractionEnabled = true
        audioImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func audioImageViewTapped() {
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
                PauseImageView.image = UIImage(named:"PlayButton")
                PauseImageView.isHidden = false
            } else {
                startAudioPlayback()
                PauseImageView.isHidden = true
            }
            isPlaying = player.isPlaying
        }
    }
    
    private func startAudioPlayback() {
        guard let player = audioPlayer else { return }
        if player.currentTime >= player.duration {
            player.currentTime = 0
        }
        player.play()
    }
    
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
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension AudioVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == audioCustomCollectionView {
            return 1 + customAudios.count
        } else if collectionView == audioCharacterCollectionView {
            return isLoading ? 6 : viewModel.categorys.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == audioCustomCollectionView {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddAudioCollectionCell", for: indexPath) as! AddAudioCollectionCell
                cell.imageView.image = UIImage(named: "AddAudio")
                cell.addAudioLabel.text = "Add Audio"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCustomCollectionCell", for: indexPath) as! AudioCustomCollectionCell
                let audioData = customAudios[indexPath.item - 1]
                cell.imageView.image = audioData.image ?? getRandomDefaultImage()
                return cell
            }
        } else if collectionView == audioCharacterCollectionView {
            if isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCharacterCollectionCell", for: indexPath) as! AudioCharacterCollectionCell
                let category = viewModel.categorys[indexPath.item]
                if let url = URL(string: category.categoryImage) {
                    cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                }
                cell.categoryName.text = "\(category.categoryName) Sound"
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == audioCustomCollectionView {
            if indexPath.item == 0 {
                showAudioOptionsActionSheet(sourceView: collectionView.cellForItem(at: indexPath)!)
            } else {
                if let previousCharacterCell = selectedAudioCharacterCell {
                    audioCharacterCollectionView.deselectItem(at: previousCharacterCell, animated: true)
                    selectedAudioCharacterCell = nil
                }
                
                selectedAudioCustomCell = indexPath
                let audioData = customAudios[indexPath.item - 1]
                selectedAudioIndex = indexPath.item - 1
                print("Custom Audio File URL:", audioData.url)
                
                if let player = audioPlayer, player.isPlaying {
                    player.stop()
                    timer?.invalidate()
                }
                audioImageView.image = audioData.image
                setupAudioPlayer(with: audioData.url)
                audioPlayer?.play()
                isPlaying = true
                self.PauseImageView.isHidden = true
            }
        } else if collectionView == audioCharacterCollectionView {
            if let previousCustomCell = selectedAudioCustomCell {
                audioCustomCollectionView.deselectItem(at: previousCustomCell, animated: true)
                selectedAudioCustomCell = nil
            }
            
            selectedAudioCharacterCell = indexPath
            let category = viewModel.categorys[indexPath.item]
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AudioCategoryAllVC") as! AudioCategoryAllVC
            vc.categoryId = category.categoryID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 155 : 115
        let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 165 : 125
        
        if collectionView == audioCustomCollectionView {
            if indexPath.item == 0 {
                return CGSize(width: width, height: height)
            }
            return CGSize(width: width, height: height)
        } else if collectionView == audioCharacterCollectionView {
            return CGSize(width: width, height: height)
        }
        return CGSize(width: width, height: height)
    }
    
    private func showAudioOptionsActionSheet(sourceView: UIView) {
        let titleString = NSAttributedString(string: "Select Audio", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ])
        
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(titleString, forKey: "attributedTitle")
        
        let recorderAction = UIAlertAction(title: "Recorder", style: .default) { [weak self] _ in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CustomRecoderVC") as! CustomRecoderVC
            vc.delegate = self
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            self?.present(vc, animated: true)
        }
        
        let mediaPlayerAction = UIAlertAction(title: "Media player", style: .default) { [weak self] _ in
            self?.openMediaPicker()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(recorderAction)
        alertController.addAction(mediaPlayerAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
        }
        
        present(alertController, animated: true)
    }
}

extension AudioVC {
    private func saveAudios() {
        let audioData = customAudios.map { audio -> CustomAudio in
            let fileName = audio.url.lastPathComponent
            let imageFileName = audio.image?.accessibilityIdentifier ?? defaultImages[0]
            return CustomAudio(fileName: fileName, imageFileName: imageFileName)
        }
        
        if let encoded = try? JSONEncoder().encode(audioData) {
            UserDefaults.standard.set(encoded, forKey: ConstantValue.is_UserAudios)
        }
    }
    
    private func loadSavedAudios() {
        guard let data = UserDefaults.standard.data(forKey: ConstantValue.is_UserAudios),
              let savedAudios = try? JSONDecoder().decode([CustomAudio].self, from: data) else {
            return
        }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        customAudios = savedAudios.compactMap { savedAudio in
            let audioUrl = documentsDirectory.appendingPathComponent(savedAudio.fileName)
            if FileManager.default.fileExists(atPath: audioUrl.path) {
                let image = UIImage(named: savedAudio.imageFileName)
                image?.accessibilityIdentifier = savedAudio.imageFileName
                return (url: audioUrl, image: image)
            } else {
                print("File not found: \(audioUrl.path)")
                return nil
            }
        }
        DispatchQueue.main.async {
            self.audioCustomCollectionView.reloadData()
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func openMediaPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    private func setupAudioPlayer(with url: URL) {
        do {
            if let player = audioPlayer, player.isPlaying {
                player.stop()
            }
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    private func timeString(from timeInterval: Int) -> String {
        let minutes = timeInterval / 60
        let seconds = timeInterval % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func setupAudioPlayerFromURL(_ url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self,
                  let audioData = data,
                  error == nil else {
                DispatchQueue.main.async {
                    self?.hideLottieLoader()
                }
                print("Error downloading audio: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                do {
                    self.audioPlayer?.stop()
                    self.timer?.invalidate()
                    self.audioPlayer = try AVAudioPlayer(data: audioData)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.prepareToPlay()
                    self.audioPlayer?.play()
                    self.isPlaying = true
                    self.hideLottieLoader()
                } catch {
                    self.hideLottieLoader()
                    print("Error setting up audio player: \(error)")
                }
            }
        }.resume()
    }
    
    func playSelectedAudio(_ audioData: CategoryAllData) {
        if let previousCustomCell = selectedAudioCustomCell {
            audioCustomCollectionView.deselectItem(at: previousCustomCell, animated: false)
            selectedAudioCustomCell = nil
        }
        selectedAudioIndex = nil
        self.selectedAudioData = audioData
        print("Audio Name:", audioData.name)
        print("Audio File:", audioData.file ?? "No File")
        showLottieLoader()
        if let url = URL(string: audioData.image) {
            audioImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")) { [weak self] _, _, _, _ in
                self?.hideLottieLoader()
                self?.PauseImageView.isHidden = true
            }
        }
        if let audioUrl = URL(string: audioData.file!) {
            showLottieLoader()
            setupAudioPlayerFromURL(audioUrl)
        }
    }
}

// MARK: - UIDocumentPickerDelegate
extension AudioVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        
        self.showLottieLoader()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsDirectory.appendingPathComponent(selectedURL.lastPathComponent)
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.copyItem(at: selectedURL, to: destinationURL)
                let randomImage = self.getRandomDefaultImage()
                
                self.customAudios.insert((url: destinationURL, image: randomImage), at: 0)
                
                DispatchQueue.main.async {
                    self.audioCustomCollectionView.reloadData()
                    self.hideLottieLoader()
                    let indexPath = IndexPath(item: 1, section: 0)
                    self.audioCustomCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    self.collectionView(self.audioCustomCollectionView, didSelectItemAt: indexPath)
                }
            } catch {
                print("Error copying file: \(error)")
                self.hideLottieLoader()
            }
        }
    }
    
    //MARK: - getRandomDefaultImage
    private func getRandomDefaultImage() -> UIImage? {
        let randomIndex = Int.random(in: 0..<defaultImages.count)
        let imageName = defaultImages[randomIndex]
        let image = UIImage(named: imageName)
        image?.accessibilityIdentifier = imageName
        return image
    }
}

extension AudioVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isPlaying = false
            self.PauseImageView.image = UIImage(named:"PlayButton")
            self.PauseImageView.isHidden = false
            self.timer?.invalidate()
        }
    }
}

extension AudioVC: SaveRecordingDelegate {
    func didSaveRecording(audioURL: URL, name: String) {
        self.showLottieLoader()
        let randomImage = getRandomDefaultImage()
        self.customAudios.insert((url: audioURL, image: randomImage), at: 0)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.audioCustomCollectionView.reloadData()
            self.hideLottieLoader()
            let indexPath = IndexPath(item: 1, section: 0)
            self.audioCustomCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            self.collectionView(self.audioCustomCollectionView, didSelectItemAt: indexPath)
        }
    }
}

// MARK: - One time Black View Show
extension AudioVC  {
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.oneTimeBlurView.alpha = 0
        } completion: { _ in
            self.oneTimeBlurView.isHidden = true
        }
    }
    
    func isFirstLaunch() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: ConstantValue.hasLaunchedAudio) {
            return false
        } else {
            defaults.set(true, forKey: ConstantValue.hasLaunchedAudio)
            return true
        }
    }
}
