//
//  EditGeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.01.22.
//

import SwiftUI

struct EditGeneratorView: View {
    
    @StateObject private var treeViewRootModel = Self.createModel()
    @State private var indexPath = IndexPath()
    @State private var selectionIndex: Int?
    @State var isNavigating = false
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                SceneView(model: sceneViewModel, isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation))
                    .ignoresSafeArea()
                PropertyTreeView(rootModel: treeViewRootModel, activeInodeIndexPath: $indexPath, activeInodeSelectionIndex: $selectionIndex)
                    .visible(!isNavigating)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // TODO:
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationBarHidden(isNavigating)
            .navigationTitle("Edit Generator")
        }
    }
    
    static func createModel() -> PropertyTreeNodeViewModel {
        PropertyTreeNodeViewModel(title: "Transformation") {
            let position = PropertyTreeNodeViewModel(title: "Postion") {
                return [PropertyTreeNodeViewModel(title: "X"), PropertyTreeNodeViewModel(title: "Y"), PropertyTreeNodeViewModel(title: "Z")]
            }
            let orienation = PropertyTreeNodeViewModel(title: "Orienation") {
                return [PropertyTreeNodeViewModel(title: "X"), PropertyTreeNodeViewModel(title: "Y"), PropertyTreeNodeViewModel(title: "Z")]
            }
            let scale = PropertyTreeNodeViewModel(title: "Scale") {
                return [PropertyTreeNodeViewModel(title: "X"), PropertyTreeNodeViewModel(title: "Y"), PropertyTreeNodeViewModel(title: "Z")]
            }
            return [position, orienation, scale]
        }
    }
    
}

struct EditGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        EditGeneratorView()
            .environmentObject(SceneViewModel())
    }
}
