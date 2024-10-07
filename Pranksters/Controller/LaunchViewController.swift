//
//  LaunchViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 07/10/24.
//

import UIKit
import Lottie

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var launchImageView: UIImageView!
    @IBOutlet weak var loadingView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
    }
    
    func setupUI() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            launchImageView.image = UIImage(named: "LaunchBG-iPhone")
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            launchImageView.image = UIImage(named: "LaunchBG-iPad")
        }
        if let animation = LottieAnimation.named("Loading") {
            loadingView.animation = animation
            self.loadingView.contentMode = .scaleAspectFit
            self.loadingView.loopMode = .loop
            self.loadingView.play()
            
            Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
                self.loadingView.stop()
                self.loadingView.isHidden = true
                
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeViewController") as! HomeViewController
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }
    
}
