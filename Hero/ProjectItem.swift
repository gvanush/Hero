//
//  ProjectItem.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/26/20.
//
import CoreFoundation
import SwiftUI
import Combine

struct ProjectItem: View {
    
    @State var enteredName: String = ""
    @ObservedObject var model: ProjectItemModel
    @State var alertType: AlertType?
    var onTapAction: () -> Void
    
    enum AlertType: Identifiable {
        case renameFailed
        
        var id: AlertType { self }
    }
    
    init(model: ProjectItemModel, onTapAction: @escaping () -> Void) {
        self.model = model
        self.onTapAction = onTapAction
    }
    
    var body: some View {
        
        VStack(spacing: 10) {
            ZStack {
                Color(.secondarySystemBackground)
                    .aspectRatio(contentMode: .fit)
                if let preview = model.preview {
                    Image(uiImage: preview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "folder")
                        .font(.system(size: 30, weight: .light))
                }

            }
            .cornerRadius(ProjectItem.cornerRadius)
            .padding(3)
            .overlay(
                Group {
                    if model.isSelected {
                        RoundedRectangle(cornerRadius: ProjectItem.cornerRadius + 3)
                            .stroke(Color.accentColor, lineWidth: ProjectItem.imageBorderSize)
                    }
                }
            )
            
            TextField(model.name, text: $enteredName, onEditingChanged: { isEditing in
                if !isEditing {
                    if !model.rename(to: enteredName) {
                        alertType = .renameFailed
                    }
                    enteredName = model.name
                }
            })
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(model.isSelected ? Color.accentColor : Color(.label))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 5.0)
            .onAppear(perform: {
                enteredName = model.name
            })
        }
        .scaleEffect(model.isSelected ? 1.03 : 1.0)
        .alert(item: $alertType) { type in
            alert(for: type)
        }
        .onTapGesture(perform: onTapAction)
        .onAppear() {
            model.loadPreview()
        }
    }
    
    func alert(for type: AlertType) -> Alert {
        switch type {
        case .renameFailed:
            return Alert(title: Text("Failed to rename project"), message: Text(Settings.genericUserErrorMessage), dismissButton: nil)
        }
    }
    
    // MARK: Drawing constants
    static let imageBorderSize: CGFloat = 3.0
    static let cornerRadius: CGFloat = 3.0
}

struct NewProjectItem: View {
    
    let onTapAction: () -> Void
    
    init(onTapAction: @escaping () -> Void) {
        self.onTapAction = onTapAction
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Color(.secondarySystemBackground)
                    .aspectRatio(contentMode: .fit)
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .light))
            }
            .cornerRadius(ProjectItem.cornerRadius)
            Text("New")
                .font(.system(size: 15, weight: .regular))
        }
            .onTapGesture(count: 1) {
                onTapAction()
            }
    }
}

struct ProjectItem_Previews: PreviewProvider {
    static var previews: some View {
        ProjectItem(model: ProjectItemModel(project: Project(name: "MyProj"))) {}
            .preferredColorScheme(.dark)
    }
}
