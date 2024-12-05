//
//  Skeleton.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit

class SkeletonCollectionViewCell: UICollectionViewCell {
    
    private let skeletonBackgroundView = UIView()
    private let ImageView = UIView()
    private let labelImageView = UIView()
    private let label2ImageView = UIView()
    private let buttonImageView = UIView()
    private let gradientLayerImage = CAGradientLayer()
    private let gradientLayerLabel = CAGradientLayer()
    private let gradientLayerLabel2 = CAGradientLayer()
    private let gradientLayerButton = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSkeleton()
    }
    
    private func setupSkeleton() {
        
        skeletonBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        skeletonBackgroundView.layer.cornerRadius = 16
        skeletonBackgroundView.clipsToBounds = true
        
        skeletonBackgroundView.layer.shadowColor = UIColor.black.cgColor
        skeletonBackgroundView.layer.shadowOpacity = 0.2
        skeletonBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        skeletonBackgroundView.layer.shadowRadius = 4.0
        skeletonBackgroundView.layer.masksToBounds = false
        contentView.addSubview(skeletonBackgroundView)
        
        ImageView.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.5)
        ImageView.clipsToBounds = true
        ImageView.layer.cornerRadius = 16
        contentView.addSubview(ImageView)
        
        labelImageView.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.5)
        labelImageView.clipsToBounds = true
        labelImageView.layer.cornerRadius = 10
        contentView.addSubview(labelImageView)
        
        label2ImageView.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.5)
        label2ImageView.clipsToBounds = true
        label2ImageView.layer.cornerRadius = 10
        contentView.addSubview(label2ImageView)
        
        buttonImageView.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.5)
        buttonImageView.clipsToBounds = true
        buttonImageView.layer.cornerRadius = 20
        contentView.addSubview(buttonImageView)
        
        skeletonBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skeletonBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            skeletonBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            skeletonBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            skeletonBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        ImageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewHeight = UIDevice.current.userInterfaceIdiom == .pad ? 174 : 119
        NSLayoutConstraint.activate([
            ImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            ImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ImageView.heightAnchor.constraint(equalToConstant: CGFloat(imageViewHeight))
        ])
        
        labelImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelImageView.topAnchor.constraint(equalTo: ImageView.bottomAnchor, constant: 8),
            labelImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            labelImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        label2ImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label2ImageView.topAnchor.constraint(equalTo: labelImageView.bottomAnchor, constant: 2),
            label2ImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label2ImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label2ImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonImageView.topAnchor.constraint(equalTo: label2ImageView.bottomAnchor, constant: 8),
            buttonImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buttonImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            buttonImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        setupGradient(for: ImageView, gradientLayer: gradientLayerImage)
        setupGradient(for: labelImageView, gradientLayer: gradientLayerLabel)
        setupGradient(for: label2ImageView, gradientLayer: gradientLayerLabel2)
        setupGradient(for: buttonImageView, gradientLayer: gradientLayerButton)
    }
    
    private func setupGradient(for view: UIView, gradientLayer: CAGradientLayer) {
        gradientLayer.colors = [
            UIColor.systemGray4.withAlphaComponent(0.5).cgColor,
            UIColor.systemGray.withAlphaComponent(0.5).cgColor,
            UIColor.systemGray4.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = view.bounds
        gradientLayer.add(createShimmerAnimation(), forKey: "shimmer")
        view.layer.addSublayer(gradientLayer)
    }
    
    private func createShimmerAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.0, 0.25]
        animation.toValue = [0.75, 1.0, 1.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        return animation
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayerImage.frame = ImageView.bounds
        gradientLayerLabel.frame = labelImageView.bounds
        gradientLayerLabel2.frame = label2ImageView.bounds
        gradientLayerButton.frame = buttonImageView.bounds
        
        gradientLayerImage.add(createShimmerAnimation(), forKey: "shimmer")
        gradientLayerLabel.add(createShimmerAnimation(), forKey: "shimmer")
        gradientLayerLabel2.add(createShimmerAnimation(), forKey: "shimmer")
        gradientLayerButton.add(createShimmerAnimation(), forKey: "shimmer")
    }
}


class SkeletonBoxCollectionViewCell: UICollectionViewCell {
    
    private let largeImageView = UIView()
    private let gradientLayerLarge = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSkeleton()
    }
    
    private func setupSkeleton() {
        
        largeImageView.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.5)
        largeImageView.clipsToBounds = true
        largeImageView.layer.cornerRadius = 16
        contentView.addSubview(largeImageView)
        
        largeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            largeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            largeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            largeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            largeImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        setupGradient(for: largeImageView, gradientLayer: gradientLayerLarge)
    }
    
    private func setupGradient(for view: UIView, gradientLayer: CAGradientLayer) {
        gradientLayer.colors = [
            UIColor.systemGray4.withAlphaComponent(0.5).cgColor,
            UIColor.systemGray.withAlphaComponent(0.5).cgColor,
            UIColor.systemGray4.withAlphaComponent(0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.frame = view.bounds
        gradientLayer.add(createShimmerAnimation(), forKey: "shimmer")
        view.layer.addSublayer(gradientLayer)
    }
    
    private func createShimmerAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.0, 0.25]
        animation.toValue = [0.75, 1.0, 1.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        return animation
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayerLarge.frame = largeImageView.bounds
    }
}

class ShimmerView: UIView {
    // MARK: - Properties
    private let gradientLayer = CAGradientLayer()
    private let gradientColorOne = UIColor(white: 0.85, alpha: 1.0).cgColor
    private let gradientColorTwo = UIColor(white: 1.0, alpha: 1.0).cgColor
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmerEffect()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmerEffect()
    }
    
    // MARK: - Setup Shimmer Effect
    private func setupShimmerEffect() {
        backgroundColor = .clear
        
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.0, 1.0]
        animation.toValue = [0.0, 1.0, 1.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerAnimation")
    }
}
