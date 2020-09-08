//
//  RootView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/4/20.
//

import SwiftUI

class RootViewModel: ObservableObject {
    @Published var isProjectBrowserViewPresented = false
}

struct RootView: View {
    
    @ObservedObject var viewModel = RootViewModel()
    
    var body: some View {
        NavigationView {
            Color(.lightGray)
                .navigationBarItems(leading: Button(action: {
                    viewModel.isProjectBrowserViewPresented.toggle()
                }, label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 25, weight: .regular))
                        .minTappableFrame(alignment: .leading)
                }))
        }
        .fullScreenCover(isPresented: $viewModel.isProjectBrowserViewPresented, content: {
            ProjectBrowser(viewModel: ProjectBrowser.ViewModel(openedProject: Project.active), onProjectCreateAction: { project in
                Project.active = project
                viewModel.isProjectBrowserViewPresented = false
            }, onProjectRemoveAction: { project in
                if Project.active?.metadata.id == project.metadata.id {
                    Project.active = nil
                }
            }) { project in
                Project.active = project
            }
        })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
