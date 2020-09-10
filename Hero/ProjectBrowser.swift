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
        
        func loadProjects() {
            do {
                setupProjectViewModels(projects: try ProjectStore.shared.loadProjects())
            } catch {
                assertionFailure(error.localizedDescription)
                // TODO: Show alert with 'Failed to load projects, try again later or contact support'
            }
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
            let project = Project()
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
        
        func duplicateProject(_ projectViewModel: ProjectView.ViewModel) throws -> ProjectView.ViewModel? {
            guard isEachProjectLoaded else {
                assertionFailure()
                return nil
            }
            let project = try ProjectStore.shared.duplicateProject(projectViewModel.project)
            let projectViewModel = ProjectView.ViewModel(project: project)
            projectViewModels!.append(projectViewModel)
            return projectViewModel
        }
        
        func next(to projectViewModel: ProjectView.ViewModel) -> ProjectView.ViewModel? {
            guard isEachProjectLoaded else {
                assertionFailure()
                return nil
            }
            guard let index = projectViewModels!.firstIndex(where: {$0.id == projectViewModel.id}) else {
                return nil
            }
            if index < projectViewModels!.count - 1 {
                return projectViewModels![index + 1]
            }
            return nil
        }
        
        func prev(to projectViewModel: ProjectView.ViewModel) -> ProjectView.ViewModel? {
            guard isEachProjectLoaded else {
                assertionFailure()
                return nil
            }
            guard let index = projectViewModels!.firstIndex(where: {$0.id == projectViewModel.id}) else {
                return nil
            }
            if index > 0 {
                return projectViewModels![index - 1]
            }
            return nil
        }
        
        private func setupProjectViewModels(projects: [Project]) {
            var projects = projects
            if let openedProject = openedProject {
                if let index = projects.firstIndex(where: {$0.id == openedProject.id}) {
                    projects[index] = openedProject
                }
            }
            projects.sort { $0.lastModifiedDate < $1.lastModifiedDate }
            var projectViewModels = [ProjectView.ViewModel]()
            projectViewModels.reserveCapacity(projects.count)
            for project in projects {
                let projectViewModel = ProjectView.ViewModel(project: project)
                projectViewModels.append(projectViewModel)
            }
            if let openedProject = openedProject {
                projectViewModels.first {$0.id == openedProject.id}?.isSelected = true
            } else if !projectViewModels.isEmpty {
                projectViewModels.last!.isSelected = true
            }
            self.projectViewModels = projectViewModels
        }
        
    }
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var actionSheetType: ActionSheetType? = nil
    private let onProjectOpenAction: ((Project) -> Void)?
    private let onProjectCreateAction: ((Project) -> Void)?
    private let onProjectRemoveAction: ((Project) -> Void)?
    
    enum ActionSheetType: Identifiable {
        
        var id: ActionSheetType { self }
        
        case projectOptions
        case projectDeleteConfirmation
    }
    
    init(viewModel: ViewModel, onProjectCreateAction: ((Project) -> Void)? = nil, onProjectRemoveAction: ((Project) -> Void)? = nil, onProjectOpenAction: ((Project) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onProjectOpenAction = onProjectOpenAction
        self.onProjectCreateAction = onProjectCreateAction
        self.onProjectRemoveAction = onProjectRemoveAction
    }
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ScrollViewReader { scrollViewProxy in
                    Group {
                        if viewModel.isEachProjectLoaded {
                            projectsGrid()
                        }
                    }
                        .navigationTitle("Projects")
                        .navigationBarTitleDisplayMode(.large)
                        .navigationBarItems(leading: Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Close")
                                .fontWeight(.regular)
                                .minTappableFrame(alignment: .leading)
                        }), trailing: projectOptionsBarItem())
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
                        .actionSheet(item: $actionSheetType) { type in
                            switch type {
                                case .projectOptions:
                                    return projectOptionsActionSheet(scrollViewProxy: scrollViewProxy)
                                case .projectDeleteConfirmation:
                                    return projectDeleteConfirmationActionSheet()
                            }
                        }
                        
                }
            }
        }
        .onAppear {
            viewModel.loadProjects()
        }
    }
    
    private func projectOptionsBarItem() -> some View {
        Button(action: {
            if viewModel.selectedProjectViewModel != nil {
                actionSheetType = .projectOptions
            }
        }, label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 25, weight: .regular))
                .minTappableFrame(alignment: .trailing)
        })
            .disabled(!viewModel.isProjectSelected)
    }
    
    private func projectsGrid() -> some View {
        LazyVGrid(columns: columns, spacing: 30) {
            NewProjectView() {
                withAnimation {
                    do {
                        try createProject()
                    } catch {
                        assertionFailure(error.localizedDescription)
                        // TODO: show error alers?
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
        .id(ProjectBrowser.gridId)
        .padding()
    }
    
    private func projectOptionsActionSheet(scrollViewProxy: ScrollViewProxy) -> ActionSheet {
        ActionSheet(title: Text(viewModel.selectedProjectViewModel!.name), message: nil, buttons: [.default(Text("Duplicate")) {
            withAnimation {
                do {
                    if let projectViewModel = try viewModel.duplicateProject(viewModel.selectedProjectViewModel!) {
                        viewModel.selectedProjectViewModel = projectViewModel
                        scrollViewProxy.scrollTo(ProjectBrowser.gridId, anchor: .top)
                    }
                } catch {
                    assertionFailure(error.localizedDescription)
                    // TODO: show error alers?
                }
            }
        }, .default(Text("Delete")) {
            actionSheetType = .projectDeleteConfirmation
        }, .cancel()])
    }
    
    private func projectDeleteConfirmationActionSheet() -> ActionSheet {
        ActionSheet(title: Text(viewModel.selectedProjectViewModel!.name), message: nil, buttons: [.destructive(Text("Delete")) {
            withAnimation {
                do {
                    let selected = viewModel.selectedProjectViewModel!
                    let projectToSelect = viewModel.prev(to: selected) ?? viewModel.next(to: selected)
                    try viewModel.removeProject(selected)
                    onProjectRemoveAction?(selected.project)
                    if let projectToSelect = projectToSelect {
                        viewModel.selectedProjectViewModel = projectToSelect
                    } else {
                        try createProject()
                    }
                } catch {
                    assertionFailure("Failed to delete project")
                    // TODO: show alert with message?
                }
            }
        }, .cancel()])
    }
    
    private func createProject() throws {
        guard let projectViewModel = try viewModel.createProject() else {return}
        viewModel.selectedProjectViewModel = projectViewModel
        onProjectCreateAction?(projectViewModel.project)
    }
    
    static let gridId = 1
}

struct ProjectView_Previews: PreviewProvider {
    
    static let projectPreviewSample = UIImage(named: "project_preview_sample")!
    
    static var previews: some View {
        ProjectBrowser(viewModel: ProjectBrowser.ViewModel(projects: [
            Project(name: "Blocks"),
            Project(),
            Project(name: "Dark Effect"),
            Project(name: "Inspire"),
            Project(),
            Project(name: "Salute"),
            Project(name: "Beuty"),
        ]))
    }
}
