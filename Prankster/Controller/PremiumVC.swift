//
//  PremiumVC.swift
//  Pranksters
//
//  Created by Arpit iOS Dev. on 11/11/24.
//

import UIKit

class PremiumVC: UIViewController {
    
    @IBOutlet weak var unlockAllButton: UIButton!
    @IBOutlet weak var coverImageURL: UILabel!
    @IBOutlet weak var URL: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUnlockAllButton()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupUnlockAllButton() {
        unlockAllButton.addTarget(self, action: #selector(unlockAllButtonTapped), for: .touchUpInside)
    }
    
    @objc private func unlockAllButtonTapped() {
        PremiumManager.shared.unlockAllContent()
        
        NotificationCenter.default.post(name: NSNotification.Name("PremiumContentUnlocked"), object: nil)
        
        let snackbar = CustomSnackbar(message: "Premium access activated!", backgroundColor: .snackbar)
        snackbar.show(in: view, duration: 2.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true)
        }
    }
}
