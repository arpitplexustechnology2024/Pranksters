//
//  Extension.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import Foundation
import UIKit

extension UIView {
    func addBottomShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 7)
        self.layer.shadowRadius = 12
        self.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: self.bounds.maxY - 4, width: self.bounds.width, height: 4)).cgPath
    }
}

extension UIColor {
    convenience init(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        
        if hex.count == 6 {
            var rgbValue: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&rgbValue)
            
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            self.init(white: 0.0, alpha: 1.0)
        }
    }
}


class CustomPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0, y: containerView.bounds.height / 2, width: containerView.bounds.width, height: containerView.bounds.height / 2)
    }
}


// MARK: - UIViewController extension
extension UIViewController {
    func hideKeyboardTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UIView
extension UIView {
    func showShimmer() {
        self.subviews.filter { $0 is ShimmerView }.forEach { $0.removeFromSuperview() }
        
        let shimmerView = ShimmerView(frame: self.bounds)
        shimmerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(shimmerView)
    }
    
    func hideShimmer() {
        self.subviews.filter { $0 is ShimmerView }.forEach { $0.removeFromSuperview() }
    }
}

extension UIView {
    func setHorizontalGradientBackground(colorLeft: UIColor, colorRight: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorLeft.cgColor, colorRight.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

import UIKit

extension UIView {
    func addGradientBorder(colors: [UIColor], width: CGFloat = 2.0, cornerRadius: CGFloat = 8.0) {
        self.layer.sublayers?.filter { $0.name == "GradientBorderLayer" }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "GradientBorderLayer"
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)

        let maskLayer = CAShapeLayer()
        maskLayer.lineWidth = width
        maskLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor

        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.lineWidth = width
        borderLayer.fillColor = UIColor.clear.cgColor

        gradientLayer.mask = maskLayer

        self.layer.addSublayer(gradientLayer)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
