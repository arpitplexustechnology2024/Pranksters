//
//  InterstitialAdUtility.swift
//  GoogleAds
//
//  Created by Arpit iOS Dev. on 01/07/24.
//

import GoogleMobileAds
import UIKit

protocol InterstitialAdUtilityDelegate: AnyObject {
    func didFailToLoadInterstitial()
    func didFailToPresentInterstitial()
    func didDismissInterstitial()
}

class InterstitialAdUtility: NSObject, GADFullScreenContentDelegate {
    
    private var interstitial: GADInterstitialAd?
    weak var delegate: InterstitialAdUtilityDelegate?
    
    // Asynchronously load an interstitial ad
    func loadInterstitial(adUnitID: String) async {
        do {
            // Attempt to load the interstitial ad
            interstitial = try await GADInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest())
            interstitial?.fullScreenContentDelegate = self
            print("Interstitial ad loaded.")
        } catch {
            // Handle the error if ad loading fails
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            delegate?.didFailToLoadInterstitial()
        }
    }
    
    // Present the interstitial ad from the given view controller
    func presentInterstitial(from viewController: UIViewController) {
        guard let interstitial = interstitial else {
            print("Ad wasn't ready.")
            delegate?.didFailToPresentInterstitial()
            return
        }
        interstitial.present(fromRootViewController: viewController)
    }

    // MARK: - GADFullScreenContentDelegate
    
    // Called when the ad fails to present full screen content
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        delegate?.didFailToPresentInterstitial()
    }
    
    // Called just before the ad presents full screen content
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    // Called after the ad has been dismissed
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        delegate?.didDismissInterstitial()
    }
}
