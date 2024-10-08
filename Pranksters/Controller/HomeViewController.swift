//
//  ViewController.swift
//  CustomSideMenuiOSExample
//
//  Created by John Codeos on 2/§/21.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var moreAppView: UIView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var spinerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.seupViewAction()
        self.addBottomShadow(to: navigationbarView)
        
        if let revealVC = self.revealViewController() {
            self.sideMenuButton.addTarget(revealVC, action: #selector(revealVC.revealSideMenu), for: .touchUpInside)
        }
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
    
    func seupViewAction() {
        
        let tapGestureActions: [(UIView, Selector)] = [
            (audioView, #selector(btnAudioTapped)),
            (videoView, #selector(btnVideoTapped)),
            (imageView, #selector(btnImageTapped)),
            (premiumView, #selector(btnPremiumTapped)),
            (moreAppView, #selector(btnMoreAppTapped)),
        ]
        
        tapGestureActions.forEach { view, action in
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        }
    }
    
    @objc func btnAudioTapped(_ sender: UITapGestureRecognizer){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CoverViewController") as! CoverViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnVideoTapped(_ sender: UITapGestureRecognizer){
       
    }
    
    @objc func btnImageTapped(_ sender: UITapGestureRecognizer){
       
    }
    
    @objc func btnPremiumTapped(_ sender: UITapGestureRecognizer){
       
    }
    
    @objc func btnMoreAppTapped(_ sender: UITapGestureRecognizer){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MoreAppViewController") as! MoreAppViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
