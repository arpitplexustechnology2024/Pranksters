//
//  AudioCardPreview.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 18/10/24.
//

import UIKit
import Shuffle_iOS
import SDWebImage

struct AudioCardModel {
    let file: String
    let name: String
    let image: String
    var isFavorited: Bool
    let itemId: Int
    let categoryId: Int
    let Premium: Bool
}

class AudioCardPreview: SwipeCard {
    
    private let imageView = UIImageView()
    private let blurredImageView = UIImageView()
    private let favouriteButton = UIButton()
    private let premiumIconView = UIImageView()
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
    private let titleLabel = UILabel()
    private let playButton = UIButton()
    private let slider = UISlider()
    private let durationLabel = UILabel()
    
    var model: AudioCardModel?
    var onFavoriteButtonTapped: ((Int, Bool, Int) -> Void)?
    var onPlayButtonTapped: (() -> Void)?
    var onSliderValueChanged: ((Float) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCard() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        addSubview(imageView)
        
        blurredImageView.contentMode = .scaleAspectFill
        blurredImageView.layer.masksToBounds = true
        blurredImageView.layer.cornerRadius = 12
        blurredImageView.alpha = 0
        addSubview(blurredImageView)
        
        premiumIconView.image = UIImage(named: "premiumIcon")
        premiumIconView.isHidden = true
        addSubview(premiumIconView)
        
        favouriteButton.setImage(UIImage(named: "Heart"), for: .normal)
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        addSubview(favouriteButton)
        
        visualEffectView.layer.cornerRadius = 12
        visualEffectView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        visualEffectView.clipsToBounds = true
        addSubview(visualEffectView)
        
        titleLabel.textColor = .icon
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        visualEffectView.contentView.addSubview(titleLabel)
        
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tintColor = .white
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        visualEffectView.contentView.addSubview(playButton)
        
        slider.minimumTrackTintColor = .black
        slider.maximumTrackTintColor = .darkGray
        slider.thumbTintColor = .white
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        visualEffectView.contentView.addSubview(slider)
        
        durationLabel.textColor = .icon
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        durationLabel.textAlignment = .right
        durationLabel.text = "00:00"
        visualEffectView.contentView.addSubview(durationLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        [imageView, blurredImageView, premiumIconView, favouriteButton, visualEffectView, titleLabel, playButton, slider, durationLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            blurredImageView.topAnchor.constraint(equalTo: topAnchor),
            blurredImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurredImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            premiumIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            premiumIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            premiumIconView.widthAnchor.constraint(equalToConstant: 60),
            premiumIconView.heightAnchor.constraint(equalToConstant: 60),
            
            favouriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            favouriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            favouriteButton.widthAnchor.constraint(equalToConstant: 22),
            favouriteButton.heightAnchor.constraint(equalToConstant: 20),
            
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            visualEffectView.heightAnchor.constraint(equalToConstant: 90),
            
            titleLabel.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -16),
            
            playButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            playButton.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 16),
            playButton.widthAnchor.constraint(equalToConstant: 30),
            playButton.heightAnchor.constraint(equalToConstant: 30),
            
            slider.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            slider.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 8),
            slider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -8),
            
            durationLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -16),
            durationLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Audio Control Methods
    @objc private func playButtonTapped() {
        onPlayButtonTapped?()
    }
    
    @objc private func sliderValueChanged() {
        onSliderValueChanged?(slider.value)
    }
    
    func updatePlayButtonImage(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func updateSliderValue(_ value: Float) {
        slider.value = value
    }
    
    func updateDurationLabel(text: String) {
        durationLabel.text = text
    }
    
    func configure(withModel model: AudioCardModel) {
        self.model = model
        imageView.sd_setImage(with: URL(string: model.image)) { [weak self] image, _, _, _ in
            if let image = image {
                self?.setImage(image)
            }
        }
        titleLabel.text = model.name
        updateFavoriteButton(isFavorited: model.isFavorited)
        
        if model.Premium {
            blurredImageView.alpha = 1
            premiumIconView.isHidden = false
        } else {
            blurredImageView.alpha = 0
            premiumIconView.isHidden = true
        }
        favouriteButton.isHidden = false
    }
    
    private func setImage(_ image: UIImage) {
        imageView.image = image
        if let blurredImage = applyGaussianBlur(to: image) {
            blurredImageView.image = blurredImage
        }
    }
    
    private func applyGaussianBlur(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(50, forKey: kCIInputRadiusKey)
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    @objc private func favouriteButtonTapped() {
        guard let model = model else { return }
        let newFavoriteStatus = !model.isFavorited
        updateFavoriteButton(isFavorited: newFavoriteStatus)
        onFavoriteButtonTapped?(model.itemId, newFavoriteStatus, model.categoryId)
    }
    
    private func updateFavoriteButton(isFavorited: Bool) {
        let heartImage = isFavorited ? "Heart_Fill" : "Heart"
        favouriteButton.setImage(UIImage(named: heartImage), for: .normal)
    }
}
