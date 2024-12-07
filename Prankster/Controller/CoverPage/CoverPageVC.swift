//
//  CoverPageVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit
import Alamofire
import SDWebImage
import Photos
import Lottie

class CoverPageVC: UIViewController {
    
    // MARK: - outlet
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var oneTimeBlurView: UIView!
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var lottieLoader: LottieAnimationView!
    @IBOutlet weak var emojiCoverPageLabel: UILabel!
    @IBOutlet weak var CoverPage2ShowAllButton: UIButton!
    @IBOutlet weak var realisticCoverPageLabel: UILabel!
    @IBOutlet weak var CoverPage3ShowAllButton: UIButton!
    @IBOutlet weak var customCoverCollectionView: UICollectionView!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var realisticCollectionView: UICollectionView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customCoverHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emojiHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var realisticHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - variable
    var isLoading = true
    var selectedCustomImage: UIImage?
    var selectedCoverImageURL: String?
    var selectedCoverImageFile: Data?
    var viewType: CoverViewType = .audio
    private var selectedCoverIndex: Int?
    let emojiViewModel = EmojiViewModel()
    var customCoverImages: [UIImage] = []
    var selectedEmojiCoverIndex: IndexPath?
    var selectedCustomCoverIndex: IndexPath?
    var selectedRealisticCoverIndex: IndexPath?
    private var noDataView: NoDataBottomBarView!
    let realisticViewModel = RealisticViewModel()
    private var selectedCoverImageData: CoverPageData?
    private var noInternetView: NoInternetBottombarView!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadSavedImages()
        self.setupNoDataView()
        self.setupSwipeGesture()
        self.setupLottieLoader()
        self.showSkeletonLoader()
        self.setupNoInternetView()
        self.checkInternetAndFetchData()
        self.navigationbarView.addBottomShadow()
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handlePremiumContentUnlocked),
                name: NSNotification.Name("PremiumContentUnlocked"),
                object: nil
            )
    }
    
    @objc private func handlePremiumContentUnlocked() {
        DispatchQueue.main.async {
            self.realisticCollectionView.reloadData()
            self.emojiCollectionView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - checkInternetAndFetchData
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            self.fetchEmojiCoverPages()
            self.fetchRealisticCoverPages()
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
        
        self.coverImageView.loadGif(name: "CoverGIF")
        self.coverImageView.layer.cornerRadius = 8
        self.coverView.layer.cornerRadius = 8
        self.coverView.layer.shadowColor = UIColor.black.cgColor
        self.coverView.layer.shadowOpacity = 0.1
        self.coverView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.coverView.layer.shadowRadius = 12
        
        self.customCoverCollectionView.delegate = self
        self.customCoverCollectionView.dataSource = self
        self.emojiCollectionView.delegate = self
        self.emojiCollectionView.dataSource = self
        self.realisticCollectionView.delegate = self
        self.realisticCollectionView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.oneTimeBlurView.addGestureRecognizer(tapGesture)
        self.oneTimeBlurView.isUserInteractionEnabled = true
        self.oneTimeBlurView.isHidden = true
        if isFirstLaunch() {
            self.oneTimeBlurView.isHidden = false
        } else {
            self.oneTimeBlurView.isHidden = true
        }
        
        self.emojiCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        self.realisticCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.coverImageViewHeightConstraint.constant = 280
            self.coverImageViewWidthConstraint.constant = 245
            self.scrollViewHeightConstraint.constant = 750
            self.customCoverHeightConstraint.constant = 180
            self.emojiHeightConstraint.constant = 180
            self.realisticHeightConstraint.constant = 180
        } else {
            self.coverImageViewHeightConstraint.constant = 240
            self.coverImageViewWidthConstraint.constant = 205
            self.scrollViewHeightConstraint.constant = 600
            self.customCoverHeightConstraint.constant = 140
            self.emojiHeightConstraint.constant = 140
            self.realisticHeightConstraint.constant = 140
        }
        self.view.layoutIfNeeded()
    }
    
    // MARK: - setupLottieLoader
    private func setupLottieLoader() {
        lottieLoader.isHidden = true
        lottieLoader.loopMode = .loop
        lottieLoader.contentMode = .scaleAspectFill
        lottieLoader.animation = LottieAnimation.named("Loader")
    }
    
    // MARK: - Done Button
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        if selectedCoverImageURL != nil || selectedCoverImageFile != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            switch viewType {
            case .audio:
                if let nextVC = storyboard.instantiateViewController(identifier: "AudioVC") as? AudioVC {
                    if let imageURL = selectedCoverImageURL {
                        nextVC.selectedCoverImageURL = imageURL
                    }
                    if let imageFile = selectedCoverImageFile {
                        nextVC.selectedCoverImageFile = imageFile
                    }
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
                
            case .video:
                if let nextVC = storyboard.instantiateViewController(identifier: "VideoVC") as? VideoVC {
                    if let imageURL = selectedCoverImageURL {
                        nextVC.selectedCoverImageURL = imageURL
                    }
                    if let imageFile = selectedCoverImageFile {
                        nextVC.selectedCoverImageFile = imageFile
                    }
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
                
            case .image:
                if let nextVC = storyboard.instantiateViewController(identifier: "ImageVC") as? ImageVC {
                    if let imageURL = selectedCoverImageURL {
                        nextVC.selectedCoverImageURL = imageURL
                    }
                    if let imageFile = selectedCoverImageFile {
                        nextVC.selectedCoverImageFile = imageFile
                    }
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        } else {
            let alert = UIAlertController(title: "No Cover Selected",
                                          message: "Please select a cover before proceeding.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Custom All Data Show Button
    @IBAction func btnCoverPage1ShowAllTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let customCoverAllVC = storyboard.instantiateViewController(withIdentifier: "CustomCoverPageVC") as? CustomCoverPageVC {
            customCoverAllVC.allCustomCovers = Array(customCoverImages)
            self.navigationController?.pushViewController(customCoverAllVC, animated: true)
        }
    }
    
    // MARK: - Emoji All Data Show Button
    @IBAction func btnCoverPage2ShowAllTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EmojiCoverPageVC") as! EmojiCoverPageVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Realistic All Data Show Button
    @IBAction func btnCoverPage3ShowAllTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "RealisticCoverPageVC") as! RealisticCoverPageVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Emoji Cover Page API Call
    func fetchEmojiCoverPages() {
        emojiViewModel.resetPagination()
        emojiViewModel.fetchEmojiCoverPages { [weak self] success in
            guard let self = self else { return }
            if success {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = true
                self.emojiCollectionView.reloadData()
            } else if let errorMessage = self.emojiViewModel.errorMessage {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = false
                print("Error fetching cover pages: \(errorMessage)")
            }
        }
    }
    
    // MARK: - Realistic Cover Page API Call
    func fetchRealisticCoverPages() {
        realisticViewModel.resetPagination()
        realisticViewModel.fetchRealisticCoverPages { [weak self] success in
            guard let self = self else { return }
            if success {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = true
                self.realisticCollectionView.reloadData()
            } else if let errorMessage = self.emojiViewModel.errorMessage {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = false
                print("Error fetching cover pages: \(errorMessage)")
            }
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
            noDataView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
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
            noInternetView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
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
    
    private func showSkeletonLoader() {
        isLoading = true
        emojiCollectionView.reloadData()
        realisticCollectionView.reloadData()
    }
    
    private func hideSkeletonLoader() {
        isLoading = false
        emojiCollectionView.reloadData()
        realisticCollectionView.reloadData()
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
        coverImageView.isHidden = true
        lottieLoader.play()
    }
    
    // MARK: - hideLottieLoader
    private func hideLottieLoader() {
        lottieLoader.stop()
        lottieLoader.isHidden = true
        coverImageView.isHidden = false
    }
    // MARK: - updateSelectedImage
    func updateSelectedImage(with coverData: CoverPageData, customImage: UIImage? = nil) {
        showLottieLoader()
        selectedCoverImageData = coverData
        selectedCoverImageURL = coverData.coverURL
        
        
        if let customImage = customImage {
            self.coverImageView.image = customImage
            self.selectedCustomImage = customImage
            self.hideLottieLoader()
            
            let temporaryDirectory = NSTemporaryDirectory()
            let fileName = "\(UUID().uuidString).jpg"
            let fileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(fileName)
            
            if let imageData = customImage.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: fileURL)
                if let fileData = try? Data(contentsOf: fileURL) {
                    self.selectedCoverImageFile = fileData
                    self.selectedCoverImageURL = nil
                }
                print("Custom Cover Image URL: \(fileURL.absoluteString)")
            }
        } else if let url = URL(string: coverData.coverURL) {
            coverImageView.sd_setImage(with: url) { [weak self] (image, error, cacheType, imageURL) in
                self?.hideLottieLoader()
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                } else {
                    print("Cover URL: \(coverData.coverURL)")
                    self?.selectedCoverImageFile = nil
                }
            }
        }
    }
    
    private func getSelectedCoverPage() -> CoverPageData? {
        if let selectedIndex = selectedEmojiCoverIndex {
            return emojiViewModel.emojiCoverPages[selectedIndex.item]
        } else if let selectedIndex = selectedRealisticCoverIndex {
            return realisticViewModel.realisticCoverPages[selectedIndex.item]
        }
        return nil
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
extension CoverPageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == customCoverCollectionView {
            return 1 + customCoverImages.count
        } else if collectionView == emojiCollectionView {
            return isLoading ? 10 : emojiViewModel.emojiCoverPages.count
        } else if collectionView == realisticCollectionView {
            return isLoading ? 10 : realisticViewModel.realisticCoverPages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == customCoverCollectionView {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCoverPageCollectionCell", for: indexPath) as! AddCoverPageCollectionCell
                cell.imageView.image = UIImage(systemName: "plus")
                cell.addCoverPageLabel.text = "Cover Page"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoverPage1CollectionCell", for: indexPath) as! CoverPage1CollectionCell
                cell.imageView.image = customCoverImages[indexPath.item - 1]
                return cell
            }
        } else if collectionView == emojiCollectionView {
            if isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoverPage2CollectionCell", for: indexPath) as! CoverPage2CollectionCell
                let coverPageData = emojiViewModel.emojiCoverPages[indexPath.row]
                cell.configure(with: coverPageData)
                return cell
            }
        } else if collectionView == realisticCollectionView {
            if isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoverPage3CollectionCell", for: indexPath) as! CoverPage3CollectionCell
                let coverPageData = realisticViewModel.realisticCoverPages[indexPath.row]
                cell.configure(with: coverPageData)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isLoading else { return }
        if collectionView == customCoverCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) {
                if indexPath.item == 0 {
                    handleCoverPage1Selection(at: indexPath, sender: cell)
                } else {
                    showLottieLoader()
                    let customImage = customCoverImages[indexPath.item - 1]
                    selectedCoverIndex = indexPath.item - 1
                    coverImageView.image = customImage
                    
                    let temporaryDirectory = NSTemporaryDirectory()
                    let fileName = "\(UUID().uuidString).jpg"
                    let fileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(fileName)
                    
                    if let imageData = customImage.jpegData(compressionQuality: 1.0) {
                        try? imageData.write(to: fileURL)
                        if let fileData = try? Data(contentsOf: fileURL) {
                            self.selectedCoverImageFile = fileData
                            self.selectedCoverImageURL = nil
                        }
                        print("Custom Cover Image URL: \(fileURL.absoluteString)")
                    }
                    hideLottieLoader()
                    handleCoverPage1Selection(at: indexPath, sender: cell)
                }
            }
        } else if collectionView == emojiCollectionView {
            let coverPageData = emojiViewModel.emojiCoverPages[indexPath.item]
            self.selectedCoverImageURL = coverPageData.coverURL
            print("Emoji Cover URL: \(coverPageData.coverURL)")
            self.selectedCoverImageFile = nil
            handleCellSelection(coverPageData: coverPageData, collectionView: collectionView, indexPath: indexPath)
        } else if collectionView == realisticCollectionView {
            let coverPageData = realisticViewModel.realisticCoverPages[indexPath.item]
            self.selectedCoverImageURL = coverPageData.coverURL
            print("Realistic Cover URL: \(coverPageData.coverURL)")
            self.selectedCoverImageFile = nil
            handleCellSelection(coverPageData: coverPageData, collectionView: collectionView, indexPath: indexPath)
        }
    }
    
    private func handleCoverPage1Selection(at indexPath: IndexPath, sender: UIView) {
        if indexPath.item == 0 {
            showImageOptionsActionSheet(sourceView: sender)
        } else {
            let imageIndex = indexPath.item - 1
            let selectedImage = customCoverImages[imageIndex]
            coverImageView.image = selectedImage
            selectedCustomCoverIndex = indexPath
            deselectCellsInOtherCollectionViews(except: customCoverCollectionView)
        }
    }
    
    private func handleCellSelection(coverPageData: CoverPageData, collectionView: UICollectionView, indexPath: IndexPath) {
        if coverPageData.coverPremium && !PremiumManager.shared.isContentUnlocked(itemID: coverPageData.itemID) {
            presentPremiumViewController(for: coverPageData)
            collectionView.deselectItem(at: indexPath, animated: false)
            
            if collectionView == emojiCollectionView, let previousIndex = selectedEmojiCoverIndex {
                collectionView.selectItem(at: previousIndex, animated: false, scrollPosition: [])
            } else if collectionView == realisticCollectionView, let previousIndex = selectedRealisticCoverIndex {
                collectionView.selectItem(at: previousIndex, animated: false, scrollPosition: [])
            }
        } else {
            if let imageUrl = URL(string: coverPageData.coverURL) {
                showLottieLoader()
                coverImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder")) { [weak self] (image, error, cacheType, url) in
                    self?.hideLottieLoader()
                    if error == nil {
                        self?.updateSelectionForCollectionView(collectionView, at: indexPath)
                        self?.deselectCellsInOtherCollectionViews(except: collectionView)
                    } else {
                        print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    private func updateSelectionForCollectionView(_ collectionView: UICollectionView, at indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmojiCoverIndex = indexPath
        } else if collectionView == realisticCollectionView {
            selectedRealisticCoverIndex = indexPath
        }
    }
    
    private func deselectCellsInOtherCollectionViews(except currentCollectionView: UICollectionView) {
        if currentCollectionView != customCoverCollectionView {
            if let previousIndex = selectedCustomCoverIndex {
                customCoverCollectionView.deselectItem(at: previousIndex, animated: true)
                selectedCustomCoverIndex = nil
            }
        }
        
        if currentCollectionView != emojiCollectionView {
            if let previousIndex = selectedEmojiCoverIndex {
                emojiCollectionView.deselectItem(at: previousIndex, animated: true)
                selectedEmojiCoverIndex = nil
            }
        }
        
        if currentCollectionView != realisticCollectionView {
            if let previousIndex = selectedRealisticCoverIndex {
                realisticCollectionView.deselectItem(at: previousIndex, animated: true)
                selectedRealisticCoverIndex = nil
            }
        }
    }
    
    private func presentPremiumViewController(for coverPageData: CoverPageData) {
        let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumPopupVC") as! PremiumPopupVC
        premiumVC.setItemIDToUnlock(coverPageData.itemID)
        premiumVC.modalTransitionStyle = .crossDissolve
        premiumVC.modalPresentationStyle = .overCurrentContext
        present(premiumVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 155 : 115
        let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 165 : 125
        
        if collectionView == customCoverCollectionView {
            if indexPath.item == 0 {
                return CGSize(width: width, height: height)
            }
            return CGSize(width: width, height: height)
        } else if collectionView == emojiCollectionView {
            return CGSize(width: width, height: height)
        } else if collectionView == realisticCollectionView {
            return CGSize(width: width, height: height)
        }
        return CGSize(width: width, height: height)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CoverPageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Show ImageOptions ActionSheet
    private func showImageOptionsActionSheet(sourceView: UIView) {
        let titleString = NSAttributedString(string: "Select Image", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ])
        
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(titleString, forKey: "attributedTitle")
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.btnCameraTapped()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.btnGalleryTapped()
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
    
    // MARK: - Camera Button
    func btnCameraTapped() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.showImagePicker(for: .camera)
                    } else {
                        self.showPermissionSnackbar(for: "camera")
                    }
                }
            }
        case .authorized:
            showImagePicker(for: .camera)
        case .restricted, .denied:
            showPermissionSnackbar(for: "camera")
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
    
    // MARK: - Gallery Button
    func btnGalleryTapped() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.showImagePicker(for: .photoLibrary)
                    } else {
                        self.showPermissionSnackbar(for: "photo library")
                    }
                }
            }
        case .authorized, .limited:
            showImagePicker(for: .photoLibrary)
        case .restricted, .denied:
            showPermissionSnackbar(for: "photo library")
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }
    
    // MARK: - showImagePicker
    func showImagePicker(for sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            if sourceType == .camera {
                imagePicker.cameraDevice = .front
            }
            DispatchQueue.main.async {
                self.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("\(sourceType) is not available")
        }
    }
    
    // MARK: - Show permission snackbar
    func showPermissionSnackbar(for feature: String) {
        let messageKey: String
        
        switch feature {
        case "camera":
            messageKey = "We need access to your camera to set the profile picture."
        case "photo library":
            messageKey = "We need access to your photo library to set the profile picture."
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
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        showLottieLoader()
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            let temporaryDirectory = NSTemporaryDirectory()
            let fileName = "\(UUID().uuidString).jpg"
            let fileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(fileName)
            
            if let imageData = selectedImage.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: fileURL)
                if let fileData = try? Data(contentsOf: fileURL) {
                    self.selectedCoverImageFile = fileData
                    self.selectedCoverImageURL = nil
                }
                print("Custom Cover Image URL: \(fileURL.absoluteString)")
                
                customCoverImages.insert(selectedImage, at: 0)
                coverImageView.image = selectedImage
                selectedCoverIndex = 0
                saveImages()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.customCoverCollectionView.reloadData()
                    let indexPath = IndexPath(item: 1, section: 0)
                    self.customCoverCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                    self.selectedCustomCoverIndex = indexPath
                    self.customCoverCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    self.hideLottieLoader()
                }
            }
        } else {
            hideLottieLoader()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func loadSavedImages() {
        showLottieLoader()
        if let savedImagesData = UserDefaults.standard.object(forKey: ConstantValue.is_UserCoverImages) as? Data {
            do {
                if let decodedImages = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedImagesData) as? [UIImage] {
                    customCoverImages = decodedImages
                    customCoverCollectionView.reloadData()
                }
            } catch {
                print("Error decoding saved images: \(error)")
            }
        }
        selectedCustomCoverIndex = nil
        hideLottieLoader()
    }
    
    func saveImages() {
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: customCoverImages, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedData, forKey: ConstantValue.is_UserCoverImages)
        }
    }
}

// MARK: - One time Black View Show
extension CoverPageVC  {
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.oneTimeBlurView.alpha = 0
        } completion: { _ in
            self.oneTimeBlurView.isHidden = true
        }
    }
    
    func isFirstLaunch() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: ConstantValue.hasLaunchedCover) {
            return false
        } else {
            defaults.set(true, forKey: ConstantValue.hasLaunchedCover)
            return true
        }
    }
}

extension CoverPageVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
