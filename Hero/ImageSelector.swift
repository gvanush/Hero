//
//  ImagePicker.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI

struct ImageSelector: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIImagePickerController
    
    @Environment(\.presentationMode) var presentationMode
    let action: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let imagePicker: ImageSelector
        
        init(_ imagePicker: ImageSelector) {
            self.imagePicker = imagePicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                imagePicker.action(image)
            }
            imagePicker.presentationMode.wrappedValue.dismiss()
        }
        
    }
    
}
