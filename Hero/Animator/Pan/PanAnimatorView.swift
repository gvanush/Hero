//
//  PanAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.07.22.
//

import SwiftUI


class PanAnimatorViewModel: AnimatorViewModel {
    
    var axis: SPTPanAnimatorSourceAxis {
        set {
            animator.source.pan.axis = newValue
        }
        get {
            animator.source.pan.axis
        }
    }

}


struct PanAnimatorView: View {
    
    @StateObject var model: PanAnimatorViewModel
    @State private var showsSetBoundsView = false
    @State private var showsViewSignalView = false
    
    var body: some View {
        Form {
            Section("Pan") {
                HStack {
                    Text("Axis")
                    Spacer()
                    Text(model.axis.displayName)
                        .foregroundColor(.secondaryLabel)
                    Menu {
                        ForEach(SPTPanAnimatorSourceAxis.allCases) { axis in
                            Button(axis.displayName) {
                                model.axis = axis
                            }
                        }
                    } label: {
                        Image(systemName: "pencil.circle")
                            .imageScale(.large)
                    }
                }
                HStack {
                    Text("Bounds")
                    Spacer()
                    Button {
                        showsSetBoundsView = true
                    } label: {
                        Image(systemName: "pencil.circle")
                            .imageScale(.large)
                    }
                }
            }
        }
        .navigationTitle(model.name)
        // NOTE: This is necessary for an unknown reason to prevent 'Form' row
        // from being selectable when there is a button inside.
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showsViewSignalView = true
                } label: {
                    Image(systemName: "waveform.path.ecg.rectangle")
                }
                Spacer()
                Button {
                    model.destroy()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $showsSetBoundsView) {
            PanAnimatorSetBoundsView(model: .init(animatorId: model.animatorId))
        }
        .fullScreenCover(isPresented: $showsViewSignalView) {
            PanAnimatorViewGraphView(model: .init(animatorId: model.animatorId))
        }
    }
}

struct PanAnimatorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PanAnimatorView(model: PanAnimatorViewModel(animatorId: SPTAnimator.make(SPTAnimator(name: "Pan.1", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))))
                .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}
