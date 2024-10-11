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

class CoverViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var AudioShowView: UIView!
    @IBOutlet weak var floatingButton: UIButton!
    
    @IBOutlet var floatingCollectionButton: [UIButton]!
    
    @IBOutlet weak var coverPage1CollectionView: UICollectionView!
    @IBOutlet weak var coverPage2CollectionView: UICollectionView!
    @IBOutlet weak var coverPage3CollectionView: UICollectionView!
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    var isLoading = true
    private var noDataView: NoDataView!
    private var noInternetView: NoInternetView!
    let emojiViewModel = EmojiViewModel()
    let realisticViewModel = RealisticViewModel()
    
    let plusImage = UIImage(named: "Plus")
    let cancelImage = UIImage(named: "Cancel")
    
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
        setupNoDataView()
        showSkeletonLoader()
        setupNoInternetView()
        checkInternetAndFetchData()
        
        self.coverPage2CollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        self.coverPage3CollectionView.register(SkeletonBoxCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
    }
    
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            self.fetchEmojiCoverPages()
            self.fetchRealisticCoverPages()
            self.noInternetView?.isHidden = true
        } else {
            self.showNoInternetView()
        }
    }
    
    func setupUI() {
        addBottomShadow(to: navigationbarView)
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
    
    @IBAction func btnCoverPage1ShowAllTapped(_ sender: UIButton) {
        // Implement your logic here
    }
    
    @IBAction func btnCoverPage2ShowAllTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EmojiCoverAllViewController") as! EmojiCoverAllViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCoverPage3ShowAllTapped(_ sender: UIButton) {
        // Implement your logic here
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
            let snackbar = TTGSnackbar(message: "Please turn on internet connection!", duration: .middle)
            snackbar.show()
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
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CoverViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == coverPage2CollectionView {
            return isLoading ? 10 : emojiViewModel.emojiCoverPages.count
        } else if collectionView == coverPage3CollectionView {
            return isLoading ? 10 : realisticViewModel.realisticCoverPages.count
        }
        return emojiViewModel.emojiCoverPages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == coverPage2CollectionView {
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
            if collectionView == coverPage2CollectionView {
                let coverPageData = emojiViewModel.emojiCoverPages[indexPath.row]
                handleCellSelection(coverPageData: coverPageData)
            } else if collectionView == coverPage3CollectionView {
                let coverPageData = realisticViewModel.realisticCoverPages[indexPath.row]
                handleCellSelection(coverPageData: coverPageData)
            }
        }

        private func handleCellSelection(coverPageData: CoverPageData) {
            if coverPageData.coverPremium {
                presentPremiumViewController()
            } else {
                if let imageUrl = URL(string: coverPageData.coverURL) {
                    coverImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
                }
            }
        }

        private func presentPremiumViewController() {
            let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PremiumViewController") as! PremiumViewController
            present(premiumVC, animated: true, completion: nil)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == coverPage1CollectionView {
            if indexPath.item == 0 {
                return CGSize(width: 115, height: 125)
            }
        }
        return CGSize(width: 115, height: 125)
    }
}
