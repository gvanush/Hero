//
//  ProjectBrowser.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/30/20.
//

import SwiftUI

struct ProjectBrowser: View {
    
    @ObservedObject var model: ProjectBrowserModel
    @Environment(\.presentationMode) var presentationMode
    @State private var actionSheetType: ActionSheetType? = nil
    private let onOpenAction: ((Project) -> Void)?
    private let onRemoveAction: ((Project) -> Void)?
    
    enum ActionSheetType: Identifiable {
        
        var id: ActionSheetType { self }
        
        case projectOptions
        case projectDeleteConfirmation
    }
    
    init(model: ProjectBrowserModel, onRemoveAction: ((Project) -> Void)? = nil, onOpenAction: ((Project) -> Void)? = nil) {
        self.model = model
        self.onOpenAction = onOpenAction
        self.onRemoveAction = onRemoveAction
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
                                            presentationMode.wrappedValue.dismiss()
                                            onOpenAction?(selectedProject)
                                        } else {
                                            assertionFailure()
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
                        
                }
            }
        }
        .onAppear {
            model.load()
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
        LazyVGrid(columns: columns, spacing: 30) {
            NewProjectView() {
                withAnimation {
                    createProject()
                }
            }
            ForEach(model.itemModels!.reversed()) { itemModel in
                ProjectItem(model: itemModel) {
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
        ActionSheet(title: Text(model.selectedItemModel!.name), message: nil, buttons: [.default(Text("Duplicate")) {
            withAnimation {
                if let newProject = model.duplicate(model.selected!) {
                    model.selected = newProject
                    scrollViewProxy.scrollTo(ProjectBrowser.gridId, anchor: .top)
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
                    // TODO: show error
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
            // TODO: show error alert
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
