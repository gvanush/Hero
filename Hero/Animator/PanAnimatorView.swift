//
//  PanAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.07.22.
//

import SwiftUI

class PanAnimatorViewModel: ObservableObject {
    
    @SPTObservedAniamtor var animator: SPTAnimator
    
    init(animatorId: SPTAnimatorId) {
        _animator = SPTObservedAniamtor(animatorId: animatorId)
        _animator.publisher = self.objectWillChange
    }
    
    var name: String {
        animator.name.capitalizingFirstLetter()
    }
    
    func destroy() {
        SPTAnimatorDestroy(animator.id)
    }
}

struct SignalView: View {
    
    let title: String
    let onView: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button {
                onView()
            } label: {
                Image(systemName: "waveform.path.ecg.rectangle")
                    .imageScale(.large)
            }
        }
    }
    
}

struct PanAnimatorView: View {
    
    @ObservedObject var model: PanAnimatorViewModel
    @State private var showsSetBoundsView = false
    @State private var shownSignal: PanAnimatorSignal?
    
    var body: some View {
        Form {
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
            Section("Signals") {
                SignalView(title: PanAnimatorSignal.horizontal.displayName) {
                    shownSignal = .horizontal
                }
                SignalView(title: PanAnimatorSignal.vertical.displayName) {
                    shownSignal = .vertical
                }
            }
        }
        .navigationTitle(model.name)
        // NOTE: This is necessary for an unknown reason to prevent 'Form' row
        // from being selectable when there is a button inside.
        .buttonStyle(BorderlessButtonStyle())
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    
                } label: {
                    Image(systemName: "play")
                }

            }
            ToolbarItem(placement: .bottomBar) {
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
        .fullScreenCover(item: $shownSignal) { signal in
            PanAnimatorViewSignalView(animatorId: model.animator.id, signal: signal)
        }
    }
}

struct PanAnimatorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PanAnimatorView(model: PanAnimatorViewModel(animatorId: SPTAnimatorMake(SPTAnimator(name: "Pan 1"))))
                .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}
