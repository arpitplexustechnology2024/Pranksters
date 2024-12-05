//
//  BannerAdUtility.swift
//  GoogleAds
//
//  Created by Arpit iOS Dev. on 01/07/24.
//

import UIKit
import GoogleMobileAds

class BannerAdUtility: NSObject, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    
    func setupBannerAd(in viewController: UIViewController, adUnitID: String) {
        let viewWidth = viewController.view.frame.inset(by: viewController.view.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        
        bannerView = GADBannerView(adSize: adaptiveSize)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        guard let viewController = bannerView.rootViewController else { return }
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(bannerView)
        viewController.view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: viewController.view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: viewController.view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
}
