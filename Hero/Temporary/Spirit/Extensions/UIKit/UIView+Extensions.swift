//
//  UIView+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 2/24/21.
//

import UIKit

extension UIView {
    
    func setupNib(_ name: String) {
        let nib = UINib(nibName: name, bundle: Bundle(for: Self.self))
        let content = nib.instantiate(withOwner: self, options: nil).first as! UIView
        content.frame = bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(content)
    }
    
}
