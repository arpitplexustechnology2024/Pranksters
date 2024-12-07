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

class CustomePresentationController: UIPresentationController {
    var heightPercentage: CGFloat = 0.8
    private var dimView: UIView?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        let height = containerView.bounds.height * heightPercentage
        return CGRect(
            x: 0,
            y: containerView.bounds.height - height,
            width: containerView.bounds.width,
            height: height
        )
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView,
              let presentedView = presentedView else { return }
        
        let dimView = UIView(frame: containerView.bounds)
        dimView.backgroundColor = .black.withAlphaComponent(0.5)
        dimView.tag = 999
        containerView.insertSubview(dimView, at: 0)
        self.dimView = dimView

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPresentedView))
        dimView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        presentedView.addGestureRecognizer(panGesture)
        self.panGestureRecognizer = panGesture

        presentedView.layer.cornerRadius = 20
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.clipsToBounds = true
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let presentedView = presentedView,
              let containerView = containerView else { return }
        
        let translation = gesture.translation(in: containerView)
        let velocity = gesture.velocity(in: containerView)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                presentedView.transform = CGAffineTransform(translationX: 0, y: translation.y)

                let progress = min(translation.y / (containerView.bounds.height * heightPercentage), 1.0)
                dimView?.alpha = 1 - progress
            }
            
        case .ended:
            let dismissThreshold = containerView.bounds.height * 0.2
            
            if translation.y > dismissThreshold || velocity.y > 500 {
                presentedViewController.dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) {
                    presentedView.transform = .identity
                    self.dimView?.alpha = 1
                }
            }
            
        default:
            break
        }
    }
    
    override func dismissalTransitionWillBegin() {
        dimView?.removeFromSuperview()
    }
    
    @objc private func dismissPresentedView() {
        presentedViewController.dismiss(animated: true)
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
        
        // Use bounds that adjust to the current view's size dynamically
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        // Remove any existing gradient layers first
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        // Insert the new gradient layer at the bottom of the layer stack
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addGradientBorder(colors: [UIColor], width: CGFloat = 2.0, cornerRadius: CGFloat = 8.0) {
        // Remove any existing gradient border layers
        layer.sublayers?.filter { $0.name == "GradientBorderLayer" }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "GradientBorderLayer"
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        // Dynamically adjust frame to current view's bounds
        gradientLayer.frame = bounds

        let maskLayer = CAShapeLayer()
        maskLayer.lineWidth = width
        
        // Use the current bounds and corner radius
        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor

        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.lineWidth = width
        borderLayer.fillColor = UIColor.clear.cgColor

        gradientLayer.mask = maskLayer

        layer.addSublayer(gradientLayer)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}
