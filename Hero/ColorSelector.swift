//
//  ColorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/28/20.
//

import SwiftUI

struct ColorSelector: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIColorPickerViewController
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        
    }
    
    @Environment(\.presentationMode) var presentationMode
    let action: (UIColor) -> Void
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        
        let colorPicker: ColorSelector
        
        init(_ parent: ColorSelector) {
            self.colorPicker = parent
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            // 'UIColorPickerViewController' is buggy, just a workaround
            self.colorPicker.action(viewController.selectedColor)
            colorPicker.presentationMode.wrappedValue.dismiss()
        }
     
    }
    
}
