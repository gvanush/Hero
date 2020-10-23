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
    @Published private var isTopBarVisible = true
    @Published private var isObjectToolbarVisible = true
    
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

struct TopBar: View {
    
    @ObservedObject var model = RootViewModel()
    private let logger = Logger(category: "topbar")
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                Button(action: {
                    logger.notice("Open project browser")
                    model.isProjectBrowserPresented.toggle()
                }, label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 25, weight: .regular))
                        .minTappableFrame(alignment: .leading)
                })
                Spacer()
                Button(action: {
                    model.saveImage()
                }, label: {
                    Text("Save image")
                }).disabled(model.project == nil)
            }
            .padding()
            .frame(minWidth: proxy.size.width, idealWidth: proxy.size.width, maxWidth: proxy.size.width, minHeight: height, idealHeight: height, maxHeight: height, alignment: .center)
            .padding(.top, proxy.safeAreaInsets.top)
            .background(BlurView(style: .systemUltraThinMaterial))
            .edgesIgnoringSafeArea(.top)
        }
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
    
    let height: CGFloat = 50.0
}

struct RootView: View {
    
    var body: some View {
        ZStack {
            HeroSceneView()
                .ignoresSafeArea()
            
            VStack {
                TopBar()
                ObjectToolbar()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
