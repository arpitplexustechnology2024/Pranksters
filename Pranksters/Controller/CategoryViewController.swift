//
//  CategoryViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 23/10/24.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var audioHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.seupViewAction()
    }
    
    func setupUI() {
        self.audioView.layer.cornerRadius = 15
        self.videoView.layer.cornerRadius = 15
        self.imageView.layer.cornerRadius = 15
        
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
        ]
        
        tapGestureActions.forEach { view, action in
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        }
    }
    
    @objc func btnAudioTapped(_ sender: UITapGestureRecognizer){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AudioViewController") as! AudioViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnVideoTapped(_ sender: UITapGestureRecognizer){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VideoViewController") as! VideoViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnImageTapped(_ sender: UITapGestureRecognizer){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ImageViewController") as! ImageViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
