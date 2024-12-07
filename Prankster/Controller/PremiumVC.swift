//
//  PremiumVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit
import StoreKit
import Alamofire

class PremiumVC: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    @IBOutlet weak var premiumImage: UIImageView!
    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var weeklyPremiumView: UIView!
    @IBOutlet weak var bestofferView: UIView!
    @IBOutlet weak var monthlyPremiumView: UIView!
    @IBOutlet weak var topratedView: UIView!
    @IBOutlet weak var lifetimePremiumView: UIView!
    @IBOutlet weak var popularView: UIView!
    @IBOutlet weak var emojiStarckView: UIStackView!
    @IBOutlet weak var featurstext01: UILabel!
    @IBOutlet weak var featurstext02: UILabel!
    @IBOutlet weak var featurstext03: UILabel!
    @IBOutlet weak var featurstext04: UILabel!
    @IBOutlet weak var bestOfferLabel: UILabel!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var weeklyPriceLabel: UILabel!
    @IBOutlet weak var topRatedLabel: UILabel!
    @IBOutlet weak var monthlyLabel: UILabel!
    @IBOutlet weak var monthlyPriceLabel: UILabel!
    @IBOutlet weak var populareLabel: UILabel!
    @IBOutlet weak var lifetimeLabel: UILabel!
    @IBOutlet weak var lifetimePriceLabel: UILabel!
    @IBOutlet weak var premiumViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var bestOfferViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var bestOfferViewWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var topRatedViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var topRatedViewWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var popularViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var populareViewWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var PremiumViewScrollWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs01HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs01WidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs02HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs02WidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs03HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs03WidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs04HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurs04WidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var premiymBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var emojiBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var featurstext01Constraints: NSLayoutConstraint!
    @IBOutlet weak var featurstext02Constraints: NSLayoutConstraint!
    @IBOutlet weak var featurstext03Constraints: NSLayoutConstraint!
    @IBOutlet weak var featurstext04Constraints: NSLayoutConstraint!
    
    @IBOutlet weak var doneImage01: UIImageView!
    @IBOutlet weak var doneImage02: UIImageView!
    @IBOutlet weak var doneImage03: UIImageView!
    
    @IBOutlet weak var premiumWeeklyView: UIView!
    @IBOutlet weak var premiumMonthlyView: UIView!
    @IBOutlet weak var premiumLifeTimeView: UIView!
    
    let productID = "com.prank.memes"
    
    private var product: SKProduct?
    private var isRestoringPurchases = false
    
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
        fetchProductInfo()
        setupUI()
        SKPaymentQueue.default().add(self)
    }
    
    private func fetchProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: Set([productID]))
            request.delegate = self
            request.start()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            self.product = product
            DispatchQueue.main.async {
                self.updateProFeaturesLabel()
            }
        }
    }
    
    private func updateProFeaturesLabel() {
        if let product = self.product {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product.priceLocale
            if let formattedPrice = numberFormatter.string(from: product.price) {
                let localizedFormat = NSLocalizedString("PremiumFeaturesKey", comment: "Format string for pro features with price for lifetime")
                let attributedString = NSMutableAttributedString(string: String(format: localizedFormat, formattedPrice))
                if let range = attributedString.string.range(of: formattedPrice) {
                    let nsRange = NSRange(range, in: attributedString.string)
                    attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: nsRange)
                }
                self.lifetimePriceLabel.attributedText = attributedString
            }
        }
    }
    
    @IBAction func btnPremiumTapped(_ sender: UIButton) {
        if !isConnectedToInternet() {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
            return
        }
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            print("User unable to make payments")
        }
    }
    
    private func isConnectedToInternet() -> Bool {
        let networkManager = NetworkReachabilityManager()
        return networkManager?.isReachable ?? false
    }
    
    @IBAction func btnRestoreTapped(_ sender: UIButton) {
        if !isConnectedToInternet() {
            let snackbar = CustomSnackbar(message: "Please turn on internet connection!", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
            return
        }
        
        isRestoringPurchases = true
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                print("Purchase Successfully")
                SKPaymentQueue.default().finishTransaction(transaction)
                showPremiumSuccessAlert()
                
            } else if transaction.transactionState == .failed {
                print("Purchase or Restore Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
                handleFailedPurchaseOrRestore(transaction: transaction)
                
            } else if transaction.transactionState == .restored {
                print("Restore Successful")
                SKPaymentQueue.default().finishTransaction(transaction)
                handleSuccessfulRestore(transaction: transaction)
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        isRestoringPurchases = false
        if queue.transactions.isEmpty {
            let snackbar = CustomSnackbar(message: "You have not purchased this item yet. Please purchase to proceed.", backgroundColor: .snackbar)
            snackbar.show(in: self.view, duration: 3.0)
            self.dismiss(animated: true)
        }
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        isRestoringPurchases = false
        showFailureAlert()
    }
    
    private func handleSuccessfulRestore(transaction: SKPaymentTransaction) {
        if isRestoringPurchases {
            showPremiumSuccessAlert()
        }
    }
    
    private func handleFailedPurchaseOrRestore(transaction: SKPaymentTransaction) {
        if isRestoringPurchases {
            showFailureAlert()
        } else {
            showFailureAlert()
        }
    }
    
    // MARK: - Show Premium Successfully Alert
    private func showPremiumSuccessAlert() {
        DispatchQueue.main.async { [self] in
            let customAlertVC = CustomAlertViewController()
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            customAlertVC.message = NSLocalizedString("Congratulation...", comment: "")
            customAlertVC.link = NSLocalizedString("You're all set.", comment: "")
            customAlertVC.image = UIImage(named: "CopyLink")
            
            self.present(customAlertVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    customAlertVC.animateDismissal {
                        customAlertVC.dismiss(animated: false, completion: nil)
                        self.dismiss(animated: true)
                    }
                }
            }
            PremiumManager.shared.unlockAllContent()
            NotificationCenter.default.post(name: NSNotification.Name("PremiumContentUnlocked"), object: nil)
        }
    }
    
    private func showFailureAlert() {
        DispatchQueue.main.async {
            let customAlertVC = AlertViewController()
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            customAlertVC.message = NSLocalizedString("Failed!", comment: "")
            customAlertVC.link = NSLocalizedString("Request failed. Please try again after some time!", comment: "")
            customAlertVC.image = UIImage(named: "PurchaseFailed")
            
            self.present(customAlertVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    customAlertVC.animateDismissal {
                        customAlertVC.dismiss(animated: false, completion: nil)
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}


extension PremiumVC {
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
                self.emojiBottomConstraints.constant = 10
                self.premiymBottomConstraints.constant = 10
                self.featurstext01Constraints.constant = 25
                self.featurstext02Constraints.constant = 47.33
                self.featurstext03Constraints.constant = 47.33
                self.featurstext04Constraints.constant = 47.33
            case 2532, 2556, 2436: // 14
                self.emojiStarckView.spacing = -5
                self.emojiBottomConstraints.constant = 20
                self.premiymBottomConstraints.constant = 20
                self.featurstext01Constraints.constant = 35
                self.featurstext02Constraints.constant = 52.33
                self.featurstext03Constraints.constant = 52.33
                self.featurstext04Constraints.constant = 52.33
            case 2622: // 16 pro
                self.emojiStarckView.spacing = -5
                self.emojiBottomConstraints.constant = 30
                self.premiymBottomConstraints.constant = 20
                self.featurstext01Constraints.constant = 45
                self.featurstext02Constraints.constant = 52.33
                self.featurstext03Constraints.constant = 52.33
                self.featurstext04Constraints.constant = 52.33
            case 2688, 2886, 2796, 2778, 2868, 2869: // 11 pro max
                self.emojiStarckView.spacing = -5
                self.emojiBottomConstraints.constant = 35
                self.premiymBottomConstraints.constant = 30
                self.featurstext01Constraints.constant = 50
                self.featurstext02Constraints.constant = 52.33
                self.featurstext03Constraints.constant = 52.33
                self.featurstext04Constraints.constant = 52.33
            default:
                self.emojiStarckView.spacing = -5
                self.emojiBottomConstraints.constant = 20
                self.premiymBottomConstraints.constant = 20
                self.featurstext01Constraints.constant = 35
                self.featurstext02Constraints.constant = 52.33
                self.featurstext03Constraints.constant = 52.33
                self.featurstext04Constraints.constant = 52.33
            }
        } else {
            self.emojiStarckView.spacing = -5
            self.emojiBottomConstraints.constant = 35
            self.premiymBottomConstraints.constant = 30
            self.featurstext01Constraints.constant = 55
            self.featurstext02Constraints.constant = 65.33
            self.featurstext03Constraints.constant = 65.33
            self.featurstext04Constraints.constant = 65.33
            self.featurs01HeightConstraints.constant = 110
            self.featurs01WidthConstraints.constant = 74
            self.featurs02HeightConstraints.constant = 110
            self.featurs02WidthConstraints.constant = 74
            self.featurs03HeightConstraints.constant = 110
            self.featurs03WidthConstraints.constant = 74
            self.featurs04HeightConstraints.constant = 74
            self.featurs04WidthConstraints.constant = 74
            self.PremiumViewScrollWidthConstraints.constant = 1000
            self.premiumViewHeightConstraints.constant = 170
            self.bestOfferViewHeightConstraints.constant = 50
            self.bestOfferViewWidthConstraints.constant = 155
            self.topRatedViewHeightConstraints.constant = 50
            self.topRatedViewWidthConstraints.constant = 155
            self.popularViewHeightConstraints.constant = 50
            self.populareViewWidthConstraints.constant = 155
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
            self.featurstext01.font = UIFont(name: "Avenir-Heavy", size: 28)
            self.featurstext02.font = UIFont(name: "Avenir-Heavy", size: 28)
            self.featurstext03.font = UIFont(name: "Avenir-Heavy", size: 28)
            self.featurstext04.font = UIFont(name: "Avenir-Heavy", size: 28)
            
        }
    }
}
