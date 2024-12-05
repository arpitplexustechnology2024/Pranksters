//
//  RewardAdUtility.swift
//  GoogleAds
//
//  Created by Arpit iOS Dev. on 01/07/24.
//

import UIKit
import GoogleMobileAds

class RewardAdUtility: NSObject, GADFullScreenContentDelegate {
    
    private var rewardedAd: GADRewardedAd?
    private weak var rootViewController: UIViewController?
    private var adUnitID: String?
    
    // Closure to handle reward earning
    var onRewardEarned: (() -> Void)?
    
    func loadRewardedAd(adUnitID: String, rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.adUnitID = adUnitID
        GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded ad loaded.")
        }
    }
    
    func showRewardedAd() {
        guard let rewardedAd = rewardedAd, let rootViewController = rootViewController else {
            print("Ad wasn't ready.")
            return
        }
        rewardedAd.present(fromRootViewController: rootViewController) { [weak self] in
            let reward = rewardedAd.adReward
            print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content: \(error.localizedDescription)")
        if let adUnitID = adUnitID {
            loadRewardedAd(adUnitID: adUnitID, rootViewController: rootViewController!)
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        if let adUnitID = adUnitID {
            loadRewardedAd(adUnitID: adUnitID, rootViewController: rootViewController!)
            self.onRewardEarned?()
        }
    }
}
