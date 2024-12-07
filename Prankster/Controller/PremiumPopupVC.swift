//
//  PremiumPopupVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 21/11/24.
//

import UIKit

class PremiumPopupVC: UIViewController {
    
    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var watchAdButton: UIButton!
    private let rewardAdUtility = RewardAdUtility()
    private var itemIDToUnlock: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.premiumView.layer.cornerRadius = 13
        self.premiumButton.layer.cornerRadius = 8
        self.watchAdButton.layer.cornerRadius = 8
        setupTapGesture()
        rewardAdUtility.loadRewardedAd(adUnitID: "ca-app-pub-3940256099942544/1712485313", rootViewController: self)
        rewardAdUtility.onRewardEarned = { [weak self] in
            if let itemID = self?.itemIDToUnlock {
                PremiumManager.shared.temporarilyUnlockContent(itemID: itemID)
                self?.dismiss(animated: true) {
                    NotificationCenter.default.post(name: NSNotification.Name("PremiumContentUnlocked"), object: nil)
                }
            }
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !premiumView.frame.contains(location) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnPremiumTapped(_ sender: UIButton) {
        self.dismiss(animated: false) {
            let premiumVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PremiumBottomVC") as! PremiumBottomVC
            premiumVC.modalPresentationStyle = .custom
            premiumVC.transitioningDelegate = self
            if let topViewController = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
                topViewController.present(premiumVC, animated: true)
            }
        }
    }
    
    @IBAction func btnWatchAdTapped(_ sender: UIButton) {
        rewardAdUtility.showRewardedAd()
    }
    
    func setItemIDToUnlock(_ itemID: Int) {
        self.itemIDToUnlock = itemID
    }
    
}

extension PremiumPopupVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let customPresentationController = CustomePresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
        customPresentationController.heightPercentage = 0.8
        return customPresentationController
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? self
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? self
        }
        return self
    }
}
