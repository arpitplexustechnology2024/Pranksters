//
//  AudioViewController.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 16/10/24.
//

import UIKit
import Alamofire
import TTGSnackbar
import SDWebImage
import Photos
import Lottie

class AudioViewController: UIViewController {
    
    @IBOutlet weak var navigationbarView: UIView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var AudioShowView: UIView!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet var floatingCollectionButton: [UIButton]!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet weak var coverImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverPage1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverPage2HeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var AudioCustomCollectionView: UICollectionView!
    @IBOutlet weak var audioCollectionView: UICollectionView!
    
    @IBOutlet weak var lottieLoader: LottieAnimationView!
    
    let plusImage = UIImage(named: "Plus")
    let cancelImage = UIImage(named: "Cancel")

    private var noDataView: NoDataBottomBarView!
    private var noInternetView: NoInternetBottombarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        addBottomShadow(to: navigationbarView)
        setupLottieLoader()
        bottomView.layer.shadowColor = UIColor.black.cgColor
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowOffset = CGSize(width: 0, height: 5)
        bottomView.layer.shadowRadius = 12
        bottomView.layer.cornerRadius = 28
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomScrollView.layer.cornerRadius = 28
        bottomScrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        floatingButton.setImage(plusImage, for: .normal)
        floatingButton.layer.cornerRadius = 19
        setupFloatingButtons()
        coverImageView.layer.cornerRadius = 8
        AudioShowView.layer.cornerRadius = 8
        
        coverPage1CollectionView.delegate = self
        coverPage1CollectionView.dataSource = self
        
        coverPage2CollectionView.delegate = self
        coverPage2CollectionView.dataSource = self
        
    }
    
    private func setupFloatingButtons() {
        for button in floatingCollectionButton {
            button.layer.cornerRadius = 19
            button.clipsToBounds = true
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.25
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            button.layer.masksToBounds = false
            button.isHidden = true
            button.alpha = 0
        }
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
    
    private func setupLottieLoader() {
        lottieLoader.isHidden = true
        lottieLoader.loopMode = .loop
        lottieLoader.contentMode = .scaleAspectFill
        lottieLoader.animation = LottieAnimation.named("Loader")
    }
    
    @IBAction func btnFloatingTapped(_ sender: UIButton) {
        floatingCollectionButton.forEach { btn in
            UIView.animate(withDuration: 0.5) {
                btn.isHidden = !btn.isHidden
                btn.alpha = btn.alpha == 0 ? 1 : 0
            }
        }
        
        if floatingButton.currentImage == plusImage {
            floatingButton.setImage(cancelImage, for: .normal)
        } else {
            floatingButton.setImage(plusImage, for: .normal)
        }
    }
    
    @IBAction func btnMoreAppTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MoreAppViewController") as! MoreAppViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFavouriteTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
    }
    
    @IBAction func btnPremiumTapped(_ sender: UIButton) {
        animate(toggel: false)
        floatingButton.setImage(plusImage, for: .normal)
    }
    
    func animate(toggel: Bool) {
        if toggel {
            floatingCollectionButton.forEach { btn in
                UIView.animate(withDuration: 0.5) {
                    btn.isHidden = false
                    btn.alpha = btn.alpha == 0 ? 1 : 0
                }
            }
        } else {
            floatingCollectionButton.forEach { btn in
                UIView.animate(withDuration: 0.5) {
                    btn.isHidden = true
                    btn.alpha = btn.alpha == 0 ? 1 : 0
                }
            }
        }
    }
    


}
