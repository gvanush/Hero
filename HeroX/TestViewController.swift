//
//  TestViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/23/21.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet weak var numberField: NumberField!
    
    override func viewDidLoad() {
        numberField.continuousEditingUpdater = DisplayLinkUpdater()
        numberField.addTarget(self, action: #selector(onValueChange(numberField:)), for: .valueChanged)
    }
    
    @objc func onValueChange(numberField: NumberField) {
        print("Value changed \(numberField.value)")
    }
    
}
