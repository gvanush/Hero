//
//  ProjectBrowserModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/11/20.
//

import Foundation

class ProjectBrowserModel: ObservableObject {
    
    @Published private (set) var itemModels: [ProjectItemModel]?
    @Published var selected: Project? {
        willSet {
            if let selectedProject = selected {
                itemModelFor(selectedProject)?.isSelected = false
            }
            if let newSelectedProject = newValue {
                itemModelFor(newSelectedProject)?.isSelected = true
            }
        }
    }
    
    var selectedItemModel: ProjectItemModel? {
        if let selectedProject = selected {
            return itemModelFor(selectedProject)
        }
        return nil
    }
    
    init(selectedProject: Project? = nil, projects: [Project]? = nil) {
        self.selected = selectedProject
        if let projects = projects {
            setupItemModels(projects: projects)
        }
    }
    
    func load() {
        guard !isLoaded else {return}
        do {
            setupItemModels(projects: try ProjectDAO.shared.load())
        } catch {
            assertionFailure(error.localizedDescription)
            // TODO: Show alert with 'Failed to load projects, try again later or contact support'
        }
    }
    
    var isLoaded: Bool {
        itemModels != nil
    }
    
    var isSelected: Bool {
        selected != nil
    }
    
    func create() -> Project? {
        guard isLoaded else {
            assertionFailure()
            return nil
        }
        
        do {
            let project = Project()
            try ProjectDAO.shared.save(project)
            itemModels!.append(.init(project: project))
            return project
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return nil
    }
    
    func remove(_ project: Project) -> Bool {
        guard isLoaded else {
            assertionFailure()
            return false
        }
        do {
            try ProjectDAO.shared.remove(project)
            if let index = itemModelIndexFor(project) {
                itemModels!.remove(at: index)
            }
            return true
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return false
    }
    
    func duplicate(_ project: Project) -> Project? {
        guard isLoaded else {
            assertionFailure()
            return nil
        }
        do {
            let project = try ProjectDAO.shared.duplicate(project)
            let projectViewModel = ProjectItemModel(project: project)
            itemModels!.append(projectViewModel)
            return project
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return nil
    }
    
    func next(to project: Project) -> Project? {
        guard isLoaded else {
            assertionFailure()
            return nil
        }
        if let index = itemModelIndexFor(project), index < itemModels!.count - 1 {
            return itemModels![index + 1].project
        }
        return nil
    }
    
    func prev(to project: Project) -> Project? {
        guard isLoaded else {
            assertionFailure()
            return nil
        }
        if let index = itemModelIndexFor(project), index > 0 {
            return itemModels![index - 1].project
        }
        return nil
    }
    
    private func itemModelFor(_ project: Project) -> ProjectItemModel? {
        itemModels?.first {$0.id == project.id}
    }
    
    private func itemModelIndexFor(_ project: Project) -> Int? {
        itemModels?.firstIndex(where: {$0.id == project.id})
    }
    
    private func setupItemModels(projects: [Project]) {
        var projects = projects
        
        if let selectedProject = selected {
            if let index = projects.firstIndex(where: {$0.id == selectedProject.id}) {
                projects[index] = selectedProject
            }
        }
        projects.sort { $0.lastModifiedDate < $1.lastModifiedDate }
        
        var projectViewModels = [ProjectItemModel]()
        projectViewModels.reserveCapacity(projects.count)
        for project in projects {
            let projectViewModel = ProjectItemModel(project: project)
            projectViewModels.append(projectViewModel)
        }
        
        self.itemModels = projectViewModels
        
        if let selectedProject = selected {
            itemModelFor(selectedProject)?.isSelected = true
        }
        
    }
    
}
