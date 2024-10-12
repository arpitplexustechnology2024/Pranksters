//
//  RealisticCoverAllViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/10/24.
//

import UIKit

class RealisticCoverAllViewController: UIViewController {

    @IBOutlet weak var navigationbarView: UIView!
    
    @IBOutlet weak var realisticCoverAllCollectionView: UICollectionView!
    
    private let viewModel = RealisticViewModel()
    
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchAllCoverPages()
        
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.realisticCoverPages.count - 1 && !viewModel.isLoading && viewModel.hasMorePages {
            fetchAllCoverPages()
        }
    }
}
