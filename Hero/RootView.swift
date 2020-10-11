//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/4/20.
//

import SwiftUI
import os

class RootViewModel: ObservableObject {
    @Published var isProjectBrowserPresented = false
    var project: Project?
    
    func saveImage() {
        guard let project = project else {
            return
        }
        let image = UIImage(named: "project_preview_sample")!
        do {
            try ProjectDAO.shared.savePreview(image, for: project)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

struct RootView: View {
    
    @ObservedObject var model = RootViewModel()
    private let logger = Logger(category: "rootview")
    
    var body: some View {
        NavigationView {
            HeroSceneView()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    logger.notice("Open project browser")
                    model.isProjectBrowserPresented.toggle()
                }, label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 25, weight: .regular))
                        .minTappableFrame(alignment: .leading)
                }), trailing: Button(action: {
                    model.saveImage()
                }, label: {
                    Text("Save image")
                }).disabled(model.project == nil))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $model.isProjectBrowserPresented, content: {
            ProjectBrowser(model: ProjectBrowserModel(selectedProject: model.project), onRemoveAction: { project in
                if model.project === project {
                    model.project = nil
                }
            }) { project in
                model.project = project
            }
        })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
