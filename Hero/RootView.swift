//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/4/20.
//

import SwiftUI

struct RootView: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            Color(.lightGray)
                .navigationBarItems(leading: Button(action: {
                    viewModel.isProjectBrowserViewPresented.toggle()
                }, label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 25, weight: .regular))
                        .minTappableFrame(alignment: .leading)
                }), trailing: Button(action: {
                    viewModel.saveImage()
                }, label: {
                    Text("Save image")
                }).disabled(viewModel.project == nil))
        }
        .fullScreenCover(isPresented: $viewModel.isProjectBrowserViewPresented, content: {
            ProjectBrowser(viewModel: ProjectBrowser.ViewModel(openedProject: viewModel.project), onProjectCreateAction: { project in
                viewModel.project = project
                viewModel.isProjectBrowserViewPresented = false
            }, onProjectRemoveAction: { project in
                if viewModel.project === project {
                    viewModel.project = nil
                }
            }) { project in
                viewModel.project = project
            }
        })
    }
    
    class ViewModel: ObservableObject {
        @Published var isProjectBrowserViewPresented = false
        @Published var project: Project?
        
        func saveImage() {
            guard let project = project else {
                return
            }
            let image = UIImage(named: "project_preview_sample")!
            do {
                try ProjectStore.shared.savePreview(image, for: project)
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
