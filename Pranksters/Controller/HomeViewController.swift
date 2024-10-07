//
//  HomeViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 07/10/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var moreAppView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.addBottomShadow(to: navigationbarView)
    }
    
    func setupUI() {
        self.audioView.layer.cornerRadius = 15
        self.videoView.layer.cornerRadius = 15
        self.imageView.layer.cornerRadius = 15
        self.premiumView.layer.cornerRadius = 15
        self.moreAppView.layer.cornerRadius = 15
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

}
