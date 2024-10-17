//
//  CoverViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 09/10/24.
//

import UIKit
import Alamofire
import TTGSnackbar
import SDWebImage
import Photos
import Lottie

class CoverViewController: UIViewController, CoverCustomViewControllerDelegate {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var AudioShowView: UIView!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet var floatingCollectionButton: [UIButton]!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var favoriteCustomImages: [Bool] = []
    
    @IBOutlet weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverPage1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverPage2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverPage3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverPage1CollectionView: UICollectionView!
    @IBOutlet weak var coverPage2CollectionView: UICollectionView!
    @IBOutlet weak var coverPage3CollectionView: UICollectionView!
    
    @IBOutlet weak var lottieLoader: LottieAnimationView!
    
    @IBOutlet weak var oneTimeBlurView: UIView!
    
    var selectedCoverPage1Index: IndexPath?
    var selectedCoverPage2Index: IndexPath?
    var selectedCoverPage3Index: IndexPath?
    var userSelectedImages: [UIImage] = []
    private let maxVisibleCustomCovers = 9
    
    var isLoading = true
    private var noDataView: NoDataBottomBarView!
    private var noInternetView: NoInternetBottombarView!
    let emojiViewModel = EmojiViewModel()
    let realisticViewModel = RealisticViewModel()
    
    let plusImage = UIImage(named: "Plus")
    let cancelImage = UIImage(named: "Cancel")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
        
        if let selectedIndexPath = coverPage1CollectionView.indexPathsForSelectedItems?.first {
            coverPage1CollectionView.deselectItem(at: selectedIndexPath, animated: false)
        }
        selectedCoverPage1Index = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNoDataView()
        showSkeletonLoader()
        setupNoInternetView()
        checkInternetAndFetchData()
        loadSavedImages()
        setupLottieLoader()
        applyBlurEffect()
        self.oneTimeBlurView.isHidden = true
        
        if isFirstLaunch() {
            self.oneTimeBlurView.isHidden = false
        } else {
            self.oneTimeBlurView.isHidden = true
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        oneTimeBlurView.addGestureRecognizer(tapGesture)
        oneTimeBlurView.isUserInteractionEnabled = true
        self.coverPage2CollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        self.coverPage3CollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        self.favouriteButton.isHidden = true
        coverImageView.loadGif(name: "Boy")
        updateFavoriteButton(isFavorite: false)
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Set heights for iPad
            coverImageViewHeightConstraint.constant = 280
            coverImageViewWidthConstraint.constant = 245
            scrollViewHeightConstraint.constant = 750
            coverPage1HeightConstraint.constant = 180
            coverPage2HeightConstraint.constant = 180
            coverPage3HeightConstraint.constant = 180
        } else {
            // Set heights for iPhone
            coverImageViewHeightConstraint.constant = 240
            coverImageViewWidthConstraint.constant = 205
            scrollViewHeightConstraint.constant = 600
            coverPage1HeightConstraint.constant = 140
            coverPage2HeightConstraint.constant = 140
            coverPage3HeightConstraint.constant = 140
        }
        
        self.view.layoutIfNeeded()
    }
    
    func applyBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = oneTimeBlurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.5
        oneTimeBlurView.addSubview(blurEffectView)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.oneTimeBlurView.alpha = 0
        } completion: { _ in
            self.oneTimeBlurView.isHidden = true
        }
    }
    
    func isFirstLaunch() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "hasLaunchedBefore") {
            return false
        } else {
            defaults.set(true, forKey: "hasLaunchedBefore")
            return true
        }
    }
    
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
    
    func setupUI() {
        addBottomShadow(to: navigationbarView)
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
        setupFloatingButtons()
        coverImageView.layer.cornerRadius = 8
        AudioShowView.layer.cornerRadius = 8
        
        coverPage1CollectionView.delegate = self
        coverPage1CollectionView.dataSource = self
        
        coverPage2CollectionView.delegate = self
        coverPage2CollectionView.dataSource = self
        
        coverPage3CollectionView.delegate = self
        coverPage3CollectionView.dataSource = self
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
        view.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                          y: view.bounds.maxY - 4,
                                                          width: view.bounds.width,
                                                          height: 4)).cgPath
    }
    
    private func setupLottieLoader() {
        lottieLoader.isHidden = true
        lottieLoader.loopMode = .loop
        lottieLoader.contentMode = .scaleAspectFill
        lottieLoader.animation = LottieAnimation.named("Loader")
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
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AudioViewController") as! AudioViewController
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didSelectCustomCover(image: UIImage, at index: Int) {
        coverImageView.image = image
        selectedCoverPage1Index = IndexPath(item: index + 1, section: 0)
        deselectCellsInOtherCollectionViews(except: coverPage1CollectionView)
        updateFavoriteButton(isFavorite: favoriteCustomImages[index])
    }
    
    @IBAction func btnCoverPage1ShowAllTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let customCoverAllVC = storyboard.instantiateViewController(withIdentifier: "CustomCoverAllViewController") as? CustomCoverAllViewController {
            customCoverAllVC.allCustomCovers = Array(userSelectedImages)
            customCoverAllVC.delegate = self
            customCoverAllVC.coverViewControllerDelegate = self
            self.navigationController?.pushViewController(customCoverAllVC, animated: true)
        }
    }
    
    func didUpdateFavoriteStatus(at index: Int, isFavorite: Bool) {
        favoriteCustomImages[index] = isFavorite
        saveImages()
        coverPage1CollectionView.reloadItems(at: [IndexPath(item: index + 1, section: 0)])
        
        if let selectedIndex = selectedCoverPage1Index, selectedIndex.item - 1 == index {
            updateFavoriteButton(isFavorite: isFavorite)
        }
    }
    
    @IBAction func btnCoverPage2ShowAllTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EmojiCoverAllViewController") as! EmojiCoverAllViewController
        vc.coverViewControllerDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCoverPage3ShowAllTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "RealisticCoverAllViewController") as! RealisticCoverAllViewController
        vc.coverViewControllerDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func fetchEmojiCoverPages() {
        emojiViewModel.resetPagination()
        emojiViewModel.fetchEmojiCoverPages { [weak self] success in
            guard let self = self else { return }
            if success {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = true
                self.coverPage2CollectionView.reloadData()
            } else if let errorMessage = self.emojiViewModel.errorMessage {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = false
                print("Error fetching cover pages: \(errorMessage)")
            }
        }
    }
    
    func fetchRealisticCoverPages() {
        realisticViewModel.resetPagination()
        realisticViewModel.fetchRealisticCoverPages { [weak self] success in
            guard let self = self else { return }
            if success {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = true
                self.coverPage3CollectionView.reloadData()
            } else if let errorMessage = self.emojiViewModel.errorMessage {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = false
                print("Error fetching cover pages: \(errorMessage)")
            }
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
            noDataView.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 16),
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
    
    func showSkeletonLoader() {
        isLoading = true
        coverPage2CollectionView.reloadData()
        coverPage3CollectionView.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        coverPage2CollectionView.reloadData()
        coverPage3CollectionView.reloadData()
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
        coverImageView.isHidden = true
        favouriteButton.isHidden = true
        lottieLoader.play()
    }
    
    func hideLottieLoader() {
        lottieLoader.stop()
        lottieLoader.isHidden = true
        coverImageView.isHidden = false
        favouriteButton.isHidden = false
    }
    
    func loadSavedImages() {
        if let savedImages = UserDefaults.standard.object(forKey: "userSelectedImages") as? Data,
           let decodedImages = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedImages) as? [UIImage] {
            userSelectedImages = decodedImages
            
            favoriteCustomImages = UserDefaults.standard.array(forKey: "favoriteCustomImages") as? [Bool] ?? Array(repeating: false, count: decodedImages.count)
            
            coverPage1CollectionView.reloadData()
            
            if let lastImage = userSelectedImages.last,
               let lastIndex = userSelectedImages.indices.last {
                coverImageView.image = lastImage
                updateFavoriteButton(isFavorite: favoriteCustomImages[lastIndex])
            } else {
                updateFavoriteButton(isFavorite: false)
            }
            selectedCoverPage1Index = nil
        } else {
            updateFavoriteButton(isFavorite: false)
        }
    }
    
    func saveImages() {
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: userSelectedImages, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedData, forKey: "userSelectedImages")
            UserDefaults.standard.set(favoriteCustomImages, forKey: "favoriteCustomImages")
        }
    }
    
    
    @IBAction func btnFavouriteSetTapped(_ sender: UIButton) {
        if let selectedIndex = selectedCoverPage1Index, selectedIndex.item > 0 {
            let imageIndex = selectedIndex.item - 1
            favoriteCustomImages[imageIndex].toggle()
            updateFavoriteButton(isFavorite: favoriteCustomImages[imageIndex])
            saveImages()
            coverPage1CollectionView.reloadItems(at: [selectedIndex])
        } else if let selectedCoverPage = getSelectedCoverPage() {
            
            let favoriteViewModel = FavoriteViewModel()
            let newFavoriteStatus = !selectedCoverPage.isFavorite
            let categoryId: Int = 4
            
            favoriteViewModel.setFavorite(itemId: selectedCoverPage.itemID, isFavorite: newFavoriteStatus, categoryId: categoryId) { [weak self] success, message in
                guard let self = self else { return }
                
                if success {
                    self.updateFavoriteStatus(newStatus: newFavoriteStatus)
                    print(message ?? "Favorite status updated successfully")
                } else {
                    print("Failed to update favorite status: \(message ?? "Unknown error")")
                }
            }
        }
    }
    
    private func getSelectedCoverPage() -> CoverPageData? {
        if let selectedIndex = selectedCoverPage2Index {
            return emojiViewModel.emojiCoverPages[selectedIndex.item]
        } else if let selectedIndex = selectedCoverPage3Index {
            return realisticViewModel.realisticCoverPages[selectedIndex.item]
        }
        return nil
    }
    
    private func updateFavoriteStatus(newStatus: Bool) {
        if let selectedIndex = selectedCoverPage2Index {
            emojiViewModel.emojiCoverPages[selectedIndex.item].isFavorite = newStatus
        } else if let selectedIndex = selectedCoverPage3Index {
            realisticViewModel.realisticCoverPages[selectedIndex.item].isFavorite = newStatus
        }
        updateFavoriteButton(isFavorite: newStatus)
    }
    
    func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "Heart_Fill" : "Heart"
        favouriteButton.setImage(UIImage(named: imageName), for: .normal)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == coverPage1CollectionView {
            return min(userSelectedImages.count + 1, maxVisibleCustomCovers + 1)
        } else if collectionView == coverPage2CollectionView {
            return isLoading ? 10 : emojiViewModel.emojiCoverPages.count
        } else if collectionView == coverPage3CollectionView {
            return isLoading ? 10 : realisticViewModel.realisticCoverPages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == coverPage1CollectionView {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCoverPageCollectionCell", for: indexPath) as! AddCoverPageCollectionCell
                cell.imageView.image = UIImage(systemName: "plus")
                cell.addCoverPageLabel.text = "Cover Page"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoverPage1CollectionCell", for: indexPath) as! CoverPage1CollectionCell
                cell.imageView.image = userSelectedImages[indexPath.item - 1]
                return cell
            }
        } else if collectionView == coverPage2CollectionView {
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
        } else if collectionView == coverPage3CollectionView {
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
        if collectionView == coverPage1CollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) {
                handleCoverPage1Selection(at: indexPath, sender: cell)
            }
        } else if collectionView == coverPage2CollectionView {
            self.favouriteButton.isHidden = false
            let coverPageData = emojiViewModel.emojiCoverPages[indexPath.row]
            handleCellSelection(coverPageData: coverPageData, collectionView: collectionView, indexPath: indexPath)
        } else if collectionView == coverPage3CollectionView {
            self.favouriteButton.isHidden = false
            let coverPageData = realisticViewModel.realisticCoverPages[indexPath.row]
            handleCellSelection(coverPageData: coverPageData, collectionView: collectionView, indexPath: indexPath)
        }
    }
    
    private func handleCoverPage1Selection(at indexPath: IndexPath, sender: UIView) {
        if indexPath.item == 0 {
            presentImageSourceOptions(sender: sender)
        } else {
            self.favouriteButton.isHidden = false
            let imageIndex = indexPath.item - 1
            let selectedImage = userSelectedImages[imageIndex]
            coverImageView.image = selectedImage
            selectedCoverPage1Index = indexPath
            deselectCellsInOtherCollectionViews(except: coverPage1CollectionView)
            updateFavoriteButton(isFavorite: favoriteCustomImages[imageIndex])
        }
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
    
    func showPermissionSnackbar(for feature: String) {
        let messageKey: String
        
        switch feature {
        case "camera":
            messageKey = "We need to access to your camera to use the set profile picture."
        case "photo library":
            messageKey = "We need to access to your photo library to use the set profile picture."
        default:
            messageKey = "SnackbarDefaultPermissionAccess"
        }
        
        let localizedMessage = NSLocalizedString(messageKey, comment: "")
        let settingsText = NSLocalizedString("Settings", comment: "")
        
        let snackbar = Snackbar(message: localizedMessage)
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
        
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            snackbar.show(in: keyWindow, duration: 5.0)
        }
    }
    
    
    // MARK: - Existing methods
    private func presentImageSourceOptions(sender: UIView) {
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
        
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleCellSelection(coverPageData: CoverPageData, collectionView: UICollectionView, indexPath: IndexPath) {
        if coverPageData.coverPremium {
            presentPremiumViewController()
            collectionView.deselectItem(at: indexPath, animated: false)
            
            if collectionView == coverPage2CollectionView, let previousIndex = selectedCoverPage2Index {
                collectionView.selectItem(at: previousIndex, animated: false, scrollPosition: [])
            } else if collectionView == coverPage3CollectionView, let previousIndex = selectedCoverPage3Index {
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
                        
                        self?.updateFavoriteButton(isFavorite: coverPageData.isFavorite)
                    } else {
                        print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    private func updateSelectionForCollectionView(_ collectionView: UICollectionView, at indexPath: IndexPath) {
        if collectionView == coverPage2CollectionView {
            selectedCoverPage2Index = indexPath
        } else if collectionView == coverPage3CollectionView {
            selectedCoverPage3Index = indexPath
        }
    }
    
    private func deselectCellsInOtherCollectionViews(except currentCollectionView: UICollectionView) {
        if currentCollectionView != coverPage1CollectionView {
            if let previousIndex = selectedCoverPage1Index {
                coverPage1CollectionView.deselectItem(at: previousIndex, animated: true)
                selectedCoverPage1Index = nil
            }
        }
        
        if currentCollectionView != coverPage2CollectionView {
            if let previousIndex = selectedCoverPage2Index {
                coverPage2CollectionView.deselectItem(at: previousIndex, animated: true)
                selectedCoverPage2Index = nil
            }
        }
        
        if currentCollectionView != coverPage3CollectionView {
            if let previousIndex = selectedCoverPage3Index {
                coverPage3CollectionView.deselectItem(at: previousIndex, animated: true)
                selectedCoverPage3Index = nil
            }
        }
    }
    
    private func presentPremiumViewController() {
        let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumViewController") as! PremiumViewController
        present(premiumVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 155 : 115
        let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 165 : 125
        
        if collectionView == coverPage1CollectionView {
            if indexPath.item == 0 {
                return CGSize(width: width, height: height)
            }
            return CGSize(width: width, height: height)
        } else if collectionView == coverPage2CollectionView {
            return CGSize(width: width, height: height)
        } else if collectionView == coverPage3CollectionView {
            return CGSize(width: width, height: height)
        }
        return CGSize(width: width, height: height)
    }
}

// MARK: - Photo Library Methods
extension CoverViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            if userSelectedImages.isEmpty {
                userSelectedImages.append(selectedImage)
                favoriteCustomImages.append(false)
            } else {
                userSelectedImages.insert(selectedImage, at: 0)
                favoriteCustomImages.insert(false, at: 0)
            }
            
            coverImageView.image = selectedImage
            coverPage1CollectionView.reloadData()
            self.favouriteButton.isHidden = false
            saveImages()
            
            let indexPath = IndexPath(item: 1, section: 0)
            coverPage1CollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            selectedCoverPage1Index = indexPath
            
            deselectCellsInOtherCollectionViews(except: coverPage1CollectionView)
            
            updateFavoriteButton(isFavorite: false)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension CoverViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class CustomPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0, y: containerView.bounds.height / 2, width: containerView.bounds.width, height: containerView.bounds.height / 2)
    }
}

extension CoverViewController: CoverPreviewViewControllerDelegate {
    func coverPreviewViewController(_ viewController: CoverPreviewViewController, didUpdateFavoriteStatusForItemAt index: Int, isFavorite: Bool) {
        if index < emojiViewModel.emojiCoverPages.count {
            emojiViewModel.emojiCoverPages[index].isFavorite = isFavorite
            coverPage2CollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else if index < realisticViewModel.realisticCoverPages.count {
            realisticViewModel.realisticCoverPages[index].isFavorite = isFavorite
            coverPage3CollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else if index < userSelectedImages.count {
            favoriteCustomImages[index] = isFavorite
            coverPage1CollectionView.reloadItems(at: [IndexPath(item: index + 1, section: 0)])
        }
    }
    
    func coverPreviewViewController(_ viewController: CoverPreviewViewController, didSelectCoverAt index: Int, coverData: CoverPageData) {
        if let imageUrl = URL(string: coverData.coverURL) {
            showLottieLoader()
            coverImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder")) { [weak self] (image, error, cacheType, url) in
                self?.hideLottieLoader()
                if error == nil {
                    self?.updateFavoriteButton(isFavorite: coverData.isFavorite)
                } else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}
