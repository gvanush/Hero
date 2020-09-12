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
    var onTapAction: () -> Void
    
    init(model: ProjectItemModel, onTapAction: @escaping () -> Void) {
        self.model = model
        self.onTapAction = onTapAction
    }
    
    var body: some View {
        
        VStack(spacing: 10) {
            ZStack {
                ProjectBgrView()
                if let preview = model.preview {
                    Image(uiImage: preview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "folder")
                        .font(.system(size: 30, weight: .light))
                }

            }
            .cornerRadius(ProjectBgrView.cornerRadius - 2)
            .padding(3)
            .overlay(
                Group {
                    if model.isSelected {
                        RoundedRectangle(cornerRadius: ProjectBgrView.cornerRadius)
                            .stroke(Color.accentColor, lineWidth: ProjectItem.imageBorderSize)
                    }
                }
            )
            
            TextField(model.name, text: $enteredName, onEditingChanged: {isEditing in
                if !isEditing {
                    model.name = enteredName
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
        .onTapGesture(perform: onTapAction)
        .onAppear() {
            model.loadPreview()
        }
    }
    
    // MARK: Drawing constants
    static let imageBorderSize: CGFloat = 3.0
}

struct NewProjectView: View {
    
    let onTapAction: () -> Void
    
    init(onTapAction: @escaping () -> Void) {
        self.onTapAction = onTapAction
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                ProjectBgrView()
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .light))
            }
            Text("New")
                .font(.system(size: 15, weight: .regular))
        }
            .onTapGesture(count: 1) {
                onTapAction()
            }
    }
}

struct ProjectBgrView: View {
    var body: some View {
        Color(.secondarySystemBackground)
            .cornerRadius(ProjectBgrView.cornerRadius)
            .aspectRatio(contentMode: .fit)
    }
    
    static let cornerRadius: CGFloat = 5.0
}
