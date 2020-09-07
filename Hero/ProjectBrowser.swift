//
//  ProjectBrowser.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/30/20.
//

import SwiftUI

struct ProjectBrowser: View {
    
    class ViewModel: ObservableObject {
        
        @Published private (set) var projectViewModels: [ProjectView.ViewModel]?
        private let openedProject: Project?
        
        init(openedProject: Project? = nil) {
            self.openedProject = openedProject
        }
        
        init(projects: [Project], openedProject: Project? = nil) {
            self.openedProject = openedProject
            setupProjectViewModels(projects: projects)
        }
        
        func loadProjects() throws {
            let projects = try ProjectStore.shared.loadProjects()
            setupProjectViewModels(projects: projects)
        }
        
        var isEachProjectLoaded: Bool {
            projectViewModels != nil
        }
        
        var selectedProjectViewModel: ProjectView.ViewModel? {
            get {
                projectViewModels?.first(where: { $0.isSelected })
            }
            set {
                objectWillChange.send()
                if let selectedProject = self.selectedProjectViewModel {
                    selectedProject.isSelected = false
                }
                newValue?.isSelected = true
            }
        }
        
        var isProjectSelected: Bool {
            selectedProjectViewModel != nil
        }
        
        func createProject() throws -> ProjectView.ViewModel? {
            guard isEachProjectLoaded else {
                assertionFailure()
                return nil
            }
            let project = Project(metadata: .init())
            try ProjectStore.shared.saveProject(project)
            let projectViewModel = ProjectView.ViewModel(project: project)
            projectViewModels!.append(projectViewModel)
            return projectViewModel
        }
        
        func removeProject(_ projectViewModel: ProjectView.ViewModel) throws {
            guard isEachProjectLoaded else {
                assertionFailure()
                return
            }
            try ProjectStore.shared.removeProject(projectViewModel.project)
            guard let index = projectViewModels!.firstIndex(where: {$0.id == projectViewModel.id}) else {return}
            projectViewModels!.remove(at: index)
        }
        
        private func setupProjectViewModels(projects: [Project]) {
            var projects = projects
            if let openedProject = openedProject {
                if let index = projects.firstIndex(where: {$0.metadata.id == openedProject.metadata.id}) {
                    projects[index] = openedProject
                }
            }
            projects.sort { $0.metadata.lastModifiedDate < $1.metadata.lastModifiedDate }
            var projectViewModels = [ProjectView.ViewModel]()
            projectViewModels.reserveCapacity(projects.count)
            for project in projects {
                let projectViewModel = ProjectView.ViewModel(project: project)
                projectViewModels.append(projectViewModel)
            }
            if let openedProject = openedProject {
                projectViewModels.first {$0.id == openedProject.metadata.id}?.isSelected = true
            } else if !projectViewModels.isEmpty {
                projectViewModels.last!.isSelected = true
            }
            self.projectViewModels = projectViewModels
        }
        
    }
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isProjectActionSheetPresented = false
    @State private var isProjectDeleteConfirmationActionSheetPresented = false
    private let onProjectOpenAction: ((Project) -> Void)?
    private let onProjectRemoveAction: ((Project) -> Void)?
    
    init(viewModel: ViewModel, onProjectRemoveAction: ((Project) -> Void)? = nil, onProjectOpenAction: ((Project) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onProjectOpenAction = onProjectOpenAction
        self.onProjectRemoveAction = onProjectRemoveAction
    }
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isEachProjectLoaded {
                    LazyVGrid(columns: columns, spacing: 30) {
                        NewProjectView() {
                            withAnimation {
                                do {
                                    if let projectViewModel = try viewModel.createProject() {
                                        viewModel.selectedProjectViewModel = projectViewModel
                                    }
                                } catch {
                                    assertionFailure(error.localizedDescription)
                                }
                            }
                        }
                        ForEach(viewModel.projectViewModels!.reversed()) { projectViewModel in
                            ProjectView(viewModel: projectViewModel) {
                                UIApplication.shared.hideKeyboard()
                                withAnimation(.easeOut(duration: 0.25)) {
                                    viewModel.selectedProjectViewModel = projectViewModel
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
                        Text("Close")
                            .fontWeight(.regular)
                            .minTappableFrame(alignment: .leading)
                    }), trailing: Button(action: {
                        if viewModel.selectedProjectViewModel != nil {
                            isProjectActionSheetPresented.toggle()
                        }
                    }, label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 25, weight: .regular))
                            .minTappableFrame(alignment: .trailing)
                    }).disabled(!viewModel.isProjectSelected))
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            HStack {
                                Spacer()
                                Button(action: {
                                    onProjectOpenAction?(viewModel.selectedProjectViewModel!.project)
                                    presentationMode.wrappedValue.dismiss()
                                }, label: {
                                    Text("Open")
                                        .fontWeight(.semibold)
                                        .minTappableFrame(alignment: .center)
                                })
                                .disabled(!viewModel.isProjectSelected)
                                Spacer()
                            }
                        }
                    }
                    .actionSheet(isPresented: $isProjectActionSheetPresented, content: {
                        ActionSheet(title: Text(viewModel.selectedProjectViewModel!.name), message: nil, buttons: [.default(Text("Duplicate")) {
                            // TODO: Duplicate
                        }, .default(Text("Delete")) {
                            isProjectDeleteConfirmationActionSheetPresented.toggle()
                            onProjectRemoveAction?(viewModel.selectedProjectViewModel!.project)
                        }, .cancel()])
                    })
                }
            }
        }
        .actionSheet(isPresented: $isProjectDeleteConfirmationActionSheetPresented, content: {
            ActionSheet(title: Text(viewModel.selectedProjectViewModel!.name), message: nil, buttons: [.destructive(Text("Delete")) {
                withAnimation {
                    do {
                        try viewModel.removeProject(viewModel.selectedProjectViewModel!)
                    } catch {
                        assertionFailure("Failed to delete project")
                        // TODO: show alert with message?
                    }
                }
            }, .cancel()])
        })
        .onAppear {
            do {
                try viewModel.loadProjects()
            } catch {
                assertionFailure(error.localizedDescription)
                // TODO: Show alert with 'Failed to load projects, try again later or contact support'
            }
        }
    }
}

struct ProjectView_Previews: PreviewProvider {
    
    static let projectPreviewSample = UIImage(named: "project_preview_sample")!
    
    static var previews: some View {
        ProjectBrowser(viewModel: ProjectBrowser.ViewModel(projects: [
            Project(metadata: .init(name: "Blocks")),
            Project(metadata: .init()),
            Project(metadata: .init(name: "Dark Effect")),
            Project(metadata: .init(name: "Inspire")),
            Project(metadata: .init()),
            Project(metadata: .init(name: "Salute")),
            Project(metadata: .init(name: "Beuty")),
        ]))
    }
}
