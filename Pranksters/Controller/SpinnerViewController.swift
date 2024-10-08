//
//  SpinnerViewController.swift
//  CustomSideMenuiOSExample
//
//  Created by John Codeos on 2/9/21.
//

import UIKit

class SpinnerViewController: UIViewController {
    
    @IBOutlet weak var backbutton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func bacutton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
