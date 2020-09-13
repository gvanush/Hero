//
//  ProjectItemModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/11/20.
//

import Combine
import SwiftUI
import os

class ProjectItemModel: Identifiable, ObservableObject {
    
    let project: Project
    @Published var isSelected: Bool
    
    private let logger: Logger?
    private var projectCancellable: AnyCancellable?
    
    init(project: Project, logger: Logger? = nil) {
        self.project = project
        self.isSelected = false
        self.logger = logger
        projectCancellable = project.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }
    }
    
    var id: UUID {
        project.id
    }
    
    var name: String {
        if let name = project.name {
            return name
        }
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return "Project \(df.string(from: project.creationDate))"
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
            logger?.notice("Loading preview for project: \(self.project, privacy: .public)")
            try ProjectDAO.shared.loadPreview(for: project)
        } catch {
            assertionFailure(error.localizedDescription)
            logger?.error("Failed to load preview for porject: \(self.project, privacy: .public); with error: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func rename(to newName: String) -> Bool {
        logger?.notice("Renaming project: \(self.project, privacy: .public); to: \(newName, privacy: .public)")
        
        let oldName = project.name
        let trimmedName = newName.trimmingCharacters(in: .whitespaces)
        project.name = trimmedName.isEmpty ? nil : trimmedName
        
        do {
            try ProjectDAO.shared.save(project)
            return true
        } catch {
            project.name = oldName
            assertionFailure(error.localizedDescription)
            logger?.error("Failed to rename porject: \(self.project, privacy: .public); with error: \(error.localizedDescription, privacy: .public)")
        }
        return false
    }
    
}
