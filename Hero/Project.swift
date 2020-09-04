//
//  Project.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/3/20.
//

import Foundation
import UIKit

class ProjectX {
    
    private static let version = "1.0.0"
    
    struct Metadata: Identifiable, Codable {
        let id: UUID
        let creationDate: Date
        var lastModifiedDate: Date
        var name: String?
        var version: String
        
        init?(json: Data) {
            do {
                let decoder = JSONDecoder()
                self = try decoder.decode(Metadata.self, from: json)
            } catch {
                assertionFailure(error.localizedDescription)
                return nil
            }
        }
        
        init(name: String?) {
            id = UUID()
            creationDate = Date()
            lastModifiedDate = creationDate
            self.name = name
            self.version = ProjectX.version
        }
        
        func json() throws -> Data {
            try JSONEncoder().encode(self)
        }
        
    }
    
    private(set) var metadata: Metadata
    fileprivate var url: URL?
    
    fileprivate init(metadata: Metadata, url: URL) {
        self.metadata = metadata
        self.url = url
    }
    
    init(metadata: Metadata) {
        self.metadata = metadata
    }
        
    fileprivate var isPersisted: Bool {
        url != nil
    }
}

class ProjectStore {
    
    private var projectsURL: URL!
    private(set) var projects: [ProjectX]?
    
    private init() {}
    
    func setup() throws {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: projectsURL.absoluteString, isDirectory: &isDir) {
            if isDir.boolValue {
                return
            }
            try FileManager.default.removeItem(at: projectsURL)
        }
        try FileManager.default.createDirectory(at: projectsURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func loadProjects() throws {
        
        guard projects == nil else {return}
        
        let urls = try FileManager.default.contentsOfDirectory(at: projectsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        projects = [ProjectX]()
        for url in urls {
            guard url.hasDirectoryPath else {continue}
            let metadataURL = url.appendingPathComponent(ProjectStore.metadataFileName)
            if FileManager.default.fileExists(atPath: metadataURL.absoluteString, isDirectory: nil) {
                do {
                    let metadataData = try Data(contentsOf: metadataURL)
                    let metadata = try JSONDecoder().decode(ProjectX.Metadata.self, from: metadataData)
                    projects?.append(ProjectX(metadata: metadata, url: url))
                } catch {
                    // TODO: Log warning
                    print("Skipping potential project \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    func unloadProjects() {
        projects = nil
    }
    
    func saveProject(_ project: ProjectX) throws {
        let url = try checkProjectURL(project)
        try project.metadata.json().write(to: url, options: .atomic)
        if var projects = self.projects, !project.isPersisted {
            projects.append(project)
        }
        project.url = url
    }
    
    func removeProject(_ project: ProjectX) throws {
        guard project.isPersisted else {
            return
        }
        
        try FileManager.default.removeItem(at: project.url!)
        
        if var projects = self.projects {
            if let index = projects.firstIndex(where: {$0.metadata.id == project.metadata.id}) {
                projects.remove(at: index)
            }
        }
        project.url = nil
    }
    
    private func checkProjectURL(_ project: ProjectX) throws -> URL {
        if project.isPersisted {
            return project.url!
        }
        let url = projectsURL.appendingPathComponent(project.metadata.id.uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
    
    static let shared = ProjectStore()
    
    private static let directoryName = "Projects"
    private static let metadataFileName = "Metadata.json"
    
}
