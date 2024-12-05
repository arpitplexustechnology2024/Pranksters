//
//  Snackbar.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit

class CustomSnackbar: UIView {
    
    private var messageLabel: UILabel!
    private var timer: Timer?
    
    init(message: String, backgroundColor: UIColor = UIColor.snackbar) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        // Set up the message label
        messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.textColor = .snackbarLabel
        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(in view: UIView, duration: TimeInterval = 3.0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        let snackbarBottomConstraint = self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 48)
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            self.heightAnchor.constraint(equalToConstant: 48),
            snackbarBottomConstraint
        ])
        
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            snackbarBottomConstraint.constant = -40
            view.layoutIfNeeded()
        })
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
    }
    
    @objc private func dismiss() {
        guard let superview = self.superview else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 100)
            superview.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
        }
        
        timer?.invalidate()
        timer = nil
    }
}


import UIKit

class Snackbar: UIView {
    
    private var messageLabel: UILabel!
    private var actionButton: UIButton!
    private var timer: Timer?
    
    init(message: String, backgroundColor: UIColor = UIColor.snackbar) {
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        // Set up the message label
        messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.textColor = .snackbarLabel
        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(messageLabel)
        
        // Set up the action button
        actionButton = UIButton(type: .system)
        actionButton.setTitleColor(.snackbarLabel, for: .normal)
        actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.isHidden = true
        self.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            messageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            
            actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: messageLabel.trailingAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAction(title: String, action: @escaping () -> Void) {
        actionButton.setTitle(title, for: .normal)
        actionButton.isHidden = false
        actionButton.actionClosure = action
    }
    
    func show(in view: UIView, duration: TimeInterval = 3.0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        let snackbarBottomConstraint = self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 48)
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            snackbarBottomConstraint
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            snackbarBottomConstraint.constant = -16
            view.layoutIfNeeded()
        })
        
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }
    
    @objc private func actionButtonTapped() {
        self.actionButton.actionClosure?()
        dismiss()
    }
    
    private func dismiss() {
        guard let superview = self.superview else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 100)
            superview.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
        }
        
        timer?.invalidate()
        timer = nil
    }
}

extension UIButton {
    private struct AssociatedKeys {
        static var actionClosure = "actionClosure"
    }
    
    var actionClosure: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.actionClosure) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.actionClosure, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

