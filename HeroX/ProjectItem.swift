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
    
    @State var enteredName: String?
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
        
        VStack(spacing: ProjectItem.verticalSpacing) {
            ZStack {
                Color(.secondarySystemBackground)
                    .aspectRatio(contentMode: .fill)
                if let preview = model.preview {
                    Image(uiImage: preview)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "folder")
                        .font(.system(size: 30, weight: .light))
                }

            }
            .cornerRadius(ProjectItem.cornerRadius)
            .padding(ProjectItem.padding)
            .overlay(
                Group {
                    if model.isSelected {
                        RoundedRectangle(cornerRadius: ProjectItem.cornerRadius + 2)
                            .stroke(Color.accentColor, lineWidth: ProjectItem.imageBorderSize)
                    }
                }
            )
            .scaleEffect(model.isSelected ? 1.03 : 1.0)
            
            Group {
                if model.isRenaming {
                    UITextFieldProxy(text: $enteredName, isEditing: $model.isRenaming, placeholder: model.name, textAlignment: .center, font: .systemFont(ofSize: ProjectItem.nameFontSize, weight: .regular)) {
                        if let enteredName = enteredName, !model.rename(to: enteredName) {
                            alertType = .renameFailed
                        }
                        enteredName = nil
                    }
                        .padding(.horizontal, 5.0)
                } else {
                    Text(model.name)
                        .lineLimit(1)
                        .font(.system(size: ProjectItem.nameFontSize, weight: .regular))
                        .foregroundColor(model.isSelected ? Color.accentColor : Color(.label))
                }
            }
                .padding(.horizontal, 5.0)
        }
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
    
    // MARK: Constants
    static let imageBorderSize: CGFloat = 2.0
    static let cornerRadius: CGFloat = 3.0
    static let padding: CGFloat = 3.0
    static let nameFontSize: CGFloat = 15
    static let verticalSpacing: CGFloat = 8
}

struct NewProjectItem: View {
    
    let onTapAction: () -> Void
    
    init(onTapAction: @escaping () -> Void) {
        self.onTapAction = onTapAction
    }
    
    var body: some View {
        VStack(spacing: ProjectItem.verticalSpacing) {
            ZStack {
                Color(.secondarySystemBackground)
                    .aspectRatio(contentMode: .fit)
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.accentColor)
            }
            .cornerRadius(ProjectItem.cornerRadius)
            .padding(ProjectItem.padding)
            Text("New")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.accentColor)
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
