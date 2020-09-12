//
//  ProjectItemModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/11/20.
//

import Combine
import SwiftUI

class ProjectItemModel: Identifiable, ObservableObject {
    
    let project: Project
    private var projectCancellable: AnyCancellable?
    @Published var isSelected: Bool
    
    init(project: Project) {
        self.project = project
        self.isSelected = false
        projectCancellable = project.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }
    }
    
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
            let oldName = project.name
            let trimmedName = newValue.trimmingCharacters(in: .whitespaces)
            project.name = trimmedName.isEmpty ? nil : trimmedName
            
            do {
                try ProjectDAO.shared.save(project)
            } catch {
                project.name = oldName
                assertionFailure(error.localizedDescription)
                // TODO: Show alert
            }
        }
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
            try ProjectDAO.shared.loadPreview(for: project)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
}
