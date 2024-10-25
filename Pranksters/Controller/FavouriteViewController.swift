//
//  FavouriteViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 22/10/24.
//

import UIKit
import Alamofire

class FavouriteViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var favouriteAllCollectionView: UICollectionView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var DoneButton: UIButton!
    private var noDataView: NoDataView!
    private var noInternetView: NoInternetView!
    private var viewModel = FavoriteViewModel()
    var isLoading = true
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        addBottomShadow(to: navigationbarView)
        setupNoDataView()
        setupNoInternetView()
        setupSegmentControl()
        checkInternetAndFetchData()
        setupViewModel()
        self.favouriteAllCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        self.DoneButton.layer.cornerRadius = 15
    }
    
    init(viewModel: FavoriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = FavoriteViewModel(apiService: FavoriteAPIService.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
    }
    
    // MARK: - UI Setup Methods
    private func setupSegmentControl() {
        segment.removeAllSegments()
        segment.insertSegment(withTitle: "Cover Page", at: 0, animated: false)
        segment.insertSegment(withTitle: "Audio", at: 1, animated: false)
        segment.insertSegment(withTitle: "Video", at: 2, animated: false)
        segment.insertSegment(withTitle: "Image", at: 3, animated: false)
        segment.selectedSegmentIndex = 0
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
    
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            let categoryId = getCategoryIdForSelectedSegment()
            viewModel.setAllFavourite(categoryId: categoryId)
            self.noInternetView?.isHidden = true
        } else {
            self.showNoInternetView()
            self.hideSkeletonLoader()
        }
    }
    
    private func getCategoryIdForSelectedSegment() -> Int {
        switch segment.selectedSegmentIndex {
        case 0:
            return 4 // Cover page category
        case 1:
            return 1 // Audio category
        case 2:
            return 2 // Video category
        case 3:
            return 3 // Image category
        default:
            return 0
        }
    }
    
    private func setupCollectionView() {
        favouriteAllCollectionView.delegate = self
        favouriteAllCollectionView.dataSource = self
        
        if let layout = favouriteAllCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    private func setupViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.hideSkeletonLoader()
                if self?.viewModel.favourites.isEmpty ?? true {
                    self?.showNoDataView()
                } else {
                    self?.hideNoDataView()
                    self?.favouriteAllCollectionView.reloadData()
                }
                self?.favouriteAllCollectionView.reloadData()
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
        favouriteAllCollectionView.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        favouriteAllCollectionView.reloadData()
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
            noDataView.topAnchor.constraint(equalTo: segment.bottomAnchor),
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
            segment.isHidden = false
            checkInternetAndFetchData()
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
        }
    }
    
    func showNoInternetView() {
        self.noInternetView.isHidden = false
        self.segment.isHidden = true
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
    
    // MARK: - Actions
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        showSkeletonLoader()
        if isConnectedToInternet() {
            let categoryId = getCategoryIdForSelectedSegment()
            viewModel.setAllFavourite(categoryId: categoryId)
        } else {
            self.showNoInternetView()
            self.hideSkeletonLoader()
        }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
    }
    
}

// MARK: - CollectionView Delegate & DataSource
extension FavouriteViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 6 : viewModel.favourites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteCollectionViewCell", for: indexPath) as! FavouriteCollectionViewCell
            let data = viewModel.favourites[indexPath.item]
            cell.configure(with: data)
            cell.onFavoriteButtonTapped = { [weak self] isFavorite in
                self?.handleFavoriteButtonTapped(for: data, isFavorite: isFavorite)
            }
            return cell
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
    
    private func handleFavoriteButtonTapped(for data: FavouriteAllData, isFavorite: Bool) {
        let categoryId = getCategoryIdForSelectedSegment()
        viewModel.setFavorite(itemId: data.itemID, isFavorite: isFavorite, categoryId: categoryId) { [weak self] success, message in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    if let index = self.viewModel.favourites.firstIndex(where: { $0.itemID == data.itemID }) {
                        self.viewModel.favourites[index].isFavorite = isFavorite
                    }
                    print(message ?? "Favorite status updated successfully")
                } else {
                    print("Failed to update favorite status: \(message ?? "Unknown error")")
                    if let cell = self.favouriteAllCollectionView.cellForItem(at: IndexPath(item: self.viewModel.favourites.firstIndex(where: { $0.itemID == data.itemID }) ?? 0, section: 0)) as? FavouriteCollectionViewCell {
                        cell.configure(with: data)
                    }
                }
            }
        }
    }
}
