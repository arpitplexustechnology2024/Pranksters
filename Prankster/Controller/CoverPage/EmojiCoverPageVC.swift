//
//  EmojiCoverPageVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit
import Alamofire

class EmojiCoverPageVC: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var emojiCoverAllCollectionView: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    private var noDataView: NoDataView!
    private var noInternetView: NoInternetView!
    private let viewModel = EmojiViewModel()
    private var isSearchActive = false
    private var filteredEmojiCoverPages: [CoverPageData] = []
    private var currentDataSource: [CoverPageData] {
        return isSearchActive ? filteredEmojiCoverPages : viewModel.emojiCoverPages
    }
    var isLoading = true
    private let categoryId: Int = 4
    private var isLoadingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchBar()
        self.setupNoDataView()
        self.setupSwipeGesture()
        self.showSkeletonLoader()
        self.setupNoInternetView()
        self.setupCollectionView()
        self.hideKeyboardTappedAround()
        self.checkInternetAndFetchData()
        self.filteredEmojiCoverPages = viewModel.emojiCoverPages
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handlePremiumContentUnlocked),
                name: NSNotification.Name("PremiumContentUnlocked"),
                object: nil
            )
    }
    
    @objc private func handlePremiumContentUnlocked() {
        DispatchQueue.main.async {
            self.emojiCoverAllCollectionView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupSearchBar() {
        searchbar.delegate = self
        searchbar.placeholder = "Search"
        searchbar.backgroundImage = UIImage()
        searchbar.backgroundColor = .comman
        searchbar.layer.cornerRadius = 10
        searchbar.clipsToBounds = true
    }
    
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            fetchAllCoverPages()
            self.noInternetView?.isHidden = true
            self.hideNoDataView()
        } else {
            self.showNoInternetView()
            self.hideSkeletonLoader()
        }
    }
    
    private func setupCollectionView() {
        self.emojiCoverAllCollectionView.delegate = self
        self.emojiCoverAllCollectionView.dataSource = self
        self.emojiCoverAllCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        self.emojiCoverAllCollectionView.register(
            LoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadingFooterView.reuseIdentifier
        )
        if let layout = emojiCoverAllCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.footerReferenceSize = CGSize(width: view.frame.width, height: 50)
        }
    }
    
    func fetchAllCoverPages() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        viewModel.fetchEmojiCoverPages { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingMore = false
                if success {
                    if self.viewModel.emojiCoverPages.isEmpty {
                        self.hideSkeletonLoader()
                        self.showNoDataView()
                    } else {
                        self.hideSkeletonLoader()
                        self.hideNoDataView()
                        self.emojiCoverAllCollectionView.reloadData()
                    }
                } else if let errorMessage = self.viewModel.errorMessage {
                    self.hideSkeletonLoader()
                    self.showNoDataView()
                    print("Error fetching all cover pages: \(errorMessage)")
                }
            }
        }
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
            noDataView.topAnchor.constraint(equalTo: searchbar.bottomAnchor),
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
            noInternetView.topAnchor.constraint(equalTo: searchbar.bottomAnchor),
            noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func retryButtonTapped() {
        if isConnectedToInternet() {
            noInternetView.isHidden = true
            hideNoDataView()
            checkInternetAndFetchData()
        } else {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
        }
    }
    
    func showNoInternetView() {
        self.noInternetView.isHidden = false
    }
    
    private func showNoDataView() {
        noDataView?.isHidden = false
    }
    
    private func hideNoDataView() {
        noDataView?.isHidden = true
    }
    
    func showSkeletonLoader() {
        isLoading = true
        self.emojiCoverAllCollectionView.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        self.emojiCoverAllCollectionView.reloadData()
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
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
    
    private func filterContent(with searchText: String) {
        isSearchActive = !searchText.isEmpty
        
        if searchText.isEmpty {
            filteredEmojiCoverPages = viewModel.emojiCoverPages
        } else {
            filteredEmojiCoverPages = viewModel.emojiCoverPages.filter { coverPage in
                let nameMatch = coverPage.coverName.lowercased().contains(searchText.lowercased())
                let tagMatch = coverPage.tagName.contains { tag in
                    tag.lowercased().contains(searchText.lowercased())
                }
                return nameMatch || tagMatch
            }
        }
        
        DispatchQueue.main.async {
            self.emojiCoverAllCollectionView.reloadData()
            
            if self.filteredEmojiCoverPages.isEmpty && !searchText.isEmpty {
                self.showNoDataView()
            } else {
                self.hideNoDataView()
            }
        }
    }
}

extension EmojiCoverPageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 8
        }
        return currentDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonBoxCollectionViewCell
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCoverAllCollectionViewCell", for: indexPath) as! EmojiCoverAllCollectionViewCell
            
            guard indexPath.row < currentDataSource.count else {
                return cell
            }
            
            let coverPageData = currentDataSource[indexPath.row]
            cell.delegate = self
            cell.configure(with: coverPageData)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 16
        if UIDevice.current.userInterfaceIdiom == .pad {
            let totalSpacing = spacing * 4
            let width = (collectionView.frame.width - totalSpacing) / 2
            let height = (collectionView.frame.height - spacing * 3) / 2 + 59
            return CGSize(width: width, height: height)
        } else {
            let totalSpacing = spacing * 3
            let width = collectionView.frame.width - totalSpacing
            let height = ((collectionView.frame.height - totalSpacing) / 2) + 59
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItem = viewModel.emojiCoverPages.count - 1
        if indexPath.item == lastItem && !viewModel.isLoading && viewModel.hasMorePages {
            fetchAllCoverPages()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                for: indexPath
            ) as! LoadingFooterView
            if !isLoading && !isSearchActive && viewModel.hasMorePages && !viewModel.emojiCoverPages.isEmpty {
                footer.startAnimating()
            } else {
                footer.stopAnimating()
            }
            
            return footer
        }
        return UICollectionReusableView()
    }
}

extension EmojiCoverPageVC: EmojiCoverAllCollectionViewCellDelegate {
    func didTapDoneButton(for coverPageData: CoverPageData) {
        if coverPageData.coverPremium && !PremiumManager.shared.isContentUnlocked(itemID: coverPageData.itemID) {
            presentPremiumViewController(for: coverPageData)
        } else {
            if let navigationController = self.navigationController {
                if let coverPageVC = navigationController.viewControllers.first(where: { $0 is CoverPageVC }) as? CoverPageVC {
                    coverPageVC.updateSelectedImage(with: coverPageData)
                    navigationController.popToViewController(coverPageVC, animated: true)
                }
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
}

extension EmojiCoverPageVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContent(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterContent(with: "")
    }
}
