//
//  PremiumVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit

class PremiumVC: UIViewController {
    
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
    
    func setupUI() {
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
        
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            premiumImage.image = UIImage(named: "premiumUI-iPhone")
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            premiumImage.image = UIImage(named: "premiumUI-iPad")
        }
        
        let screenHeight = UIScreen.main.nativeBounds.height
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch screenHeight {
            case 1334, 1920, 2340, 1792: // se
                emojiStarckView.spacing = -10
                emojiBottomConstraints.constant = 10
                premiymBottomConstraints.constant = 10
                featurstext01Constraints.constant = 25
                featurstext02Constraints.constant = 47.33
                featurstext03Constraints.constant = 47.33
                featurstext04Constraints.constant = 47.33
            case 2532, 2556, 2436: // 14
                emojiStarckView.spacing = -5
                emojiBottomConstraints.constant = 20
                premiymBottomConstraints.constant = 20
                featurstext01Constraints.constant = 35
                featurstext02Constraints.constant = 52.33
                featurstext03Constraints.constant = 52.33
                featurstext04Constraints.constant = 52.33
            case 2622: // 16 pro
                emojiStarckView.spacing = -5
                emojiBottomConstraints.constant = 30
                premiymBottomConstraints.constant = 20
                featurstext01Constraints.constant = 45
                featurstext02Constraints.constant = 52.33
                featurstext03Constraints.constant = 52.33
                featurstext04Constraints.constant = 52.33
            case 2688, 2886, 2796, 2778, 2868, 2869: // 11 pro max
                emojiStarckView.spacing = -5
                emojiBottomConstraints.constant = 35
                premiymBottomConstraints.constant = 30
                featurstext01Constraints.constant = 50
                featurstext02Constraints.constant = 52.33
                featurstext03Constraints.constant = 52.33
                featurstext04Constraints.constant = 52.33
            default:
                emojiStarckView.spacing = -5
                emojiBottomConstraints.constant = 20
                premiymBottomConstraints.constant = 20
                featurstext01Constraints.constant = 35
                featurstext02Constraints.constant = 52.33
                featurstext03Constraints.constant = 52.33
                featurstext04Constraints.constant = 52.33
            }
        }
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
    
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
