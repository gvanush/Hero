//
//  Project.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/3/20.
//

import Foundation
import UIKit

class Project: NSCopying {
    
    private(set) var metadata: Metadata
    @Published fileprivate(set) var preview: OptionalResource<UIImage>
    fileprivate var url: URL?
    
    fileprivate init(metadata: Metadata, url: URL) {
        self.metadata = metadata
        self.url = url
        self.preview = .notLoaded
    }
    
    init(metadata: Metadata) {
        self.metadata = metadata
        self.preview = .notLoaded
    }
        
    fileprivate var isPersisted: Bool {
        url != nil
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let project = Project(metadata: metadata.copy() as! Metadata)
        project.preview = preview
        return project
    }
    
    private static let version = "1.0.0"
    
    class Metadata: Identifiable, Codable, NSCopying {
        
        let id: UUID
        let creationDate: Date
        var lastModifiedDate: Date
        var name: String?
        var version: String
        
        init(name: String? = nil) {
            id = UUID()
            creationDate = Date()
            lastModifiedDate = creationDate
            self.name = name
            self.version = Project.version
        }
        
        func json() throws -> Data {
            try JSONEncoder().encode(self)
        }
        
        static func makeFromJSON(_ json: Data) throws -> Metadata {
            try JSONDecoder().decode(Metadata.self, from: json)
        }
        
        func copy(with zone: NSZone? = nil) -> Any {
            let metadata = Metadata(name: name)
            metadata.version = version
            return metadata
        }
        
    }
    
}

class ProjectStore {
    
    private var projectsURL: URL!
    
    private init() {}
    
    func setup() throws {
        projectsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        projectsURL.appendPathComponent(ProjectStore.directoryName)
        
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: projectsURL.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return
            }
            try FileManager.default.removeItem(at: projectsURL)
        }
        try FileManager.default.createDirectory(at: projectsURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func loadProjects() throws -> [Project] {
        
        let urls = try FileManager.default.contentsOfDirectory(at: projectsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        var projects = [Project]()
        for url in urls {
            guard url.hasDirectoryPath else {continue}
            let metadataURL = url.appendingPathComponent(ProjectStore.metadataFileName)
            if FileManager.default.fileExists(atPath: metadataURL.path) {
                do {
                    let metadataData = try Data(contentsOf: metadataURL)
                    let metadata = try Project.Metadata.makeFromJSON(metadataData)
                    projects.append(Project(metadata: metadata, url: url))
                } catch {
                    // TODO: Log warning
                    print("Skipping potential project \(error.localizedDescription)")
                }
            }
        }
        return projects
    }
    
    func saveProject(_ project: Project) throws {
        try checkProjectURL(project)
        let url = project.url!.appendingPathComponent(ProjectStore.metadataFileName)
        try project.metadata.json().write(to: url, options: .atomic)
    }
    
    func removeProject(_ project: Project) throws {
        guard project.isPersisted else {
            return
        }
        try FileManager.default.removeItem(at: project.url!)
        project.url = nil
    }
    
    func loadProjectPreview(_ project: Project) throws {
        guard project.isPersisted else {
            return
        }
        
        switch project.preview {
        case .notLoaded:
            let previewURL = project.url!.appendingPathComponent(ProjectStore.previewFileName)
            if FileManager.default.fileExists(atPath: previewURL.path) {
                let previewData = try Data(contentsOf: previewURL)
                if let image = UIImage(data: previewData) {
                    project.preview = .some(image)
                } else {
                    project.preview = .none
                }
            } else {
                project.preview = .none
            }
        case .none, .some(_):
            return
        }
    }
    
    func savePreview(_ preview: UIImage, for project: Project) throws {
        if !project.isPersisted {
            try saveProject(project)
        }
        
        let previewURL = project.url!.appendingPathComponent(ProjectStore.previewFileName)
        if let previewData = preview.jpegData(compressionQuality: 1.0) {
            try previewData.write(to: previewURL, options: .atomic)
            project.preview = .some(preview)
        } else {
            throw Error.invalidProjectPreview
        }
    }
    
    func duplicateProject(_ project: Project) throws -> Project {
        guard project.isPersisted else {
            assertionFailure(Error.invalidProjectToDuplicate.localizedDescription)
            throw Error.invalidProjectToDuplicate
        }
        
        let newProject = project.copy() as! Project
        try saveProject(newProject)
        
        switch newProject.preview {
        case .notLoaded:
            let srcURL = project.url!.appendingPathComponent(ProjectStore.previewFileName)
            if FileManager.default.fileExists(atPath: srcURL.path) {
                let destURL = newProject.url!.appendingPathComponent(ProjectStore.previewFileName)
                try FileManager.default.copyItem(at: srcURL, to: destURL)
            }
        case .none:
            break
        case .some(let preview):
            try savePreview(preview, for: newProject)
            break
        }
        
        return newProject
    }
    
    private func checkProjectURL(_ project: Project) throws {
        if project.isPersisted {
            return
        }
        let url = projectsURL.appendingPathComponent(project.metadata.id.uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        project.url = url
    }
    
    static let shared = ProjectStore()
    
    private static let directoryName = "Projects"
    private static let metadataFileName = "Metadata.json"
    private static let previewFileName = "Preview.jpeg"
    
    enum Error: LocalizedError {
        case invalidProjectPreview
        case invalidProjectToDuplicate
        
        var errorDescription: String? {
            switch self {
            case .invalidProjectPreview:
                return "The image has no data or the underlying 'CGImageRef' contains data in an unsupported bitmap format."
            case .invalidProjectToDuplicate:
                return "Source project must be saved before being duplicated."
            }
        }
    }
    
}
