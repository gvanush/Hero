//
//  AnimatorsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.07.22.
//

import SwiftUI

class AnimatorsViewModel: ObservableObject {
    
    @Published var disclosedAnimatorIds = [SPTAnimatorId]()
    
    init() {
        
        SPTAnimatorAddCountWillChangeListener(Unmanaged.passUnretained(self).toOpaque(), { listener, newValue  in
            let me = Unmanaged<AnimatorsViewModel>.fromOpaque(listener).takeUnretainedValue()
            me.disclosedAnimatorIds.removeAll()
            me.objectWillChange.send()
        })
    }
    
    deinit {
        SPTAnimatorRemoveCountWillChangeListener(Unmanaged.passUnretained(self).toOpaque())
    }
 
    func makeAnimator(_ animator: SPTAnimator) -> SPTAnimatorId {
        SPTAnimatorMake(animator)
    }
    
    func discloseAnimator(id: SPTAnimatorId) {
        disclosedAnimatorIds = [id]
    }
    
    func destroyAnimator(id: SPTAnimatorId) {
        SPTAnimatorDestroy(id)
    }
}

struct AnimatorsView: View {
    
    @StateObject var model = AnimatorsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationStack(path: $model.disclosedAnimatorIds) {
            List(SPTAnimatorGetAll()) { animator in
                NavigationLink(animator.name.capitalizingFirstLetter(), value: animator.id)
            }
            .navigationDestination(for: SPTAnimatorId.self, destination: { animatorId in
                PanAnimatorView(model: PanAnimatorViewModel(animatorId: animatorId))
            })
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
                            let animatorId = model.makeAnimator(SPTAnimator(name: "Pan.\(SPTAnimatorGetAll().count)", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))
                            model.discloseAnimator(id: animatorId)
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
