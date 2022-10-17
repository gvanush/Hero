//
//  AnimatorsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.07.22.
//

import SwiftUI

class AnimatorsViewModel: ObservableObject {
    
    @Published var disclosedAnimatorIds = [SPTAnimatorId]()
    var countWillChangeSubscription: SPTAnySubscription?
    
    init() {
        countWillChangeSubscription = SPTAnimator.onCountWillChangeSink { [weak self] _ in
            self?.disclosedAnimatorIds.removeAll()
            self?.objectWillChange.send()
        }
    }
    
 
    func makeAnimator(_ animator: SPTAnimator) -> SPTAnimatorId {
        SPTAnimator.make(animator)
    }
    
    func discloseAnimator(id: SPTAnimatorId) {
        disclosedAnimatorIds = [id]
    }
    
    func destroyAnimator(id: SPTAnimatorId) {
        SPTAnimator.destroy(id: id)
    }
    
}

struct AnimatorsView: View {
    
    @StateObject var model = AnimatorsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationStack(path: $model.disclosedAnimatorIds) {
            List(SPTAnimator.getAllIds()) { animatorId in
                NavigationLink(SPTAnimator.get(id: animatorId).name.capitalizingFirstLetter(), value: animatorId)
            }
            .navigationDestination(for: SPTAnimatorId.self, destination: { animatorId in
                // NOTE: For some reason 'navigationDestination' is called
                // after removing the last element in the list at which point
                // all animators are daed hence checking to avoid crash
                if SPTAnimator.exists(id: animatorId) {
                    switch SPTAnimator.get(id: animatorId).source.type {
                    case .pan:
                        PanAnimatorView(model: .init(animatorId: animatorId))
                    case .random:
                        RandomAnimatorView(model: .init(animatorId: animatorId))
                    @unknown default:
                        fatalError()
                    }
                }
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
                        Button("Random") {
                            let animatorId = model.makeAnimator(SPTAnimator(name: "Random.\(SPTAnimator.getCount())", source: SPTAnimatorSourceMakeRandom(.randomInFullRange())))
                            model.discloseAnimator(id: animatorId)
                        }
                        Button("Pan") {
                            let animatorId = model.makeAnimator(SPTAnimator(name: "Pan.\(SPTAnimator.getCount())", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))
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
