//
//  HomeViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 07/10/24.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var moreAppView: UIView!
    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var spinerButton: UIButton!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var sideMenuLogo: UIImageView!
    @IBOutlet weak var sideMenuTableView: UITableView!
    
    var arrImg = ["More", "Fav", "premium 1", "review", "share", "privacy"]
    var arrData = ["More app", "Favorite list", "Premium", "Write a app review", "Share app with a friend", "Privacy Policy"]
    
    var backgroundOverlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.addBottomShadow(to: navigationbarView)
        self.setupBackgroundOverlayView()
        self.addTapGestureToOverlay()
        
        self.sideMenuView.frame.origin.x = -self.sideMenuView.frame.width
    }
    
    func setupUI() {
        self.audioView.layer.cornerRadius = 15
        self.videoView.layer.cornerRadius = 15
        self.imageView.layer.cornerRadius = 15
        self.premiumView.layer.cornerRadius = 15
        self.moreAppView.layer.cornerRadius = 15
        
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
        
        self.sideMenuView.isHidden = false
    }
    
    func setupBackgroundOverlayView() {
        backgroundOverlayView = UIView(frame: self.view.bounds)
        backgroundOverlayView.backgroundColor = UIColor.black
        backgroundOverlayView.alpha = 0.0
        self.view.addSubview(backgroundOverlayView)
        self.view.bringSubviewToFront(sideMenuView)
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
    
    func addTapGestureToOverlay() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap))
        backgroundOverlayView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleOverlayTap() {
        hideSideMenu()
    }
    
    @IBAction func btnSideMenuTapped(_ sender: UIButton) {
        showSideMenu()
    }
    
    func showSideMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundOverlayView.alpha = 0.3
            self.sideMenuView.frame.origin.x = 0
        })
    }
    
    func hideSideMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundOverlayView.alpha = 0.0
            self.sideMenuView.frame.origin.x = -self.sideMenuView.frame.width
        })
    }
    
    // MARK: - UITableView Delegate and DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCell") as! sideMenuCell
        cell.sideMenuIcon.image = UIImage(named: arrImg[indexPath.row])
        cell.sideMenuLabel.text = arrData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
