//
//  SpinnerViewController.swift
//  CustomSideMenuiOSExample
//
//  Created by John Codeos on 2/9/21.
//

import UIKit
import AudioToolbox

class SpinnerViewController: UIViewController {
    
    @IBOutlet weak var fortuneWheelImageView: UIImageView!
    @IBOutlet weak var pin: UIImageView!
    
    let spinButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Spin", for: .normal)
        button.backgroundColor = UIColor.yellow
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(spinWheel), for: .touchUpInside)
        return button
    }()
    
    private var currentRotationAngle: CGFloat = 0
    private var isSpinning = false
    private var timer: Timer?
    private var animationDelegate: AnimationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(spinButton)
        
        NSLayoutConstraint.activate([
            spinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinButton.topAnchor.constraint(equalTo: fortuneWheelImageView.bottomAnchor, constant: 30),
            spinButton.widthAnchor.constraint(equalToConstant: 150),
            spinButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func spinWheel() {
        if !isSpinning {
            isSpinning = true
            rotateWheel()
            startVibration()
        }
    }
    
    func rotateWheel() {
        let fullRotation = CABasicAnimation(keyPath: "transform.rotation")
        fullRotation.fromValue = 0
        fullRotation.toValue = CGFloat.pi * 12
        fullRotation.duration = 5
        fullRotation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        fullRotation.isRemovedOnCompletion = false
        fullRotation.fillMode = .forwards
        
        animationDelegate = AnimationDelegate { [weak self] in
            self?.stopSpinningAndVibration()
        }
        fullRotation.delegate = animationDelegate
        
        fortuneWheelImageView.layer.add(fullRotation, forKey: "rotate")
    }
    
    private func startVibration() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.isSpinning {
                AudioServicesPlaySystemSound(1519)
                
                timer.invalidate()
                let newInterval = min(timer.timeInterval * 1.2, 0.5)
                self.timer = Timer.scheduledTimer(withTimeInterval: newInterval, repeats: true) { _ in
                    if self.isSpinning {
                        AudioServicesPlaySystemSound(1519)
                    }
                }
            }
        }
    }
    
    private func stopSpinningAndVibration() {
        isSpinning = false
        timer?.invalidate()
        timer = nil
    }
}

class AnimationDelegate: NSObject, CAAnimationDelegate {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            completion()
        }
    }
}
