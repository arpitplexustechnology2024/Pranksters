//
//  CustomCoverAllViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/10/24.
//

import UIKit

class CustomCoverAllViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var customeCoverAllCollectionView: UICollectionView!
    
    var allCustomCovers: [UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBottomShadow(to: navigationbarView)
        setupCollectionView()
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
        return cell
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
