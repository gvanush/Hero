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
        numberField.continuousEditingUpdater = BasicUpdater(timeInterval: 0.1, tolerance: 0.01)
    }
    
}
