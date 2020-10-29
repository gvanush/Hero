//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/4/20.
//

import SwiftUI
import os

class RootViewModel: ObservableObject {
    @Published var isProjectBrowserPresented = false {
        willSet {
            sceneViewModel.isPaused = newValue
        }
    }
    @Published var isTopBarVisible = true
    @Published var isStatusBarVisible = true
    let sceneViewModel = SceneViewModel()
    
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
    
    func setTopBar(visible: Bool, animated: Bool = false) {
        if animated {
            withAnimation {
                isTopBarVisible = visible
            }
        } else {
            isTopBarVisible = visible
        }
    }
    
    func setFullScreenMode(enabled: Bool, animated: Bool = false) {
        if animated {
            withAnimation {
                isTopBarVisible = !enabled
                isStatusBarVisible = !enabled
            }
        } else {
            isTopBarVisible = !enabled
            isStatusBarVisible = !enabled
        }
    }
}

struct RootView: View {
    
    @ObservedObject var model = RootViewModel()
    
    var body: some View {
        ZStack {
            SceneView(model: model.sceneViewModel)
            TopBar()
                .opacity(model.isTopBarVisible ? 1.0 : 0.0)
        }
            .statusBar(hidden: !model.isStatusBarVisible)
            .environmentObject(model)
    }
}

struct TopBar: View {
    
    @EnvironmentObject private var rootViewModel: RootViewModel
    
    private let logger = Logger(category: "topbar")
    
    var body: some View {
        GeometryReader { proxy in
            HStack {
                Button(action: {
                    logger.notice("Open project browser")
                    rootViewModel.isProjectBrowserPresented.toggle()
                }, label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 25, weight: .regular))
                        .minTappableFrame(alignment: .leading)
                })
                Spacer()
                Button(action: {
                    rootViewModel.saveImage()
                }, label: {
                    Text("Save image")
                }).disabled(rootViewModel.project == nil)
            }
            .padding()
            .frame(minWidth: proxy.size.width, idealWidth: proxy.size.width, maxWidth: proxy.size.width, minHeight: height, idealHeight: height, maxHeight: height, alignment: .center)
            .padding(.top, proxy.safeAreaInsets.top)
            .background(BlurView(style: .systemUltraThinMaterial))
            .edgesIgnoringSafeArea(.top)
        }
        .fullScreenCover(isPresented: $rootViewModel.isProjectBrowserPresented, content: {
            ProjectBrowser(model: ProjectBrowserModel(selectedProject: rootViewModel.project), onRemoveAction: { project in
                if rootViewModel.project === project {
                    rootViewModel.project = nil
                }
            }) { project in
                rootViewModel.project = project
            }
        })
    }
    
    let height: CGFloat = 50.0
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
