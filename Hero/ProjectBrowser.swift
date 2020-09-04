//
//  ProjectBrowser.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/30/20.
//

import SwiftUI

struct ProjectBrowser: View {
    
    class ViewModel: ObservableObject {
        
        @Published private (set) var projects: [ProjectView.ViewModel]
        
        var selectedProject: ProjectView.ViewModel! {
            get {
                projects.first(where: { $0.isSelected })
            }
            set {
                guard let newlySelected = projects.first(where: { $0.id == newValue.id }) else {
                    assertionFailure("Invalid project selected")
                    return
                }
                if let selectedProject = self.selectedProject {
                    selectedProject.isSelected = false
                }
                newlySelected.isSelected = true
            }
        }
        
        init(projects: [ProjectView.ViewModel] = []) {
            self.projects = projects
        }
        
        func remove(project: ProjectView.ViewModel) {
            guard let index = projects.firstIndex(where: {$0.id == project.id}) else {return}
            projects.remove(at: index)
            if projects.isEmpty {
                // TODO: create a new project and dismiss
                return
            }
            selectedProject = (index < projects.count ? projects[index] : projects.last!)
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isProjectActionSheetPresented = false
    @State private var isProjectDeleteConfirmationActionSheetPresented = false
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 30) {
                    NewProjectView()
                    ForEach(viewModel.projects) { projectViewModel in
                        ProjectView(viewModel: projectViewModel) {
                            UIApplication.shared.hideKeyboard()
                            withAnimation(.easeOut(duration: 0.25)) {
                                viewModel.selectedProject = projectViewModel
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("Projects")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                        .fontWeight(.regular)
                        .minTappableFrame(alignment: .leading)
                }), trailing: Button(action: {
                    isProjectActionSheetPresented.toggle()
                }, label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 25, weight: .regular))
                        .minTappableFrame(alignment: .trailing)
                }))
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Spacer()
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }, label: {
                                Text("Open")
                                    .fontWeight(.semibold)
                                    .minTappableFrame(alignment: .center)
                            })
                            Spacer()
                        }
                    }
                }
                .actionSheet(isPresented: $isProjectActionSheetPresented, content: {
                    ActionSheet(title: Text(viewModel.selectedProject.name), message: nil, buttons: [.default(Text("Duplicate")) {
                        // TODO: Duplicate
                    }, .default(Text("Delete")) {
                        isProjectDeleteConfirmationActionSheetPresented.toggle()
                    }, .cancel()])
                })
            }
        }
        .actionSheet(isPresented: $isProjectDeleteConfirmationActionSheetPresented, content: {
            ActionSheet(title: Text(viewModel.selectedProject.name), message: nil, buttons: [.destructive(Text("Delete")) {
                withAnimation {
                    viewModel.remove(project: viewModel.selectedProject)
                }
            }, .cancel()])
        })
    }
}

struct NewProjectView: View {
    var body: some View {
        VStack {
            ZStack {
                Color(.secondarySystemBackground)
                    .cornerRadius(5.0)
                    .padding(2)
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .light))
            }
            Text("New")
                .font(.system(size: 15, weight: .regular))
        }
    }
}

struct ProjectView_Previews: PreviewProvider {
    
    static let projectPreviewSample = UIImage(named: "project_preview_sample")!
    
    static var previews: some View {
        ProjectBrowser(viewModel: ProjectBrowser.ViewModel(projects: [
            ProjectView.ViewModel(project: Project(id: UUID(), name: "Blocks", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: true),
            ProjectView.ViewModel(project: Project(id: UUID(), name: nil, preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
            ProjectView.ViewModel(project: Project(id: UUID(), name: "Dark Effect", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
            ProjectView.ViewModel(project: Project(id: UUID(), name: "Inspire", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
            ProjectView.ViewModel(project: Project(id: UUID(), name: nil, preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
            ProjectView.ViewModel(project: Project(id: UUID(), name: "Salute", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
            ProjectView.ViewModel(project: Project(id: UUID(), name: "Beuty", preview: projectPreviewSample, lastModifiedDate: Date()), isSelected: false),
        ]))
    }
}
