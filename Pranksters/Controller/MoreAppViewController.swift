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
    
    @IBOutlet weak var navigationLabel: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var noInternetView: NoInternetView!
    private let viewModel = MoreAppViewModel()
    private var moreDataArray: [MoreData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNoInternetView()
        checkInternetAndFetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController()?.gestureEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.revealViewController()?.gestureEnabled = true
    }
    
    func checkInternetAndFetchData() {
        if isConnectedToInternet() {
            self.fetchMoreData()
            self.noInternetView?.isHidden = true
        } else {
            self.showNoInternetView()
        }
    }
    
    func setupUI() {
        self.collectionview.delegate = self
        self.collectionview.dataSource = self
        self.activityIndicator.style = .large
        
        if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    private func fetchMoreData() {
        let packageName = "id553834731"
        self.activityIndicator.startAnimating()
        viewModel.fetchMoreData(packageName: packageName) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let moreDataArray):
                    self.moreDataArray = moreDataArray
                    DispatchQueue.main.async {
                        self.hideLoader()
                        self.collectionview.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    self.hideLoader()
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
    
    func setupNoInternetView() {
        noInternetView = NoInternetView()
        noInternetView.retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        noInternetView.isHidden = true
        self.view.addSubview(noInternetView)
        
        noInternetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noInternetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noInternetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noInternetView.topAnchor.constraint(equalTo: navigationLabel.bottomAnchor, constant: 10),
            noInternetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func retryButtonTapped() {
        if isConnectedToInternet() {
            noInternetView.isHidden = true
            checkInternetAndFetchData()
        } else {
            let snackbar = TTGSnackbar(message: "Please turn on internet connection!", duration: .middle)
            snackbar.show()
        }
    }
    
    func hideLoader() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
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
        return moreDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoreAppCollectionViewCell", for: indexPath) as! MoreAppCollectionViewCell
        let moreData = moreDataArray[indexPath.item]
        
        cell.configure(with: moreData)
        cell.More_App_DownloadButton.tag = indexPath.item
        cell.More_App_DownloadButton.addTarget(self, action: #selector(appIDButtonClicked(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let paddingSpace = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing * (UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1)
            let availableWidth = collectionView.frame.width - paddingSpace
            let widthPerItem = availableWidth / (UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
            return CGSize(width: widthPerItem, height: 241)
        }
    
}
