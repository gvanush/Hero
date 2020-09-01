//
//  TextInputAlert.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/31/20.
//

import SwiftUI

struct TextInputAlert<Content: View>: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool
    let title: String?
    let messsage: String?
    let text: String?
    let placeholder: String?
    let cancelAction: (() -> Void)?
    let doneActionText: String
    let doneAction: (String?) -> Void
    let content: Content
    
    final class Coordinator {
        var alertController: UIAlertController?
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> UIHostingController<Content> {
        UIHostingController<Content>(rootView: content)
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        if isPresented {
            guard uiViewController.presentedViewController == nil else {return}
            
            let alertController = UIAlertController(title: title, message: messsage, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.text = text
                textField.placeholder = placeholder
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                isPresented = false
                cancelAction?()
            }))
            
            let textField = alertController.textFields!.first!
            alertController.addAction(UIAlertAction(title: doneActionText, style: .default, handler: { alertAction in
                isPresented = false
                doneAction(textField.text)
            }))
            
            context.coordinator.alertController = alertController
            uiViewController.present(context.coordinator.alertController!, animated: true)
            
        } else {
            guard uiViewController.presentedViewController == context.coordinator.alertController else {return}
            uiViewController.dismiss(animated: true)
            context.coordinator.alertController = nil
        }
    }
}

extension View {
    public func textInputAlert(isPresented: Binding<Bool>, title: String? = nil, messsage: String? = nil, text: String? = nil, placeholder: String? = nil, cancelAction: (() -> Void)? = nil, doneActionText: String = "Done", doneAction: @escaping (String?) -> Void) -> some View {
        TextInputAlert(isPresented: isPresented, title: title, messsage: messsage, text: text, placeholder: placeholder, cancelAction: cancelAction, doneActionText: doneActionText, doneAction: doneAction, content: self)
    }
}

struct TestView: View {
    
    @State var isAlertPresented = false
    
    var body: some View {
        VStack {
            Button(action: {
                isAlertPresented.toggle()
            }, label: {
                Text("Show")
            })
        }.textInputAlert(isPresented: $isAlertPresented, title: "Rename Project", messsage: "Enter a new name", text: nil, placeholder: "projx", cancelAction: nil, doneActionText: "Save") { newName in
            print(newName ?? "")
        }
    }
}

struct TextInputAlert_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
