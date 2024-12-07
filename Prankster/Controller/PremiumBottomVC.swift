//
//  PremiumBottomVC.swift
//  Prankster
//
//  Created by Arpit iOS Dev. on 06/12/24.
//

import UIKit

class PremiumBottomVC: UIViewController {
    
    //    @IBOutlet weak var unlockAllButton: UIButton!
    
    @IBOutlet weak var premiumImage: UIImageView!
    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var weeklyPremiumView: UIView!
    @IBOutlet weak var bestofferView: UIView!
    @IBOutlet weak var monthlyPremiumView: UIView!
    @IBOutlet weak var topratedView: UIView!
    @IBOutlet weak var lifetimePremiumView: UIView!
    @IBOutlet weak var popularView: UIView!
    @IBOutlet weak var premiymBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var emojiBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurstext01Constraints: NSLayoutConstraint!
    @IBOutlet weak var featurstext02Constraints: NSLayoutConstraint!
    @IBOutlet weak var featurstext03Constraints: NSLayoutConstraint!
    @IBOutlet weak var featurstext04Constraints: NSLayoutConstraint!
    @IBOutlet weak var emojiStarckView: UIStackView!
    @IBOutlet weak var featurstext01: UILabel!
    @IBOutlet weak var featurstext02: UILabel!
    @IBOutlet weak var featurstext03: UILabel!
    @IBOutlet weak var featurstext04: UILabel!
    @IBOutlet weak var premiumViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var bestOfferLabel: UILabel!
    @IBOutlet weak var bestOfferViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var bestOfferViewWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var weeklyPriceLabel: UILabel!
    @IBOutlet weak var topRatedLabel: UILabel!
    @IBOutlet weak var topRatedViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var topRatedViewWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var monthlyPriceLabel: UILabel!
    @IBOutlet weak var populareLabel: UILabel!
    @IBOutlet weak var popularViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var populareViewWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var lifetimeLabel: UILabel!
    @IBOutlet weak var lifetimePriceLabel: UILabel!
    
    @IBOutlet weak var PremiumViewScrollWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs01HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs01WidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs02HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs02WidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs03HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs03WidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs04HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs04WidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var bGImageHeightConstraints: NSLayoutConstraint!
    
    
    @IBOutlet weak var weekStrikethrought: UILabel! {
        didSet {
            let attributedString = NSAttributedString(
                string: weekStrikethrought.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor.gray]
            )
            weekStrikethrought.attributedText = attributedString
        }
    }
    
    @IBOutlet weak var monthlyStrikethrought: UILabel! {
        didSet {
            let attributedString = NSAttributedString(
                string: monthlyStrikethrought.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor.gray]
            )
            monthlyStrikethrought.attributedText = attributedString
        }
    }
    
    @IBOutlet weak var ligetimeStrikethrounght: UILabel! {
        didSet {
            let attributedString = NSAttributedString(
                string: ligetimeStrikethrounght.text ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor.gray]
            )
            ligetimeStrikethrounght.attributedText = attributedString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //  setupUnlockAllButton()
    }
    


    

    
    //    private func setupUnlockAllButton() {
    //        unlockAllButton.addTarget(self, action: #selector(unlockAllButtonTapped), for: .touchUpInside)
    //    }
    //
    //    @objc private func unlockAllButtonTapped() {
    //        PremiumManager.shared.unlockAllContent()
    //
    //        NotificationCenter.default.post(name: NSNotification.Name("PremiumContentUnlocked"), object: nil)
    //
    //        let snackbar = CustomSnackbar(message: "Premium access activated!", backgroundColor: .snackbar)
    //        snackbar.show(in: view, duration: 2.0)
    //
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    //            self.dismiss(animated: true)
    //        }
    //    }
    
    
    @IBAction func btnPremiumTapped(_ sender: UIButton) {
    }
    
    
    @IBAction func btnRestoreTapped(_ sender: UIButton) {
    }
}

extension PremiumBottomVC {
    func setupUI() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            premiumImage.image = UIImage(named: "PremiumBottom")
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            premiumImage.image = UIImage(named: "PremiumBottom-Ipad")
        }
        
        let screenHeight = UIScreen.main.nativeBounds.height
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            self.premiumButton.layer.cornerRadius = 13
            self.weeklyPremiumView.layer.cornerRadius = 10
            self.weeklyPremiumView.addGradientBorder(colors: [UIColor(hex: "#01B4D8"),UIColor(hex: "#8FE0EF")],width: 3.0,cornerRadius: 10)
            bestofferView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            bestofferView.layer.cornerRadius = 10
            bestofferView.clipsToBounds = true
            bestofferView.setHorizontalGradientBackground( colorLeft: UIColor(hex: "#01B4D8"), colorRight: UIColor(hex: "#8FE0EF"))
            self.monthlyPremiumView.layer.cornerRadius = 10
            self.monthlyPremiumView.addGradientBorder(colors: [UIColor(hex: "#FC6D70"),UIColor(hex: "#FEA3A4")],width: 3.0,cornerRadius: 10)
            topratedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            topratedView.layer.cornerRadius = 10
            topratedView.clipsToBounds = true
            topratedView.setHorizontalGradientBackground( colorLeft: UIColor(hex: "#FC6D70"), colorRight: UIColor(hex: "#FEA3A4"))
            self.lifetimePremiumView.layer.cornerRadius = 10
            self.lifetimePremiumView.addGradientBorder(colors: [UIColor(hex: "#B094E0"),UIColor(hex: "#CAA3FD")],width: 4.0,cornerRadius: 10)
            popularView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            popularView.layer.cornerRadius = 10
            popularView.clipsToBounds = true
            popularView.setHorizontalGradientBackground( colorLeft: UIColor(hex: "#B094E0"), colorRight: UIColor(hex: "#CAA3FD"))
            
            self.featurs01HeightConstraints.constant = 80
            self.featurs01WidthConstraints.constant = 60
            self.featurs02HeightConstraints.constant = 80
            self.featurs02WidthConstraints.constant = 60
            self.featurs03HeightConstraints.constant = 80
            self.featurs03WidthConstraints.constant = 60
            self.featurs04HeightConstraints.constant = 53
            self.featurs04WidthConstraints.constant = 60
            self.premiumViewHeightConstraints.constant = 100
            self.PremiumViewScrollWidthConstraints.constant = 500
            self.bestOfferViewHeightConstraints.constant = 30
            self.bestOfferViewWidthConstraints.constant = 87
            self.topRatedViewHeightConstraints.constant = 30
            self.topRatedViewWidthConstraints.constant = 87
            self.popularViewHeightConstraints.constant = 30
            self.populareViewWidthConstraints.constant = 87
            self.bGImageHeightConstraints.constant = 400
            self.bestOfferLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
            self.topRatedLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
            self.populareLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
            self.weeklyLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
            self.monthlyLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
            self.lifetimeLabel.font = UIFont(name: "Avenir-Heavy", size: 12)
            self.weeklyPriceLabel.font = UIFont(name: "Avenir-Heavy", size: 23)
            self.monthlyPriceLabel.font = UIFont(name: "Avenir-Heavy", size: 23)
            self.lifetimePriceLabel.font = UIFont(name: "Avenir-Heavy", size: 23)
            self.weekStrikethrought.font = UIFont(name: "Avenir-Heavy", size: 10)
            self.monthlyStrikethrought.font = UIFont(name: "Avenir-Heavy", size: 10)
            self.ligetimeStrikethrounght.font = UIFont(name: "Avenir-Heavy", size: 10)
            self.featurstext01.font = UIFont(name: "Avenir-Heavy", size: 17)
            self.featurstext02.font = UIFont(name: "Avenir-Heavy", size: 17)
            self.featurstext03.font = UIFont(name: "Avenir-Heavy", size: 17)
            self.featurstext04.font = UIFont(name: "Avenir-Heavy", size: 17)
            switch screenHeight {
            case 1334, 1920, 2340, 1792: // se
                self.emojiStarckView.spacing = -10
                self.emojiBottomConstraints.constant = 8
                self.premiymBottomConstraints.constant = 8
                self.featurstext01Constraints.constant = 20
                self.featurstext02Constraints.constant = 32.33
                self.featurstext03Constraints.constant = 32.33
                self.featurstext04Constraints.constant = 32.33
                self.featurs01HeightConstraints.constant = 60
                self.featurs01WidthConstraints.constant = 40
                self.featurs02HeightConstraints.constant = 60
                self.featurs02WidthConstraints.constant = 40
                self.featurs03HeightConstraints.constant = 60
                self.featurs03WidthConstraints.constant = 40
                self.featurs04HeightConstraints.constant = 40
                self.featurs04WidthConstraints.constant = 40
                self.bGImageHeightConstraints.constant = 350
                self.featurstext01.font = UIFont(name: "Avenir-Heavy", size: 13)
                self.featurstext02.font = UIFont(name: "Avenir-Heavy", size: 13)
                self.featurstext03.font = UIFont(name: "Avenir-Heavy", size: 13)
                self.featurstext04.font = UIFont(name: "Avenir-Heavy", size: 13)
            case 2532, 2556, 2436: // 14
                self.emojiStarckView.spacing = -10
                self.emojiBottomConstraints.constant = 10
                self.premiymBottomConstraints.constant = 10
                self.featurstext01Constraints.constant = 25
                self.featurstext02Constraints.constant = 47.33
                self.featurstext03Constraints.constant = 47.33
                self.featurstext04Constraints.constant = 47.33
            case 2622: // 16 pro
                self.emojiStarckView.spacing = -10
                self.emojiBottomConstraints.constant = 10
                self.premiymBottomConstraints.constant = 10
                self.featurstext01Constraints.constant = 25
                self.featurstext02Constraints.constant = 47.33
                self.featurstext03Constraints.constant = 47.33
                self.featurstext04Constraints.constant = 47.33
            case 2688, 2886, 2796, 2778, 2868, 2869: // 11 pro max
                self.emojiStarckView.spacing = -10
                self.emojiBottomConstraints.constant = 10
                self.premiymBottomConstraints.constant = 10
                self.featurstext01Constraints.constant = 25
                self.featurstext02Constraints.constant = 47.33
                self.featurstext03Constraints.constant = 47.33
                self.featurstext04Constraints.constant = 47.33
                self.bGImageHeightConstraints.constant = 450
            default:
                self.emojiStarckView.spacing = -10
                self.emojiBottomConstraints.constant = 10
                self.premiymBottomConstraints.constant = 10
                self.featurstext01Constraints.constant = 25
                self.featurstext02Constraints.constant = 47.33
                self.featurstext03Constraints.constant = 47.33
                self.featurstext04Constraints.constant = 47.33
            }
        } else {
            self.premiumButton.layer.cornerRadius = 13
            self.weeklyPremiumView.layer.cornerRadius = 10
            self.weeklyPremiumView.addGradientBorder(colors: [UIColor(hex: "#01B4D8"),UIColor(hex: "#8FE0EF")],width: 3.0,cornerRadius: 10)
            bestofferView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            bestofferView.layer.cornerRadius = 10
            bestofferView.clipsToBounds = true
            bestofferView.setHorizontalGradientBackground( colorLeft: UIColor(hex: "#01B4D8"), colorRight: UIColor(hex: "#8FE0EF"))
            self.monthlyPremiumView.layer.cornerRadius = 10
            self.monthlyPremiumView.addGradientBorder(colors: [UIColor(hex: "#FC6D70"),UIColor(hex: "#FEA3A4")],width: 3.0,cornerRadius: 10)
            topratedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            topratedView.layer.cornerRadius = 10
            topratedView.clipsToBounds = true
            topratedView.setHorizontalGradientBackground( colorLeft: UIColor(hex: "#FC6D70"), colorRight: UIColor(hex: "#FEA3A4"))
            self.lifetimePremiumView.layer.cornerRadius = 10
            self.lifetimePremiumView.addGradientBorder(colors: [UIColor(hex: "#B094E0"),UIColor(hex: "#CAA3FD")],width: 4.0,cornerRadius: 10)
            popularView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            popularView.layer.cornerRadius = 10
            popularView.clipsToBounds = true
            popularView.setHorizontalGradientBackground( colorLeft: UIColor(hex: "#B094E0"), colorRight: UIColor(hex: "#CAA3FD"))
            
            self.emojiStarckView.spacing = -10
            self.emojiBottomConstraints.constant = 10
            self.premiymBottomConstraints.constant = 10
            self.featurstext01Constraints.constant = 26
            self.featurstext02Constraints.constant = 49.33
            self.featurstext03Constraints.constant = 49.33
            self.featurstext04Constraints.constant = 49.33
            self.featurs01HeightConstraints.constant = 90
            self.featurs01WidthConstraints.constant = 70
            self.featurs02HeightConstraints.constant = 90
            self.featurs02WidthConstraints.constant = 70
            self.featurs03HeightConstraints.constant = 90
            self.featurs03WidthConstraints.constant = 70
            self.featurs04HeightConstraints.constant = 63
            self.featurs04WidthConstraints.constant = 70
            self.PremiumViewScrollWidthConstraints.constant = 1000
            self.premiumViewHeightConstraints.constant = 170
            self.bestOfferViewHeightConstraints.constant = 50
            self.bestOfferViewWidthConstraints.constant = 155
            self.topRatedViewHeightConstraints.constant = 50
            self.topRatedViewWidthConstraints.constant = 155
            self.popularViewHeightConstraints.constant = 50
            self.populareViewWidthConstraints.constant = 155
            self.bGImageHeightConstraints.constant = 800
            self.bestOfferLabel.font = UIFont(name: "Avenir-Heavy", size: 22)
            self.topRatedLabel.font = UIFont(name: "Avenir-Heavy", size: 22)
            self.populareLabel.font = UIFont(name: "Avenir-Heavy", size: 22)
            self.weeklyLabel.font = UIFont(name: "Avenir-Heavy", size: 22)
            self.monthlyLabel.font = UIFont(name: "Avenir-Heavy", size: 22)
            self.lifetimeLabel.font = UIFont(name: "Avenir-Heavy", size: 22)
            self.weeklyPriceLabel.font = UIFont(name: "Avenir-Heavy", size: 41)
            self.monthlyPriceLabel.font = UIFont(name: "Avenir-Heavy", size: 41)
            self.lifetimePriceLabel.font = UIFont(name: "Avenir-Heavy", size: 41)
            self.weekStrikethrought.font = UIFont(name: "Avenir-Heavy", size: 20)
            self.monthlyStrikethrought.font = UIFont(name: "Avenir-Heavy", size: 20)
            self.ligetimeStrikethrounght.font = UIFont(name: "Avenir-Heavy", size: 20)
            self.featurstext01.font = UIFont(name: "Avenir-Heavy", size: 23)
            self.featurstext02.font = UIFont(name: "Avenir-Heavy", size: 23)
            self.featurstext03.font = UIFont(name: "Avenir-Heavy", size: 23)
            self.featurstext04.font = UIFont(name: "Avenir-Heavy", size: 23)
            
        }
    }
}
