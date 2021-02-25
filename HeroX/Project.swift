//
//  Project.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/3/20.
//

import Foundation
import UIKit
import os

class Project: Identifiable, Codable, ObservableObject, CustomStringConvertible {
    
    let id: UUID
    let creationDate: Date
    var lastModifiedDate: Date { willSet { objectWillChange.send() } }
    var name: String? { willSet { objectWillChange.send() } }
    var version: String { willSet { objectWillChange.send() } }
    
    var description: String {
        let invalidProjectDescription = "<invalid>"
        guard let json = try? json() else {
            return invalidProjectDescription
        }
        return String(data: json, encoding: .utf8) ?? invalidProjectDescription
    }
    
    fileprivate(set) var url: URL? { willSet { objectWillChange.send() } }
    fileprivate(set) var preview = OptionalResource<UIImage>.notLoaded { willSet { objectWillChange.send() } }
    
    convenience init(name: String? = nil) {
        self.init(name: name, url: nil)
    }
    
    fileprivate init(name: String? = nil, url: URL? = nil) {
        id = UUID()
        creationDate = Date()
        lastModifiedDate = creationDate
        self.name = name
        self.version = Project.version
        self.url = url
        self.preview = .notLoaded
    }
    
    fileprivate static func makeFrom(json: Data, url: URL) throws -> Project {
        let project = try JSONDecoder().decode(Project.self, from: json)
        project.url = url
        return project
    }
        
    fileprivate var isPersisted: Bool {
        url != nil
    }
    
    fileprivate func json() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    fileprivate func duplicate() -> Project {
        let project = Project(name: name)
        project.preview = preview
        project.version = version
        return project
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, creationDate, lastModifiedDate, name, version
    }
    
    private static let version = "1.0.0"
    
}

class ProjectDAO {
    
    private var projectsURL: URL!
    private let logger = Logger(category: "projectdao")
    
    private init() {}
    
    func setup() throws {
        projectsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        projectsURL.appendPathComponent(ProjectDAO.directoryName)
        
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: projectsURL.path, isDirectory: &isDir) {
            if isDir.boolValue {
                return
            }
            try FileManager.default.removeItem(at: projectsURL)
        }
        try FileManager.default.createDirectory(at: projectsURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func load() throws -> [Project] {
        
        let urls = try FileManager.default.contentsOfDirectory(at: projectsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        var projects = [Project]()
        for url in urls {
            guard url.hasDirectoryPath else {continue}
            let metadataURL = url.appendingPathComponent(ProjectDAO.metadataFileName)
            if FileManager.default.fileExists(atPath: metadataURL.path) {
                do {
                    let metadata = try Data(contentsOf: metadataURL)
                    projects.append(try Project.makeFrom(json: metadata, url: url))
                } catch {
                    assertionFailure(error.localizedDescription)
                    logger.warning("Failed to load project metadata with error: \(error.localizedDescription)")
                }
            }
        }
        return projects
    }
    
    func save(_ project: Project) throws {
        try checkURL(for: project)
        let url = project.url!.appendingPathComponent(ProjectDAO.metadataFileName)
        try project.json().write(to: url, options: .atomic)
    }
    
    func remove(_ project: Project) throws {
        guard project.isPersisted else {
            return
        }
        try FileManager.default.removeItem(at: project.url!)
        project.url = nil
    }
    
    func loadPreview(for project: Project) throws {
        guard project.isPersisted else {
            return
        }
        
        switch project.preview {
        case .notLoaded:
            let previewURL = project.url!.appendingPathComponent(ProjectDAO.previewFileName)
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
            try save(project)
        }
        
        let previewURL = project.url!.appendingPathComponent(ProjectDAO.previewFileName)
        if let previewData = preview.jpegData(compressionQuality: 1.0) {
            try previewData.write(to: previewURL, options: .atomic)
            project.preview = .some(preview)
        } else {
            throw Error.invalidProjectPreview
        }
    }
    
    func duplicate(_ project: Project) throws -> Project {
        
        let newProject = project.duplicate()
        try save(newProject)
        
        guard project.isPersisted else {
            return newProject
        }
        
        switch newProject.preview {
        case .notLoaded:
            let srcURL = project.url!.appendingPathComponent(ProjectDAO.previewFileName)
            if FileManager.default.fileExists(atPath: srcURL.path) {
                let destURL = newProject.url!.appendingPathComponent(ProjectDAO.previewFileName)
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
    
    private func checkURL(for project: Project) throws {
        if project.isPersisted {
            return
        }
        let url = projectsURL.appendingPathComponent(project.id.uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        project.url = url
    }
    
    static let shared = ProjectDAO()
    
    private static let directoryName = "Projects"
    private static let metadataFileName = "Metadata.json"
    private static let previewFileName = "Preview.jpeg"
    
    enum Error: LocalizedError {
        case invalidProjectPreview
        
        var errorDescription: String? {
            switch self {
            case .invalidProjectPreview:
                return "The image has no data or the underlying 'CGImageRef' contains data in an unsupported bitmap format."
            }
        }
    }
    
}
