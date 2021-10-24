//
//  UIApplication+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/1/20.
//

import UIKit

extension UIApplication {
    func hideKeyboard() {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
