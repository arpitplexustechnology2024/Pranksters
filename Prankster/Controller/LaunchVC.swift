//
//  LaunchVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit
//import AppTrackingTransparency
import FBSDKCoreKit

class LaunchVC: UIViewController {
    
    @IBOutlet weak var launchImageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var passedActionKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        exampleUsage()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization { status in
//                switch status {
//                case .authorized:
//                    AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_first_app_launch"))
//                default:
//                    break
//                }
//            }
//        }
//    }
    
    func exampleUsage() {
        let tracker = SnapchatEventTracker()
        tracker.trackAppInstall(
            transactionId: "3409181200909",
            hashedEmail: "8c2a47d3bdb8d3096a6479f53eac3b724291db5f1c31611100f675be5537329d"
        ) { result in
            switch result {
            case .success:
                print("App install event tracked successfully")
            case .failure(let error):
                print("Failed to track app install: \(error)")
            }
        }
    }

    
    func setupUI() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            launchImageView.image = UIImage(named: "LaunchBG-iPhone")
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            launchImageView.image = UIImage(named: "LaunchBG-iPad")
        }
        
        loadingActivityIndicator.style = .large
        loadingActivityIndicator.color = .black
        loadingActivityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.loadingActivityIndicator.stopAnimating()
            self.loadingActivityIndicator.isHidden = true
            
            if let actionKey = self.passedActionKey {
                switch actionKey {
                case "MoreActionKey":
                    self.navigateToMoreAppVC(shouldNavigateToMoreApp: true)
                case "SpinnerActionKey":
                    self.navigateToSpinnerVC(shouldNavigateToSpinner: true)
                case "PrankActionKey":
                    self.navigateToHomeVC()
                default:
                    self.navigateToHomeVC()
                }
            } else {
                self.navigateToHomeVC()
            }
        }
    }
    
    func navigateToHomeVC() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeVC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToSpinnerVC(shouldNavigateToSpinner: Bool = false) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeVC") as! HomeVC
        vc.shouldNavigateToSpinner = shouldNavigateToSpinner
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToMoreAppVC(shouldNavigateToMoreApp: Bool = false) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeVC") as! HomeVC
        vc.shouldNavigateToMoreApp = shouldNavigateToMoreApp
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
