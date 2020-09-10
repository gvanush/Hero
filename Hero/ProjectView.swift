//
//  ProjectView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/26/20.
//
import CoreFoundation
import SwiftUI
import Combine

struct ProjectView: View {
    
    class ViewModel: Identifiable, ObservableObject {
        
        let project: Project
        var projectCancellable: AnyCancellable?
        @Published var isSelected: Bool
        
        init(project: Project) {
            self.project = project
            self.isSelected = false
            projectCancellable = project.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }
        }
        
        var id: UUID {
            project.id
        }
        
        var name: String {
            get {
                if let name = project.name {
                    return name
                }
                
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                return "Project \(df.string(from: project.creationDate))"
            }
            set {
                let oldName = project.name
                let trimmedName = newValue.trimmingCharacters(in: .whitespaces)
                project.name = trimmedName.isEmpty ? nil : trimmedName
                
                do {
                    try ProjectStore.shared.saveProject(project)
                } catch {
                    project.name = oldName
                    assertionFailure(error.localizedDescription)
                    // TODO: Show alert
                }
            }
        }
        
        var preview: UIImage? {
            switch project.preview {
            case .notLoaded, .none:
                return nil
            case .some(let image):
                return image
            }
        }
        
        func loadPreview() {
            do {
                try ProjectStore.shared.loadProjectPreview(project)
            } catch {
                assertionFailure(error.localizedDescription)
            }
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
            viewModel.loadPreview()
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
