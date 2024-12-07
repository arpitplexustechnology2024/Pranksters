//
//  AudioCategoryAllVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 17/10/24.
//

import UIKit
import Alamofire

class AudioCategoryAllVC: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var audioCharacterAllCollectionView: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    var isLoading = true
    var categoryId: Int = 0
    private let typeId: Int = 1
    private var isLoadingMore = false
    private var isSearchActive = false
    private var noDataView: NoDataView!
    private var viewModel = CategoryAllViewModel()
    private var noInternetView: NoInternetView!
    private var filteredAudios: [CategoryAllData] = []
    private var currentDataSource: [CategoryAllData] {
        return isSearchActive ? filteredAudios : viewModel.audioData
    }
    
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
        self.filteredAudios = viewModel.audioData
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePremiumContentUnlocked),
            name: NSNotification.Name("PremiumContentUnlocked"),
            object: nil
        )
    }
    
    @objc private func handlePremiumContentUnlocked() {
        DispatchQueue.main.async {
            self.audioCharacterAllCollectionView.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopPlayingAudio()
    }
    
    @objc private func appDidEnterBackground() {
        if self.isViewLoaded && self.view.window != nil {
            stopPlayingAudio()
        }
    }
    
    private func stopPlayingAudio() {
        if let playingCell = AudioPlaybackManager.shared.currentlyPlayingCell,
           let playingIndexPath = AudioPlaybackManager.shared.currentlyPlayingIndexPath {
            playingCell.stopAudio()
            AudioPlaybackManager.shared.currentlyPlayingCell = nil
            AudioPlaybackManager.shared.currentlyPlayingIndexPath = nil
        }
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
            fetchAllAudios()
            self.noInternetView?.isHidden = true
            self.hideNoDataView()
        } else {
            self.showNoInternetView()
            self.hideSkeletonLoader()
        }
    }
    
    private func setupCollectionView() {
        self.audioCharacterAllCollectionView.delegate = self
        self.audioCharacterAllCollectionView.dataSource = self
        self.audioCharacterAllCollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        self.audioCharacterAllCollectionView.register(
            LoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadingFooterView.reuseIdentifier
        )
        if let layout = audioCharacterAllCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.footerReferenceSize = CGSize(width: view.frame.width, height: 50)
        }
    }
    
    // MARK: - fetchAllAudios
    func fetchAllAudios() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        viewModel.fetchAudioData(categoryId: categoryId, typeId: typeId) { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingMore = false
                if success {
                    if self.viewModel.audioData.isEmpty {
                        self.hideSkeletonLoader()
                        self.showNoDataView()
                    } else {
                        self.hideSkeletonLoader()
                        self.hideNoDataView()
                        self.audioCharacterAllCollectionView.reloadData()
                    }
                } else if let errorMessage = self.viewModel.errorMessage {
                    self.hideSkeletonLoader()
                    self.showNoDataView()
                    print("Error fetching all cover pages: \(errorMessage)")
                }
            }
        }
    }
    
    func showSkeletonLoader() {
        isLoading = true
        audioCharacterAllCollectionView.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        audioCharacterAllCollectionView.reloadData()
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
            filteredAudios = viewModel.audioData
        } else {
            filteredAudios = viewModel.audioData.filter { coverPage in
                let nameMatch = coverPage.name.lowercased().contains(searchText.lowercased())
                let categoryMatch = coverPage.artistName.lowercased().contains(searchText.lowercased())
                return nameMatch || categoryMatch
            }
        }
        
        DispatchQueue.main.async {
            self.audioCharacterAllCollectionView.reloadData()
            
            if self.filteredAudios.isEmpty && !searchText.isEmpty {
                self.showNoDataView()
            } else {
                self.hideNoDataView()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension AudioCategoryAllVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCharacterAllCollectionViewCell", for: indexPath) as! AudioCharacterAllCollectionViewCell
            guard indexPath.row < currentDataSource.count else {
                return cell
            }
            
            let audioData = currentDataSource[indexPath.row]
            cell.delegate = self
            cell.configure(with: audioData, at: indexPath)
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
        let lastItem = viewModel.audioData.count - 1
        if indexPath.item == lastItem && !viewModel.isLoading && viewModel.hasMorePages {
            self.fetchAllAudios()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                for: indexPath
            ) as! LoadingFooterView
            if !isLoading && !isSearchActive && viewModel.hasMorePages && !viewModel.audioData.isEmpty {
                footer.startAnimating()
            } else {
                footer.stopAnimating()
            }
            
            return footer
        }
        return UICollectionReusableView()
    }
}

// MARK: - AudioAllCollectionViewCellDelegate
extension AudioCategoryAllVC: AudioAllCollectionViewCellDelegate {
    func didTapAudioPlayback(at indexPath: IndexPath) {
        guard let cell = audioCharacterAllCollectionView.cellForItem(at: indexPath) as? AudioCharacterAllCollectionViewCell else {
            return
        }
        
        if AudioPlaybackManager.shared.currentlyPlayingIndexPath == indexPath {
            cell.stopAudio()
            AudioPlaybackManager.shared.currentlyPlayingCell = nil
            AudioPlaybackManager.shared.currentlyPlayingIndexPath = nil
        } else {
            cell.playAudio()
        }
    }
    
    func didTapDoneButton(for categoryAllData: CategoryAllData) {
        AudioPlaybackManager.shared.stopCurrentPlayback()
        if categoryAllData.premium && !PremiumManager.shared.isContentUnlocked(itemID: categoryAllData.itemID) {
            presentPremiumViewController(for: categoryAllData)
        } else {
            if let navigationController = self.navigationController {
                if let audioVC = navigationController.viewControllers.first(where: { $0 is AudioVC }) as? AudioVC {
                    audioVC.playSelectedAudio(categoryAllData)
                    navigationController.popToViewController(audioVC, animated: true)
                }
            }
        }
    }
    
    private func presentPremiumViewController(for categoryAllData: CategoryAllData) {
        let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumPopupVC") as! PremiumPopupVC
        premiumVC.setItemIDToUnlock(categoryAllData.itemID)
        premiumVC.modalTransitionStyle = .crossDissolve
        premiumVC.modalPresentationStyle = .overCurrentContext
        present(premiumVC, animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate
extension AudioCategoryAllVC: UISearchBarDelegate {
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
