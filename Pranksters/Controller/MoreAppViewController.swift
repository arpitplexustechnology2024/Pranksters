//
//  MoreAppViewController.swift
//  CustomSideMenuiOSExample
//
//  Created by John Codeos on 2/9/21.
//

import UIKit
import Alamofire
import TTGSnackbar

class MoreAppViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var collectionview: UICollectionView!
    private var noDataView: NoDataView!
    private var noInternetView: NoInternetView!
    private let viewModel = MoreAppViewModel()
    private var moreDataArray: [MoreData] = []
    
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNoDataView()
        showSkeletonLoader()
        setupNoInternetView()
        checkInternetAndFetchData()
        self.addBottomShadow(to: navigationbarView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
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
            self.fetchMoreData()
            self.noInternetView?.isHidden = true
        } else {
            self.showNoInternetView()
            self.hideSkeletonLoader()
        }
    }
    
    func setupUI() {
        self.collectionview.delegate = self
        self.collectionview.dataSource = self
        self.collectionview.register(SkeletonCollectionViewCell.self, forCellWithReuseIdentifier: "SkeletonCell")
        if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    private func fetchMoreData() {
        let packageName = "id553834731"
        viewModel.fetchMoreData(packageName: packageName) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let moreDataArray):
                    self.moreDataArray = moreDataArray
                    DispatchQueue.main.async {
                        self.hideSkeletonLoader()
                        self.noDataView.isHidden = true
                        self.collectionview.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    self.hideSkeletonLoader()
                    self.noDataView.isHidden = false
                }
            }
        }
    }
    
    @objc private func appIDButtonClicked(_ sender: UIButton) {
        let index = sender.tag
        let moreData = moreDataArray[index]
        
        let appStoreURL = "https://apps.apple.com/app/id\(moreData.appID)"
        
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
    
    func showSkeletonLoader() {
        isLoading = true
        collectionview.reloadData()
    }
    
    func hideSkeletonLoader() {
        isLoading = false
        collectionview.reloadData()
    }
    
    func showNoInternetView() {
        self.noInternetView.isHidden = false
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MoreAppViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoading ? 6 : moreDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SkeletonCell", for: indexPath) as! SkeletonCollectionViewCell
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoreAppCollectionViewCell", for: indexPath) as! MoreAppCollectionViewCell
            let moreData = moreDataArray[indexPath.item]
            
            cell.configure(with: moreData)
            cell.More_App_DownloadButton.tag = indexPath.item
            cell.More_App_DownloadButton.addTarget(self, action: #selector(appIDButtonClicked(_:)), for: .touchUpInside)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let paddingSpace = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing * (UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / (UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
        let heightPerItem: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 300 : 245
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
}
