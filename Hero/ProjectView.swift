//
//  ProjectView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/26/20.
//
import CoreFoundation
import SwiftUI

class Project: Identifiable {
    var id: UUID
    var name: String?
    var preview: UIImage
    var lastModifiedDate: Date
    var creationDate = Date()
    
    init(id: UUID, name: String?, preview: UIImage, lastModifiedDate: Date) {
        self.id = id
        self.name = name
        self.preview = preview
        self.lastModifiedDate = lastModifiedDate
    }
}

struct ProjectView: View {
    
    class ViewModel: Identifiable, ObservableObject {
        
        @Published private var project: Project
        @Published var isSelected: Bool
        
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
                let trimmedName = newValue.trimmingCharacters(in: .whitespaces)
                project.name = trimmedName.isEmpty ? nil : trimmedName
            }
        }
        
        var preview: UIImage {
            project.preview
        }
        
        init(project: Project, isSelected: Bool) {
            self.project = project
            self.isSelected = isSelected
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
        
        VStack {
            Image(uiImage: viewModel.preview)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(ProjectView.imageCornerRadius - 2)
                .padding(3)
                .overlay(
                    Group {
                        if viewModel.isSelected {
                            RoundedRectangle(cornerRadius: ProjectView.imageCornerRadius)
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
            .padding(.horizontal, 5.0)
            .foregroundColor(viewModel.isSelected ? Color.accentColor : Color(.label))
            .multilineTextAlignment(.center)
            .font(.system(size: 15, weight: .regular))
            .onAppear(perform: {
                enteredName = viewModel.name
            })
        }
        .scaleEffect(viewModel.isSelected ? 1.03 : 1.0)
        .onTapGesture(perform: onTapAction)
//        .onLongPressGesture(perform: onTapAction)
        
    }
    
    // MARK: Drawing constants
    static let imageCornerRadius: CGFloat = 5.0
    static let imageBorderSize: CGFloat = 3.0
}

class RootViewModel: ObservableObject {
    @Published var isProjectBrowserViewPresented = false
}

struct RootView: View {
    
    @ObservedObject var viewModel = RootViewModel()
    
    var body: some View {
        NavigationView {
            Color(.lightGray)
                .navigationBarItems(leading: Button(action: {
                    viewModel.isProjectBrowserViewPresented.toggle()
                }, label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 25, weight: .regular))
                        .minTappableFrame(alignment: .leading)
                }))
        }
        .fullScreenCover(isPresented: $viewModel.isProjectBrowserViewPresented, content: {
            let projectPreviewSample = UIImage(named: "project_preview_sample")!
            ProjectBrowser(viewModel: ProjectBrowser.ViewModel(
                projects: [
                    ProjectView.ViewModel(project: Project(id: UUID(), name: "Blocks", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: true),
                    ProjectView.ViewModel(project: Project(id: UUID(), name: nil, preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
                    ProjectView.ViewModel(project: Project(id: UUID(), name: "Dark Effect", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
                    ProjectView.ViewModel(project: Project(id: UUID(), name: "Inspire", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
                    ProjectView.ViewModel(project: Project(id: UUID(), name: nil, preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
                    ProjectView.ViewModel(project: Project(id: UUID(), name: "Salute", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
                    ProjectView.ViewModel(project: Project(id: UUID(), name: "Beuty", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
                ]
        ))})
    }
}
