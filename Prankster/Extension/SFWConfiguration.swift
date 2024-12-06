//
//  File.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 30/11/24.
//

import Foundation
import UIKit
import SwiftFortuneWheel

// MARK: - Configuration Extension
private let blackColor = UIColor(white: 51.0 / 255.0, alpha: 1.0)
private let boaderColor = UIColor(white: 51.0 / 255.0, alpha: 1.0)
private let circleStrokeWidth: CGFloat = 10
private let _position: SFWConfiguration.Position = .top

extension UIColor {
    static let customColors: [UIColor] = [
        UIColor(hex: "FF8744"),
        UIColor(hex: "7DB346"),
        UIColor(hex: "9B59FB"),
        UIColor(hex: "2AFCD6"),
        UIColor(hex: "20D086"),
        UIColor(hex: "E6403D")
    ]
    
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension SFWConfiguration {
    static var customColorsConfiguration: SFWConfiguration {
        let spin = SFWConfiguration.SpinButtonPreferences(size: CGSize(width: 40, height: 40))
        
        let sliceColorType = SFWConfiguration.ColorType.customPatternColors(colors: UIColor.customColors, defaultColor: .orange)
        
        let slicePreferences = SFWConfiguration.SlicePreferences(backgroundColorType: sliceColorType, strokeWidth: 0, strokeColor: .clear)
        
        let anchorImage = SFWConfiguration.AnchorImage(imageName: "anchorImage", size: CGSize(width: 8, height: 8), verticalOffset: -10)
        
        let circlePreferences = SFWConfiguration.CirclePreferences(strokeWidth: 0, strokeColor: boaderColor)
        
        var wheelPreferences = SFWConfiguration.WheelPreferences(circlePreferences: circlePreferences,
                                                                 slicePreferences: slicePreferences,
                                                                 startPosition: .top)
        
        wheelPreferences.imageAnchor = anchorImage

        let configuration = SFWConfiguration(wheelPreferences: wheelPreferences, spinButtonPreferences: spin)

        return configuration
    }
}

// MARK: - Preferences Extensions
extension ImagePreferences {
    static var prizeImagePreferences: ImagePreferences {
        let preferences = ImagePreferences(preferredSize: CGSize(width: 45, height: 45),
                                           verticalOffset: 18)
        return preferences
    }
}

extension UIColor {
    static func gradientColor(from color1: UIColor, to color2: UIColor, size: CGSize) -> UIColor? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        gradientLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image.map { UIColor(patternImage: $0) }
    }
}
