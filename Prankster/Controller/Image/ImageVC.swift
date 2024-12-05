//
//  ImageVC.swift
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

class ImageVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var oneTimeBlurView: UIView!
    @IBOutlet weak var imageShowView: UIView!
    @IBOutlet weak var ImageImageView: UIImageView!
    @IBOutlet weak var imageCustomCollectionView: UICollectionView!
    @IBOutlet weak var imageCharacterCollectionView: UICollectionView!
    @IBOutlet weak var lottieLoader: LottieAnimationView!
    @IBOutlet weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageCustomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageCharacterHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    private var isLoading = true
    var selectedCoverImageURL: String?
    var selectedCoverImageFile: Data?
    private var selectedImageIndex: Int?
    private var selectedImageURL: String?
    private var selectedImageName: String?
    private var customImages: [UIImage] = []
    private var viewModel: CategoryViewModel!
    private var noDataView: NoDataBottomBarView!
    private var selectedImageData: CategoryAllData?
    private var selectedImageCustomCell: IndexPath?
    private var selectedImageCategoryCell: IndexPath?
    private var noInternetView: NoInternetBottombarView!
    
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = CategoryViewModel(apiService: CategoryAPIService.shared)
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupViewModel()
        self.setupNoDataView()
        self.loadSavedImages()
        self.setupSwipeGesture()
        self.setupLottieLoader()
        self.showSkeletonLoader()
        self.setupNoInternetView()
        self.checkInternetAndFetchData()
        self.navigationbarView.addBottomShadow()
    }
    
    // MARK: - checkInternetAndFetchData
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            viewModel.fetchCategorys(typeId: 3)
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
        
        self.ImageImageView.loadGif(name: "CoverGIF")
        self.ImageImageView.layer.cornerRadius = 8
        self.imageShowView.layer.cornerRadius = 8
        self.imageShowView.layer.shadowColor = UIColor.black.cgColor
        self.imageShowView.layer.shadowOpacity = 0.1
        self.imageShowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.imageShowView.layer.shadowRadius = 12
        
        self.imageCustomCollectionView.delegate = self
        self.imageCustomCollectionView.dataSource = self
        self.imageCharacterCollectionView.delegate = self
        self.imageCharacterCollectionView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.oneTimeBlurView.addGestureRecognizer(tapGesture)
        self.oneTimeBlurView.isUserInteractionEnabled = true
        self.oneTimeBlurView.isHidden = true
        if isFirstLaunch() {
            self.oneTimeBlurView.isHidden = false
        } else {
            self.oneTimeBlurView.isHidden = true
        }
        
        self.imageCharacterCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.coverImageViewHeightConstraint.constant = 280
            self.coverImageViewWidthConstraint.constant = 245
            self.scrollViewHeightConstraint.constant = 680
            self.imageCustomHeightConstraint.constant = 180
            self.imageCharacterHeightConstraint.constant = 360
        } else {
            self.coverImageViewHeightConstraint.constant = 240
            self.coverImageViewWidthConstraint.constant = 205
            self.scrollViewHeightConstraint.constant = 530
            self.imageCustomHeightConstraint.constant = 140
            self.imageCharacterHeightConstraint.constant = 280
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
                    self?.imageCharacterCollectionView.reloadData()
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
            noDataView.topAnchor.constraint(equalTo: ImageImageView.bottomAnchor, constant: 16),
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
            noInternetView.topAnchor.constraint(equalTo: ImageImageView.bottomAnchor, constant: 16),
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
        imageCharacterCollectionView.reloadData()
    }
    
    private func hideSkeletonLoader() {
        isLoading = false
        imageCharacterCollectionView.reloadData()
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
        ImageImageView.isHidden = true
        lottieLoader.play()
    }
    
    // MARK: - hideLottieLoader
    private func hideLottieLoader() {
        lottieLoader.stop()
        lottieLoader.isHidden = true
        ImageImageView.isHidden = false
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
            var imageURLToPass: String?
            var imageFileToPass: Data?
            var imageNameToPass: String?
            
            if let selectedIndex = selectedImageIndex {
                let temporaryDirectory = NSTemporaryDirectory()
                let fileName = "CustomImage_\(UUID().uuidString).jpg"
                let fileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(fileName)
                
                if let imageData = customImages[selectedIndex].jpegData(compressionQuality: 1.0) {
                    try? imageData.write(to: fileURL)
                    if let fileData = try? Data(contentsOf: fileURL) {
                        imageFileToPass = fileData
                        imageURLToPass = nil
                    }
                    imageNameToPass = "Custom Image \(selectedIndex + 1)"
                }
            } else if let selectedData = selectedImageData {
                imageURLToPass = selectedData.image
                imageNameToPass = selectedData.name
                imageFileToPass = nil
            }
            
            if imageURLToPass != nil || imageFileToPass != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let nextVC = storyboard.instantiateViewController(withIdentifier: "ShareLinkVC") as? ShareLinkVC {
                    nextVC.selectedURL = imageURLToPass
                    nextVC.selectedFile = imageFileToPass
                    nextVC.selectedName = imageNameToPass
                    nextVC.selectedCoverURL = selectedCoverImageURL
                    nextVC.selectedCoverFile = selectedCoverImageFile
                    nextVC.selectedPranktype = "gallery"
                    nextVC.sharePrank = true
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "No Image Selected",
                                              message: "Please select an image before proceeding.",
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
    
    // MARK: - updateSelectedImage
    func updateSelectedImage(with coverData: CategoryAllData) {
        selectedImageIndex = nil
        if let previousCustomCell = selectedImageCustomCell {
            imageCustomCollectionView.deselectItem(at: previousCustomCell, animated: false)
            selectedImageCustomCell = nil
        }
        showLottieLoader()
        selectedImageData = coverData
        selectedImageURL = coverData.image
        selectedImageName = coverData.name
        
        if let url = URL(string: coverData.image) {
            ImageImageView.sd_setImage(with: url, completed: { [weak self] (image, error, cacheType, imageURL) in
                self?.hideLottieLoader()
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                } else {
                    print("Image URL: \(coverData.image)")
                    print("Name: \(coverData.name)")
                }
            })
        }
    }
    
    // MARK: - setupbackSwipeGesture
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
extension ImageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCustomCollectionView {
            return 1 + customImages.count
        } else if collectionView == imageCharacterCollectionView {
            return isLoading ? 6 : viewModel.categorys.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imageCustomCollectionView {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCollectionViewCell", for: indexPath) as! AddImageCollectionViewCell
                cell.imageView.image = UIImage(named: "AddImage")
                cell.addImageLabel.text = "Add Image"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCustomCollectionViewCell", for: indexPath) as! ImageCustomCollectionViewCell
                let customImage = customImages[indexPath.item - 1]
                cell.imageView.image = customImage
                return cell
            }
        } else if collectionView == imageCharacterCollectionView {
            if isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCharacterCollectionViewCell", for: indexPath) as! ImageCharacterCollectionViewCell
                let character = viewModel.categorys[indexPath.item]
                if let url = URL(string: character.categoryImage) {
                    cell.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                }
                cell.categoryName.text = "\(character.categoryName) Image"
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == imageCustomCollectionView {
            if indexPath.item == 0 {
                showImageOptionsActionSheet(sourceView: collectionView.cellForItem(at: indexPath)!)
            } else {
                if let previousCharacterCell = selectedImageCategoryCell {
                    imageCharacterCollectionView.deselectItem(at: previousCharacterCell, animated: true)
                    selectedImageCategoryCell = nil
                }
                selectedImageCustomCell = indexPath
                showLottieLoader()
                let customImage = customImages[indexPath.item - 1]
                selectedImageIndex = indexPath.item - 1
                ImageImageView.image = customImage
                
                let temporaryDirectory = NSTemporaryDirectory()
                let fileName = "\(UUID().uuidString).jpg"
                let fileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(fileName)
                print("Image URL: \(fileURL.absoluteString)")
                hideLottieLoader()
            }
        } else if collectionView == imageCharacterCollectionView {
            if let previousCustomCell = selectedImageCustomCell {
                imageCustomCollectionView.deselectItem(at: previousCustomCell, animated: true)
                selectedImageCustomCell = nil
            }
            selectedImageCategoryCell = indexPath
            let category = viewModel.categorys[indexPath.item]
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImageCategoryAllVC") as! ImageCategoryAllVC
            vc.categoryId = category.categoryID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 155 : 115
        let height: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 165 : 125
        
        if collectionView == imageCustomCollectionView {
            if indexPath.item == 0 {
                return CGSize(width: width, height: height)
            }
            return CGSize(width: width, height: height)
        } else if collectionView == imageCharacterCollectionView {
            return CGSize(width: width, height: height)
        }
        return CGSize(width: width, height: height)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                print("Image URL: \(fileURL.absoluteString)")
            }
            
            customImages.insert((selectedImage), at: 0)
            ImageImageView.image = selectedImage
            selectedImageIndex = 0
            saveImages()
            
            DispatchQueue.main.async {
                self.imageCustomCollectionView.reloadData()
                let indexPath = IndexPath(item: 1, section: 0)
                self.imageCustomCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                self.selectedImageCustomCell = indexPath
                self.imageCustomCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.hideLottieLoader()
            }
        } else {
            hideLottieLoader()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func loadSavedImages() {
        showLottieLoader()
        if let savedImagesData = UserDefaults.standard.object(forKey: ConstantValue.is_UserImages) as? Data {
            do {
                if let decodedImages = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedImagesData) as? [UIImage] {
                    customImages = decodedImages
                    imageCustomCollectionView.reloadData()
                }
            } catch {
                print("Error decoding saved images: \(error)")
            }
        }
        selectedImageCustomCell = nil
        hideLottieLoader()
    }
    
    func saveImages() {
        if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: customImages, requiringSecureCoding: false) {
            UserDefaults.standard.set(encodedData, forKey: ConstantValue.is_UserImages)
        }
    }
}

// MARK: - One time Black View Show
extension ImageVC  {
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.oneTimeBlurView.alpha = 0
        } completion: { _ in
            self.oneTimeBlurView.isHidden = true
        }
    }
    
    func isFirstLaunch() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: ConstantValue.hasLaunchedImage) {
            return false
        } else {
            defaults.set(true, forKey: ConstantValue.hasLaunchedImage)
            return true
        }
    }
}
