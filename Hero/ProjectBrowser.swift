//
//  ProjectBrowser.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/30/20.
//

import SwiftUI
import os

struct ProjectBrowser: View {
    
    @ObservedObject var model: ProjectBrowserModel
    @Environment(\.presentationMode) var presentationMode
    @State private var actionSheetType: ActionSheetType?
    @State private var alertType: AlertType?
    private let onOpenAction: ((Project) -> Void)?
    private let onRemoveAction: ((Project) -> Void)?
    private let logger: Logger
    
    enum ActionSheetType: Identifiable {
        case projectOptions
        case projectDeleteConfirmation
        
        var id: ActionSheetType { self }
    }
    
    enum AlertType: Identifiable {
        case loadFailed
        case createFailed
        case duplicateFailed
        case removeFailed
        
        var id: AlertType { self }
    }
    
    init(model: ProjectBrowserModel, onRemoveAction: ((Project) -> Void)? = nil, onOpenAction: ((Project) -> Void)? = nil) {
        self.model = model
        self.onOpenAction = onOpenAction
        self.onRemoveAction = onRemoveAction
        logger = Logger(category: "projectbrowser")
        
        self.model.logger = logger
    }
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 12), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ScrollViewReader { scrollViewProxy in
                    Group {
                        if model.isLoaded {
                            projectsGrid()
                        }
                    }
                        .navigationTitle("Projects")
                        .navigationBarTitleDisplayMode(.large)
                        .navigationBarItems(leading: Button(action: {
                            logger.notice("Close")
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
                                        if let selectedProject = model.selected {
                                            logger.notice("Open project: \(selectedProject, privacy: .public)")
                                            presentationMode.wrappedValue.dismiss()
                                            onOpenAction?(selectedProject)
                                        } else {
                                            assertionFailure()
                                            logger.fault("There is no selected project but openning project is requested")
                                        }
                                    }, label: {
                                        Text("Open")
                                            .fontWeight(.semibold)
                                            .minTappableFrame(alignment: .center)
                                    })
                                    .disabled(!model.isSelected)
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
                    .alert(item: $alertType) { type in
                        alert(for: type)
                    }
                        
                }
            }
        }
        .onAppear {
            if !model.load() {
                alertType = .loadFailed
            }
        }
    }
    
    private func projectOptionsBarItem() -> some View {
        Button(action: {
            actionSheetType = .projectOptions
        }, label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 25, weight: .regular))
                .minTappableFrame(alignment: .trailing)
        })
            .disabled(!model.isSelected)
    }
    
    private func projectsGrid() -> some View {
        LazyVGrid(columns: columns, spacing: 20) {
            NewProjectItem() {
                withAnimation {
                    createProject()
                }
            }
            ForEach(model.itemModels!.reversed()) { itemModel in
                ProjectItem(model: itemModel) {
                    logger.notice("Select project: \(itemModel.project, privacy: .public)")
                    UIApplication.shared.hideKeyboard()
                    withAnimation(.easeOut(duration: 0.25)) {
                        model.selected = itemModel.project
                    }
                }
            }
        }
        .id(ProjectBrowser.gridId)
        .padding()
    }
    
    private func projectOptionsActionSheet(scrollViewProxy: ScrollViewProxy) -> ActionSheet {
        ActionSheet(title: Text(model.selectedItemModel!.name), message: nil, buttons: [.default(Text("Rename")) {
            if let selectedItemModel = model.selectedItemModel {
                selectedItemModel.isRenaming = true
            }
        }, .default(Text("Duplicate")) {
            withAnimation {
                if let newProject = model.duplicate(model.selected!) {
                    model.selected = newProject
                    scrollViewProxy.scrollTo(ProjectBrowser.gridId, anchor: .top)
                } else {
                    alertType = .duplicateFailed
                }
            }
        }, .default(Text("Delete")) {
            actionSheetType = .projectDeleteConfirmation
        }, .cancel()])
    }
    
    private func projectDeleteConfirmationActionSheet() -> ActionSheet {
        ActionSheet(title: Text(model.selectedItemModel!.name), message: nil, buttons: [.destructive(Text("Delete")) {
            withAnimation {
                guard let selectedProject = model.selected else {
                    assertionFailure()
                    logger.fault("There is no selected project but deleting project is requested")
                    return
                }
                let projectToSelect = model.prev(to: selectedProject) ?? model.next(to: selectedProject)
                if model.remove(selectedProject) {
                    onRemoveAction?(selectedProject)
                    if let projectToSelect = projectToSelect {
                        model.selected = projectToSelect
                    } else {
                        createProject()
                    }
                } else {
                    alertType = .removeFailed
                }
            }
        }, .cancel()])
    }
    
    private func createProject() {
        if let project = model.create() {
            model.selected = project
            presentationMode.wrappedValue.dismiss()
            onOpenAction?(project)
        } else {
            alertType = .createFailed
        }
        
    }
    
    private func alert(for type: AlertType) -> Alert {
        switch type {
        case .loadFailed:
            return Alert(title: Text("Failed to load projects"), message: Text(Settings.genericUserErrorMessage), dismissButton:  nil)
        case .createFailed:
            return Alert(title: Text("Failed to create a new project"), message: Text(Settings.genericUserErrorMessage), dismissButton:  nil)
        case .duplicateFailed:
            return Alert(title: Text("Failed to duplicate the project"), message: Text(Settings.genericUserErrorMessage), dismissButton:  nil)
        case .removeFailed:
            return Alert(title: Text("Failed to remove project"), message: Text(Settings.genericUserErrorMessage), dismissButton:  nil)
        }
    }
    
    static let gridId = 1
}

struct ProjectView_Previews: PreviewProvider {
    
    static let projectPreviewSample = UIImage(named: "project_preview_sample")!
    
    static var previews: some View {
        ProjectBrowser(model: ProjectBrowserModel(projects: [
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
