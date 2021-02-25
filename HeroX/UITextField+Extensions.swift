//
//  UITextField+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/21/21.
//

import UIKit

extension UITextField {
    
    func setupInputAccessoryToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil, tag: Int? = nil) {
        
        let tag = tag ?? 0;
        
        // Frame is necessary to suppress the log errors with autolayout contraints
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        toolbar.barStyle = .default
        toolbar.items = []
        if let onCancel = onCancel {
            let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action)
            cancelItem.tag = tag
            toolbar.items!.append(cancelItem)
        }
        toolbar.items!.append(UIBarButtonItem(systemItem: .flexibleSpace))
        if let onDone = onDone {
            let doneItem = UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
            doneItem.tag = tag
            toolbar.items!.append(doneItem)
        }
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }
    
    @nonobjc private func onDonePressed(_ barButtonItem: UIBarButtonItem) {
        
    }
    
}