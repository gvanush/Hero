//
//  ProjectView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/26/20.
//
import CoreFoundation
import SwiftUI

struct ProjectView: View {
    
    class ViewModel: Identifiable, ObservableObject {
        
        private(set) var project: Project
        @Published var isSelected: Bool
        
        init(project: Project) {
            self.project = project
            self.isSelected = false
        }
        
        var id: UUID {
            project.metadata.id
        }
        
        var name: String {
            get {
                if let name = project.metadata.name {
                    return name
                }
                
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                return "Project \(df.string(from: project.metadata.creationDate))"
            }
            set {
                let trimmedName = newValue.trimmingCharacters(in: .whitespaces)
                project.metadata.name = trimmedName.isEmpty ? nil : trimmedName
            }
        }
        
        var preview: UIImage? {
            return UIImage(named: "project_preview_sample")!
//            switch project.preview {
//            case .notLoaded, .none:
//                return nil
//            case .some(let image):
//                return image
//            }
        }
        
        func loadPreview() throws {
            try ProjectStore.shared.loadProjectPreview(project)
        }
        
        func saveProject() throws {
            try ProjectStore.shared.saveProject(project)
        }
        
    }
    
    @State var enteredName: String = ""
    @ObservedObject var viewModel: ViewModel
    var onTapAction: () -> Void
    
    init(viewModel: ViewModel, onPressAction: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onTapAction = onPressAction
    }
    
    var body: some View {
        
        VStack(spacing: 10) {
            ZStack {
                ProjectBgrView()
                if let preview = viewModel.preview {
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
                    if viewModel.isSelected {
                        RoundedRectangle(cornerRadius: ProjectBgrView.cornerRadius)
                            .stroke(Color.accentColor, lineWidth: ProjectView.imageBorderSize)
                    }
                }
            )
            
            TextField(viewModel.name, text: $enteredName, onEditingChanged: {isEditing in
                if !isEditing {
                    viewModel.name = enteredName
                    enteredName = viewModel.name
                    do {
                        try viewModel.saveProject()
                    } catch {
                        assertionFailure(error.localizedDescription)
                        // TODO: show error alert
                    }
                }
            })
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(viewModel.isSelected ? Color.accentColor : Color(.label))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 5.0)
            .onAppear(perform: {
                enteredName = viewModel.name
            })
        }
        .scaleEffect(viewModel.isSelected ? 1.03 : 1.0)
        .onTapGesture(perform: onTapAction)
        .onAppear() {
            try? viewModel.loadPreview()
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
