//
//  ImageViewController.swift
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

class ImageViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var AudioShowView: UIView!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet var floatingCollectionButton: [UIButton]!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var audioCustomCollectionView: UICollectionView!
    @IBOutlet weak var audioCharacterCollectionView: UICollectionView!
    @IBOutlet weak var lottieLoader: LottieAnimationView!
    @IBOutlet weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioCustomHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var audioCharacterHeightConstraint: NSLayoutConstraint!
    
    let plusImage = UIImage(named: "Plus")
    let cancelImage = UIImage(named: "Cancel")
    
    private var selectedAudioIndex: Int?
    
    private var customAudios: [(url: URL, image: UIImage?, isFavorite: Bool?)] = [] {
        didSet {
            
        }
    }
    
    private var currentAudioIsFavorite: Bool = false {
        didSet {
            updateFavoriteButtonImage()
        }
    }
    
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
    }
    
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            viewModel.fetchCharacters(categoryId: 3)
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
        audioImageView.layer.cornerRadius = 8
        AudioShowView.layer.cornerRadius = 8
        self.audioCharacterCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        audioCustomCollectionView.delegate = self
        audioCustomCollectionView.dataSource = self
        audioCharacterCollectionView.delegate = self
        audioCharacterCollectionView.dataSource = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            coverImageViewHeightConstraint.constant = 280
            coverImageViewWidthConstraint.constant = 245
            scrollViewHeightConstraint.constant = 680
            audioCustomHeightConstraint.constant = 180
            audioCharacterHeightConstraint.constant = 360
        } else {
            coverImageViewHeightConstraint.constant = 240
            coverImageViewWidthConstraint.constant = 205
            scrollViewHeightConstraint.constant = 530
            audioCustomHeightConstraint.constant = 140
            audioCharacterHeightConstraint.constant = 280
        }
        self.view.layoutIfNeeded()
    }
    
    func setupViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.hideSkeletonLoader()
                self?.noDataView.isHidden = true
                self?.audioCharacterCollectionView.reloadData()
                
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
            noDataView.topAnchor.constraint(equalTo: audioImageView.bottomAnchor, constant: 16),
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
            noInternetView.topAnchor.constraint(equalTo: audioImageView.bottomAnchor, constant: 16),
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
        audioCharacterCollectionView.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        audioCharacterCollectionView.reloadData()
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
        audioImageView.isHidden = true
        favouriteButton.isHidden = true
        lottieLoader.play()
    }
    
    func hideLottieLoader() {
        lottieLoader.stop()
        lottieLoader.isHidden = true
        audioImageView.isHidden = false
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
    
    @IBAction func btnFavouriteSetTapped(_ sender: UIButton) {
        guard let selectedIndex = selectedAudioIndex else { return }
        updateFavoriteButtonImage()
        currentAudioIsFavorite.toggle()
        customAudios[selectedIndex].isFavorite = currentAudioIsFavorite
        audioCustomCollectionView.reloadItems(at: [IndexPath(item: selectedIndex + 1, section: 0)])
    }
}

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == audioCustomCollectionView {
            return 1 + customAudios.count
        } else if collectionView == audioCharacterCollectionView {
            return isLoading ? 6 : viewModel.characters.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == audioCustomCollectionView {
            if indexPath.item == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddAudioCollectionCell", for: indexPath) as! AddAudioCollectionCell
                cell.imageView.image = UIImage(named: "AddAudio")
                cell.addAudioLabel.text = "Add Image"
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCustomCollectionCell", for: indexPath) as! AudioCustomCollectionCell
                return cell
            }
        } else if collectionView == audioCharacterCollectionView {
            if isLoading {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCharacterCollectionCell", for: indexPath) as! AudioCharacterCollectionCell
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
        if collectionView == audioCustomCollectionView {
            if indexPath.item == 0 {
                showImageOptionsActionSheet(sourceView: collectionView.cellForItem(at: indexPath)!)
            } else {
                let audioData = customAudios[indexPath.item - 1]
                selectedAudioIndex = indexPath.item - 1
                audioImageView.image = audioData.image
                currentAudioIsFavorite = audioData.isFavorite ?? false
                updateFavoriteButtonImage()
            }
        } else if collectionView == audioCharacterCollectionView {
            let character = viewModel.characters[indexPath.item]
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AudioCharacterAllViewController") as! AudioCharacterAllViewController
            vc.characterId = character.characterID
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
}

extension ImageViewController {
    private func showImageOptionsActionSheet(sourceView: UIView) {
        let titleString = NSAttributedString(string: "Select Audio", attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
        ])
        
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alertController.setValue(titleString, forKey: "attributedTitle")
        
        let recorderAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            // Handle recorder action
        }
        
        let mediaPlayerAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            // Handle recorder action
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
    
    private func updateFavoriteButtonImage() {
        let imageName = currentAudioIsFavorite ? "Heart_Fill" : "Heart"
        favouriteButton.setImage(UIImage(named: imageName), for: .normal)
    }
}
