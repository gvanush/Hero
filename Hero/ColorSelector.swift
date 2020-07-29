//
//  ColorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/28/20.
//

import SwiftUI

struct ColorSelector: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIColorPickerViewController
    
    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.supportsAlpha = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIColorPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var color: UIColor
    
    
    class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        
        let colorPicker: ColorSelector
        
        init(_ parent: ColorSelector) {
            self.colorPicker = parent
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            // 'UIColorPickerViewController' is buggy, just a workaround
            self.colorPicker.color = viewController.selectedColor
            colorPicker.presentationMode.wrappedValue.dismiss()
        }
     
    }
    
}
