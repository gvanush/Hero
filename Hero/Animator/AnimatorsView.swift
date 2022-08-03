//
//  AnimatorsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.07.22.
//

import SwiftUI

class AnimatorsViewModel: ObservableObject {
    
    @Published var selection: SPTAnimatorId?
    
    init() {
        SPTAnimatorAddCountWillChangeListener(Unmanaged.passUnretained(self).toOpaque(), { listener, newValue  in
            
            let me = Unmanaged<AnimatorsViewModel>.fromOpaque(listener).takeUnretainedValue()
            
            if !SPTAnimatorGetAll().contains(where: { $0.id == me.selection }) {
                me.selection = nil
            }
            
            me.objectWillChange.send()
        })
    }
    
    deinit {
        SPTAnimatorRemoveCountWillChangeListener(Unmanaged.passUnretained(self).toOpaque())
    }
 
    func makeAnimator(_ animator: SPTAnimator) -> SPTAnimatorId {
        SPTAnimatorMake(animator)
    }
    
    func destroyAnimator(id: SPTAnimatorId) {
        SPTAnimatorDestroy(id)
    }
}

struct AnimatorsView: View {
    
    @State var selection: SPTAnimatorId?
    @StateObject var model = AnimatorsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            List(SPTAnimatorGetAll()) { animator in
                NavigationLink(animator.name.capitalizingFirstLetter(), tag: animator.id, selection: $selection, destination: {
                    PanAnimatorView(model: PanAnimatorViewModel(animatorId: animator.id))
                })
            }
            .navigationTitle("Animators")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Menu {
                        Button("Face") {
                            
                        }
                        Button("Pan") {
                            selection = model.makeAnimator(SPTAnimator(name: "Pan \(SPTAnimatorGetAll().count)", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))
                        }
                    } label: {
                        Text("New From Source")
                    }
                }
            }
        }
    }
}

struct AnimatorsView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatorsView()
    }
}
