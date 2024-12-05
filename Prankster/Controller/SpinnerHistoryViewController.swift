//
//  SpinnerHistoryViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 02/12/24.
//

import UIKit

class SpinnerHistoryViewController: UIViewController {
    
    @IBOutlet weak var spinnerDataCollectionView: UICollectionView!
    
    var spinnerResponseData: [SpinnerData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinnerDataCollectionView.delegate = self
        spinnerDataCollectionView.dataSource = self
        checkAndClearExpiredData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        spinnerDataCollectionView.reloadData()
    }
    
    private func checkAndClearExpiredData() {
        guard let nextSpinTime = UserDefaults.standard.object(forKey: "nextSpinAvailableTime") as? TimeInterval else {
            return
        }
        
        let expirationTime = Date(timeIntervalSince1970: nextSpinTime)
        if expirationTime.timeIntervalSinceNow <= 0 {
            UserDefaults.standard.removeObject(forKey: "savedSpinnerData")
            spinnerResponseData.removeAll()
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension SpinnerHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spinnerResponseData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpinnerCollectionViewCell", for: indexPath) as! SpinnerCollectionViewCell
        let spinData = spinnerResponseData[indexPath.item]
        cell.configure(with: spinData) { [weak self] selectedSpinData in
            guard let self = self, let spinData = selectedSpinData else { return }
            self.dismiss(animated: true) { [self] in
                if let window = UIApplication.shared.windows.first {
                    if let rootViewController = window.rootViewController as? UINavigationController {
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpinnerPreviewVC") as! SpinnerPreviewVC
                        vc.coverImage = spinData.coverImage
                        vc.name = spinData.name
                        vc.file = spinData.file
                        vc.link = spinData.link
                        vc.type = spinData.type
                        vc.modalTransitionStyle = .crossDissolve
                        vc.modalPresentationStyle = .overCurrentContext
                        rootViewController.present(vc, animated: true)
                    }
                }
            }
        }
        cell.shareButton.tag = indexPath.item
        cell.shareButton.addTarget(self, action: #selector(shareButtonTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        let height: CGFloat = 55
        return CGSize(width: width, height: height)
    }
    
    @objc func shareButtonTapped(_ sender: UIButton) {
        let prank = spinnerResponseData[sender.tag]
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let navigationController = self.navigationController ?? UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareLinkVC") as! ShareLinkVC
                vc.coverImageURL = prank.coverImage
                vc.prankName = prank.name
                vc.prankDataURL = prank.file
                vc.prankLink = prank.link
                vc.selectedPranktype = prank.type
                vc.sharePrank = false
                navigationController.pushViewController(vc, animated: true)
            }
        }
    }
}
