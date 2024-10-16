//
//  RealisticCoverAllViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/10/24.
//

import UIKit
import Alamofire

class RealisticCoverAllViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    
    @IBOutlet weak var realisticCoverAllCollectionView: UICollectionView!
    
    private let viewModel = RealisticViewModel()
    private let favoriteViewModel = FavoriteViewModel()
    private var noDataView: NoDataView!
    private var noInternetView: NoInternetView!
    
    var isLoading = true
    
    private let categoryId: Int = 4
    
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            fetchAllCoverPages()
            self.noInternetView?.isHidden = true
        } else {
            self.showNoInternetView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        checkInternetAndFetchData()
        
        showSkeletonLoader()
        
        self.realisticCoverAllCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
    }
    
    private func setupCollectionView() {
        realisticCoverAllCollectionView.delegate = self
        realisticCoverAllCollectionView.dataSource = self
        if let layout = realisticCoverAllCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    func fetchAllCoverPages() {
        viewModel.fetchRealisticCoverPages { [weak self] success in
            guard let self = self else { return }
            if success {
                self.hideSkeletonLoader()
                self.realisticCoverAllCollectionView.reloadData()
            } else if let errorMessage = self.viewModel.errorMessage {
                self.hideSkeletonLoader()
                self.noDataView.isHidden = false
                print("Error fetching all cover pages: \(errorMessage)")
            }
        }
    }
    
    func showSkeletonLoader() {
        isLoading = true
        realisticCoverAllCollectionView.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        realisticCoverAllCollectionView.reloadData()
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)

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
            noDataView.topAnchor.constraint(equalTo: navigationbarView.bottomAnchor),
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
            noInternetView.topAnchor.constraint(equalTo: navigationbarView.bottomAnchor),
            noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func retryButtonTapped() {
        if isConnectedToInternet() {
            noInternetView.isHidden = true
            noDataView.isHidden = true
            checkInternetAndFetchData()
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: UIColor(hexString: "#322F35"))
            snackbar.show(in: self.view, duration: 3.0)
        }
    }
    
    func showNoInternetView() {
        self.noInternetView.isHidden = false
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
    }
    
}

extension RealisticCoverAllViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 8 : viewModel.realisticCoverPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RealisticCoverAllCollectionViewCell", for: indexPath) as! RealisticCoverAllCollectionViewCell
            let coverPageData = viewModel.realisticCoverPages[indexPath.row]
            cell.configure(with: coverPageData)
            cell.onFavoriteButtonTapped = { [weak self] isFavorite in
                self?.handleFavoriteButtonTapped(for: coverPageData, isFavorite: isFavorite)
            }
            return cell
        }
    }
    
    private func handleFavoriteButtonTapped(for coverPageData: CoverPageData, isFavorite: Bool) {
        favoriteViewModel.setFavorite(itemId: coverPageData.itemID, isFavorite: isFavorite, categoryId: categoryId) { [weak self] success, message in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    if let index = self.viewModel.realisticCoverPages.firstIndex(where: { $0.itemID == coverPageData.itemID }) {
                        self.viewModel.realisticCoverPages[index].isFavorite = isFavorite
                    }
                    print(message ?? "Favorite status updated successfully")
                } else {
                    print("Failed to update favorite status: \(message ?? "Unknown error")")
                    // Revert the favorite status in the UI
                    if let cell = self.realisticCoverAllCollectionView.cellForItem(at: IndexPath(item: self.viewModel.realisticCoverPages.firstIndex(where: { $0.itemID == coverPageData.itemID }) ?? 0, section: 0)) as? RealisticCoverAllCollectionViewCell {
                        cell.configure(with: coverPageData)
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.realisticCoverPages.count - 1 && !viewModel.isLoading && viewModel.hasMorePages {
            fetchAllCoverPages()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let coverPageData = viewModel.realisticCoverPages[indexPath.row]
        if coverPageData.coverPremium {
            presentPremiumViewController()
        } else {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CoverPreviewViewController") as! CoverPreviewViewController
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.coverPages = Array(viewModel.realisticCoverPages[indexPath.row...])
            vc.initialIndex = 0
            self.present(vc, animated: true)
        }
    }
    
    private func presentPremiumViewController() {
        let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumViewController") as! PremiumViewController
        present(premiumVC, animated: true, completion: nil)
    }
}
