//
//  NativeTextField.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/14/20.
//

import SwiftUI

struct NativeTextField: UIViewRepresentable {
    
    @Binding var text: String?
    @Binding var isEditing: Bool
    let placeholder: String?
    let textAlignment: NSTextAlignment?
    let font: UIFont?
    let onEditingFinished: (() -> Void)?
    
    typealias UIViewType = UITextField
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.text = text
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.font = font
        if let textAlignment = self.textAlignment {
            textField.textAlignment = textAlignment
        }
        return textField
    }
    
    func updateUIView(_ textField: UITextField, context: Context) {
        if isEditing {
            textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        textField.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isEditing: $isEditing, onEditingFinished: onEditingFinished)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String?
        @Binding var isEditing: Bool
        let onEditingFinished: (() -> Void)?
        
        init(text: Binding<String?>, isEditing: Binding<Bool>, onEditingFinished: (() -> Void)?) {
            _text = text
            _isEditing = isEditing
            self.onEditingFinished = onEditingFinished
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            isEditing = false
            text = textField.text
            onEditingFinished?()
        }
    }
    
    
}

