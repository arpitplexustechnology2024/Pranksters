//
//  NoInternetBottombarView.swift
//  LOL
//
//  Created by Arpit iOS Dev. on 02/08/24.
//

import UIKit
import Lottie

class NoInternetBottombarView: UIView {
    
    @IBOutlet weak var lottieView: LottieAnimationView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var lottieViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lottieViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lottieViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var retryButtonTopConstraint: NSLayoutConstraint!
    
    var onRetry: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NoInternetBottombarView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        adjustConstraints()
        
        localizeUI()
        setupLottieLoader()
    }
    
    private func setupLottieLoader() {
        lottieView.loopMode = .loop
        lottieView.contentMode = .scaleAspectFit
        lottieView.animation = LottieAnimation.named("NoInternet")
        lottieView.play()
    }
    
    func localizeUI() {
        titleLabel.text = NSLocalizedString("Oops... \n No internet connection!", comment: "")
        messageLabel.text = NSLocalizedString("Please turn on internet connection!", comment: "")
    }
    
    private func adjustConstraints() {
        let screenHeight = UIScreen.main.nativeBounds.height
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch screenHeight {
            case 1136, 1334, 1920, 2208:
                lottieViewTopConstraint.constant = 10
                lottieViewHeightConstraint.constant = 160
                lottieViewWidthConstraint.constant = 160
                labelTopConstraint.constant = 0
                retryButtonTopConstraint.constant = 10
            case 2436, 1792, 2556, 2532:
                lottieViewTopConstraint.constant = 40
                lottieViewHeightConstraint.constant = 200
                lottieViewWidthConstraint.constant = 200
                labelTopConstraint.constant = 20
                retryButtonTopConstraint.constant = 30
            case 2796, 2778, 2688:
                lottieViewTopConstraint.constant = 40
                lottieViewHeightConstraint.constant = 230
                lottieViewWidthConstraint.constant = 230
                labelTopConstraint.constant = 20
                retryButtonTopConstraint.constant = 30
            default:
                lottieViewTopConstraint.constant = 30
                lottieViewHeightConstraint.constant = 180
                lottieViewWidthConstraint.constant = 180
                labelTopConstraint.constant = 10
                retryButtonTopConstraint.constant = 20
            }
        }
    }
}
