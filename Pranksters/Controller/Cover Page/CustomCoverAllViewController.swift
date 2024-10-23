//
//  CustomCoverAllViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/10/24.
//

import UIKit

protocol CoverCustomViewControllerDelegate: AnyObject {
    func didUpdateFavoriteStatus(at index: Int, isFavorite: Bool)
    func didSelectCustomCover(image: UIImage, at index: Int)
}

class CustomCoverAllViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var customeCoverAllCollectionView: UICollectionView!
    
    private var coverPages: [CoverPageData] = []
    var allCustomCovers: [UIImage] = []
    var favoriteCustomImages: [Bool] = []
    
    private var noDataView: NoDataView!
    
    weak var delegate: CoverCustomViewControllerDelegate?
    weak var coverViewControllerDelegate: CoverPreviewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomShadow(to: navigationbarView)
        setupCollectionView()
        setupNoDataView()
        loadFavoriteStatus()
        createCoverPageData()
        updateNoDataViewVisibility()
    }
    
    private func createCoverPageData() {
        coverPages = allCustomCovers.enumerated().map { index, image in
            CoverPageData(coverURL: "",
                          coverPremium: false,
                          itemID: index,
                          isFavorite: favoriteCustomImages[index])
        }
    }
    
    private func loadFavoriteStatus() {
        favoriteCustomImages = UserDefaults.standard.array(forKey: "is_FavoriteCoverImages") as? [Bool] ?? Array(repeating: false, count: allCustomCovers.count)
    }
    
    private func saveFavoriteStatus() {
        UserDefaults.standard.set(favoriteCustomImages, forKey: "is_FavoriteCoverImages")
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
        customeCoverAllCollectionView.delegate = self
        customeCoverAllCollectionView.dataSource = self
        if let layout = customeCoverAllCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
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
            
            noDataView.layer.cornerRadius = 28
            noDataView.layer.masksToBounds = true
            
            noDataView.layoutIfNeeded()
        }
        
        private func updateNoDataViewVisibility() {
            noDataView.isHidden = !allCustomCovers.isEmpty
            customeCoverAllCollectionView.isHidden = allCustomCovers.isEmpty
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
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CustomCoverAllViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allCustomCovers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoverPage1CollectionCell", for: indexPath) as! CoverPage1CollectionCell
        cell.imageView.image = allCustomCovers[indexPath.item]
        cell.updateFavoriteButton(isFavorite: favoriteCustomImages[indexPath.item])
        
        cell.onFavoriteButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.favoriteCustomImages[indexPath.item].toggle()
            cell.updateFavoriteButton(isFavorite: self.favoriteCustomImages[indexPath.item])
            self.saveFavoriteStatus()
            self.delegate?.didUpdateFavoriteStatus(at: indexPath.item, isFavorite: self.favoriteCustomImages[indexPath.item])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CoverPreviewViewController") as! CoverPreviewViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.coverPages = Array(coverPages[indexPath.row...])
        vc.initialIndex = 0
        vc.isCustomCover = true
        vc.customImages = Array(allCustomCovers[indexPath.row...])
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let paddingSpace = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing * (UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / (UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2)
        let heightPerItem: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 287 : 187
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
}

extension CustomCoverAllViewController: CoverPreviewViewControllerDelegate {
    func coverPreviewViewController(_ viewController: CoverPreviewViewController, didSelectCoverAt index: Int, coverData: CoverPageData) {
        let actualIndex = coverPages.firstIndex(where: { $0.itemID == coverData.itemID }) ?? index
        let selectedImage = allCustomCovers[actualIndex]
        coverViewControllerDelegate?.coverPreviewViewController(viewController, didSelectCoverAt: actualIndex, coverData: coverData)
        delegate?.didSelectCustomCover(image: selectedImage, at: actualIndex)
        let temporaryDirectory = NSTemporaryDirectory()
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(fileName)
        
        print("📱 Selected Cover Data:")
        print("=====================================")
        print("Image URL: \(fileURL.absoluteString)")
        print("Is Favorite: \(coverData.isFavorite)")
        
        viewController.dismiss(animated: true) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func coverPreviewViewController(_ viewController: CoverPreviewViewController, didUpdateFavoriteStatusForItemAt index: Int, isFavorite: Bool) {
        let actualIndex = coverPages.firstIndex(where: { $0.itemID == index }) ?? index
        favoriteCustomImages[actualIndex] = isFavorite
        coverPages[actualIndex].isFavorite = isFavorite
        saveFavoriteStatus()
        customeCoverAllCollectionView.reloadItems(at: [IndexPath(item: actualIndex, section: 0)])
        delegate?.didUpdateFavoriteStatus(at: actualIndex, isFavorite: isFavorite)
        
 
    }
}
