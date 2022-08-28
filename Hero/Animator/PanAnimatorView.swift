//
//  PanAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.07.22.
//

import SwiftUI

class PanAnimatorViewModel: ObservableObject {
    
    @SPTObservedAnimator var animator: SPTAnimator
    
    init(animatorId: SPTAnimatorId) {
        _animator = SPTObservedAnimator(animatorId: animatorId)
        _animator.publisher = self.objectWillChange
    }
    
    var name: String {
        animator.name.capitalizingFirstLetter()
    }
    
    var axis: SPTPanAnimatorSourceAxis {
        set {
            animator.source.pan.axis = newValue
        }
        get {
            animator.source.pan.axis
        }
    }
    
    func destroy() {
        SPTAnimatorDestroy(animator.id)
    }
}


struct PanAnimatorView: View {
    
    @ObservedObject var model: PanAnimatorViewModel
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
                    
                } label: {
                    Image(systemName: "play")
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
            PanAnimatorSetBoundsView(model: .init(animatorId: model.animator.id))
        }
        .fullScreenCover(isPresented: $showsViewSignalView) {
            PanAnimatorViewSignalView(animatorId: model.animator.id)
        }
    }
}

struct PanAnimatorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PanAnimatorView(model: PanAnimatorViewModel(animatorId: SPTAnimatorMake(SPTAnimator(name: "Pan 1", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))))
                .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}
