//
//  ShareView_02.swift
//  LOL
//
//  Created by Arpit iOS Dev. on 20/08/24.
//

import UIKit
import SDWebImage

class ShareView: UIView {
    
    @IBOutlet weak var shareBackground: UIImageView!
    @IBOutlet weak var cardview: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
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
        let nib = UINib(nibName: "ShareView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
        
        cardview.layer.cornerRadius = 16
        cardview.layer.masksToBounds = true
        
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
    }
    
    func configure(with imageURL: URL, name: String) {
        // Load main image
        imageView.sd_setImage(with: imageURL) { [weak self] (image, error, cacheType, url) in
            guard let self = self, let loadedImage = image else { return }
            self.createBlurredBackground(from: loadedImage)
            self.textLabel.text = name
        }
    }

    private func createBlurredBackground(from image: UIImage) {
        let context = CIContext(options: nil)
        guard let ciImage = CIImage(image: image),
              let blurFilter = CIFilter(name: "CIGaussianBlur") else { return }
        
        blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter.setValue(15.0, forKey: kCIInputRadiusKey)
        
        guard let blurredImage = blurFilter.outputImage,
              let cgImage = context.createCGImage(blurredImage, from: blurredImage.extent) else { return }
        
        shareBackground.image = UIImage(cgImage: cgImage)
        shareBackground.contentMode = .scaleAspectFill
    }
}
