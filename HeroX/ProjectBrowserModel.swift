//
//  ProjectBrowserModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/11/20.
//

import Foundation
import os

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
    var logger: Logger?
    
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
    
    func load() -> Bool {
        logger?.notice("Loading projects")
        guard !isLoaded else {return true}
        do {
            setupItemModels(projects: try ProjectDAO.shared.load())
            logger?.notice("Projects loaded")
            return true
        } catch {
            assertionFailure(error.localizedDescription)
            logger?.error("Failed to load projects with error: \(error.localizedDescription, privacy: .public)")
        }
        return false
    }
    
    var isLoaded: Bool {
        itemModels != nil
    }
    
    var isSelected: Bool {
        selected != nil
    }
    
    var isEmpty: Bool {
        itemModels?.count == 0
    }
    
    var first: Project? {
        itemModels?.first?.project
    }
    
    var last: Project? {
        itemModels?.last?.project
    }
    
    func create() -> Project? {
        logger?.notice("Creating a new project")
        guard isLoaded else {
            assertionFailure()
            logger?.fault("Creating a new project when projects are not loaded")
            return nil
        }
        
        do {
            let project = Project()
            try ProjectDAO.shared.save(project)
            itemModels!.append(.init(project: project))
            logger?.notice("Project created: \(project, privacy: .public)")
            return project
        } catch {
            assertionFailure(error.localizedDescription)
            logger?.error("Failed to create a new project with error: \(error.localizedDescription, privacy: .public)")
        }
        return nil
    }
    
    func remove(_ project: Project) -> Bool {
        logger?.notice("Removing project \(project, privacy: .public)")
        guard isLoaded else {
            assertionFailure()
            logger?.fault("Removing a project when projects are not loaded")
            return false
        }
        do {
            try ProjectDAO.shared.remove(project)
            if let index = itemModelIndexFor(project) {
                itemModels!.remove(at: index)
            }
            logger?.notice("Project removed")
            return true
        } catch {
            assertionFailure(error.localizedDescription)
            logger?.error("Failed to remove project \(project, privacy: .public); with error: \(error.localizedDescription, privacy: .public)")
        }
        return false
    }
    
    func duplicate(_ project: Project) -> Project? {
        logger?.notice("Duplicating project \(project, privacy: .public)")
        guard isLoaded else {
            assertionFailure()
            logger?.fault("Duplicating project when projects are not loaded")
            return nil
        }
        do {
            let newProject = try ProjectDAO.shared.duplicate(project)
            let projectViewModel = ProjectItemModel(project: newProject, logger: logger)
            itemModels!.append(projectViewModel)
            logger?.notice("Project duplicated: \(newProject, privacy: .public)")
            return newProject
        } catch {
            assertionFailure(error.localizedDescription)
            logger?.error("Failed to duplicate project \(project, privacy: .public); with error: \(error.localizedDescription, privacy: .public)")
        }
        return nil
    }
    
    func next(to project: Project) -> Project? {
        if let index = itemModelIndexFor(project), index < itemModels!.count - 1 {
            return itemModels![index + 1].project
        }
        return nil
    }
    
    func prev(to project: Project) -> Project? {
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
            let projectViewModel = ProjectItemModel(project: project, logger: logger)
            projectViewModels.append(projectViewModel)
        }
        
        self.itemModels = projectViewModels
        
        if let selectedProject = selected {
            itemModelFor(selectedProject)?.isSelected = true
        }
        
    }
    
}
