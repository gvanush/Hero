//
//  EditGeneratorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.01.22.
//

import SwiftUI

struct EditGeneratorView: View {
    
    @State var positionSelection: Axis? = .x
    @State var scaleSelection: Axis? = .x
    @State var orientationSelection: Axis? = .x
    @State var isNavigating = false
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                SceneView(model: sceneViewModel, isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation))
                    .ignoresSafeArea()
                PropertyTreeNavigationView {
                    PropertyNode("Transformation") {
                        PropertyNode("Position", selected: $positionSelection)
                        PropertyNode("Scale", selected: $scaleSelection)
                        PropertyNode("Orientation", selected: $orientationSelection)
                    }
                }
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
    
}

struct EditGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        EditGeneratorView()
            .environmentObject(SceneViewModel())
    }
}
