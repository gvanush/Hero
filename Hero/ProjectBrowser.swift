//
//  ProjectBrowser.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/30/20.
//

import SwiftUI

struct ProjectBrowser: View {
    
    class ViewModel: ObservableObject {
        
        @Published var projects: [ProjectView.ViewModel]
        @Published var isProjectActionSheetPresented = false
        @Published var isProjectDeleteConfirmationActionSheetPresented = false
        
        var selectedProject: ProjectView.ViewModel {
            projects.first(where: { $0.isSelected })!
        }
        
        init(projects: [ProjectView.ViewModel] = []) {
            self.projects = projects
        }
        
        func select(project: ProjectView.ViewModel) {
            selectedProject.isSelected = false
            
            if let newlySelected = projects.first(where: { $0.id == project.id }) {
                newlySelected.isSelected = true
            }
            
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    
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
                            viewModel.select(project: projectViewModel)
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
                    viewModel.isProjectActionSheetPresented.toggle()
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
                .actionSheet(isPresented: $viewModel.isProjectActionSheetPresented, content: {
                    ActionSheet(title: Text(viewModel.selectedProject.name), message: nil, buttons: [.default(Text("Duplicate")) {
                        
                    }, .default(Text("Delete")) {
                        viewModel.isProjectDeleteConfirmationActionSheetPresented.toggle()
                    }, .cancel()])
                })
            }
        }
        .actionSheet(isPresented: $viewModel.isProjectDeleteConfirmationActionSheetPresented, content: {
            ActionSheet(title: Text(viewModel.selectedProject.name), message: nil, buttons: [.destructive(Text("Delete")) {
                // TODO: Delete project
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
