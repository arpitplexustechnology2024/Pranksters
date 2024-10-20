//
//  ImageCharacterAllViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 18/10/24.
//

import UIKit
import Alamofire

class ImageCharacterAllViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var imageCharacterAllCollectionView: UICollectionView!
    private var viewModel: CharacterAllViewModel!
    private var noDataView: NoDataView!
    private var noInternetView: NoInternetView!
    private let favoriteViewModel = FavoriteViewModel()
    
    var characterId: Int = 0
    private let categoryId: Int = 3
    var isLoading = true
    
    init(viewModel: CharacterAllViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = CharacterAllViewModel(apiService: CharacterAllAPIService.shared)
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
        setupViewModel()
        showSkeletonLoader()
        setupNoDataView()
        setupNoInternetView()
        setupCollectionView()
        checkInternetAndFetchData()
        addBottomShadow(to: navigationbarView)
        self.imageCharacterAllCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
    }
    
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            viewModel.fetchAudioData(categoryId: 3, characterId: characterId)
            self.noInternetView?.isHidden = true
        } else {
            self.showNoInternetView()
            self.hideSkeletonLoader()
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
    
    private func setupCollectionView() {
        imageCharacterAllCollectionView.delegate = self
        imageCharacterAllCollectionView.dataSource = self
        if let layout = imageCharacterAllCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    private func setupViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.hideSkeletonLoader()
                if self?.viewModel.audioData.isEmpty ?? true {
                    self?.showNoDataView()
                } else {
                    self?.hideNoDataView()
                    self?.imageCharacterAllCollectionView.reloadData()
                }
                self?.imageCharacterAllCollectionView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] error in
            self?.hideSkeletonLoader()
            self?.showNoDataView()
            print("Error: \(error)")
        }
    }
    
    func showSkeletonLoader() {
        isLoading = true
        imageCharacterAllCollectionView.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        imageCharacterAllCollectionView.reloadData()
    }
    
    private func setupNoDataView() {
        noDataView = NoDataView()
        noDataView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noDataView.isHidden = true
        self.view.addSubview(noDataView)
        
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.topAnchor.constraint(equalTo: navigationbarView.bottomAnchor, constant: 30),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupNoInternetView() {
        noInternetView = NoInternetView()
        noInternetView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        noInternetView.isHidden = true
        self.view.addSubview(noInternetView)
        
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noInternetView.topAnchor.constraint(equalTo: navigationbarView.bottomAnchor, constant: 30),
            noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
    
    func showNoInternetView() {
        self.noInternetView.isHidden = false
    }
    
    func showNoDataView() {
        noDataView.isHidden = false
    }
    
    func hideNoDataView() {
        noDataView.isHidden = true
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - CollectionView Delegate & DataSource
extension ImageCharacterAllViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 8 : viewModel.audioData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCharacterAllCollectionViewCell", for: indexPath) as! ImageCharacterAllCollectionViewCell
            let audioData = viewModel.audioData[indexPath.item]
            cell.configure(with: audioData)
            cell.onFavoriteButtonTapped = { [weak self] isFavorite in
                self?.handleFavoriteButtonTapped(for: audioData, isFavorite: isFavorite)
            }
            return cell
        }
    }
    
    private func handleFavoriteButtonTapped(for audioData: CharacterAllData, isFavorite: Bool) {
        favoriteViewModel.setFavorite(itemId: audioData.itemID, isFavorite: isFavorite, categoryId: categoryId) { [weak self] success, message in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    if let index = self.viewModel.audioData.firstIndex(where: { $0.itemID == audioData.itemID }) {
                        self.viewModel.audioData[index].isFavorite = isFavorite
                    }
                    print(message ?? "Favorite status updated successfully")
                } else {
                    print("Failed to update favorite status: \(message ?? "Unknown error")")
                    if let cell = self.imageCharacterAllCollectionView.cellForItem(at: IndexPath(item: self.viewModel.audioData.firstIndex(where: { $0.itemID == audioData.itemID }) ?? 0, section: 0)) as? ImageCharacterAllCollectionViewCell {
                        cell.configure(with: audioData)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let paddingSpace = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing * (UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / (UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
        let heightPerItem: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 287 : 187
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let coverPageData = viewModel.audioData[indexPath.row]
        if coverPageData.premium {
            presentPremiumViewController()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "ImagePreviewViewController") as! ImagePreviewViewController
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.imageData = Array(viewModel.audioData[indexPath.row...])
            vc.initialIndex = 0
            self.present(vc, animated: true)
        }
    }
    
    private func presentPremiumViewController() {
        let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumViewController") as! PremiumViewController
        present(premiumVC, animated: true, completion: nil)
    }
}
