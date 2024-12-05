//
//  ViewLinkVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 01/12/24.
//

import UIKit
import Alamofire

class ViewLinkVC: UIViewController {
    
    @IBOutlet weak var viewlinkCollectionView: UICollectionView!
    @IBOutlet weak var navigationView: UIView!
    var pranks: [PrankCreateData] = []
    private var noDataView: NoDataView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipeGesture()
        setupNoDataView()
        setupCollectionView()
        fetchPranksFromUserDefaults()
    }
    
    func setupCollectionView() {
        viewlinkCollectionView.delegate = self
        viewlinkCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        viewlinkCollectionView.collectionViewLayout = layout
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
            noDataView.topAnchor.constraint(equalTo: navigationView.bottomAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func fetchPranksFromUserDefaults() {
        if let savedPranksData = UserDefaults.standard.data(forKey: "SavedPranks"),
           let savedPranks = try? JSONDecoder().decode([PrankCreateData].self, from: savedPranksData) {
            self.pranks = savedPranks.sorted { $0.id > $1.id }
            noDataView.isHidden = !pranks.isEmpty
            viewlinkCollectionView.reloadData()
        } else {
            noDataView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPranksFromUserDefaults()
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
}

// MARK: - Collection View Delegate and DataSource
extension ViewLinkVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pranks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewLinkCollectionViewCell", for: indexPath) as! ViewLinkCollectionViewCell
        
        let prank = pranks[indexPath.item]
        
        if let url = URL(string: prank.coverImage) {
            AF.request(url).response { response in
                switch response.result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.imageView.image = image
                        }
                    }
                case .failure(let error):
                    print("Image load error: \(error)")
                    cell.imageView.image = UIImage(named: "Pranksters")
                }
            }
        }
        
        cell.shareButton.tag = indexPath.item
        cell.shareButton.addTarget(self, action: #selector(shareButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: width, height: width * 1.2)
    }
    
    @objc func shareButtonTapped(_ sender: UIButton) {
        let prank = pranks[sender.tag]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareLinkPopup") as! ShareLinkPopup
        vc.coverImageURL = prank.coverImage
        vc.prankName = prank.name
        vc.prankDataURL = prank.file
        vc.prankLink = prank.link
        vc.prankType = prank.type
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
    }
}
