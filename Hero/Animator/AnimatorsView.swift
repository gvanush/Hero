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
    
    func makePanAnimator() -> SPTAnimatorId {
        SPTAnimator.make(SPTAnimator(name: "Pan.\(SPTAnimator.getCount())", source: .init(panWithAxis: .horizontal, bottomLeft: .zero, topRight: .one)))
    }
    
    func makeRandomAnimator() -> SPTAnimatorId {
        SPTAnimator.make(.init(name: "Random.\(SPTAnimator.getCount())", source: .init(randomWithSeed: .randomInFullRange(), frequency: 1.0)))
    }
    
    func makeOscillatorAnimator() -> SPTAnimatorId {
        SPTAnimator.make(.init(name: "Oscillator.\(SPTAnimator.getCount())", source: .init(oscillatorWithFrequency: 1.0, interpolation: .smoothStep)))
    }
    
    func makeValueNoise() -> SPTAnimatorId {
        SPTAnimator.make(.init(name: "Value.Noise.\(SPTAnimator.getCount())", source: .init(noiseWithType: .value, seed: .randomInFullRange(), frequency: 1.0, interpolation: .smoothStep)))
    }
    
    func makePerlinNoise() -> SPTAnimatorId {
        SPTAnimator.make(.init(name: "Perlin.Noise.\(SPTAnimator.getCount())", source: .init(noiseWithType: .perlin, seed: .randomInFullRange(), frequency: 1.0, interpolation: .smoothStep)))
    }
    
    func discloseAnimator(id: SPTAnimatorId) {
        disclosedAnimatorIds = [id]
    }
    
    func destroyAnimator(id: SPTAnimatorId) {
        SPTAnimator.destroy(id: id)
    }
    
}

struct AnimatorsView: View {
    
    @ObservedObject var model: AnimatorsViewModel
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
                    case .noise:
                        NoiseAnimatorView(model: .init(animatorId: animatorId))
                    case .oscillator:
                        OscillatorAnimatorView(model: .init(animatorId: animatorId))
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
                        Menu("Noise") {
                            Button("Value") {
                                model.discloseAnimator(id: model.makeValueNoise())
                            }
                            Button("Perlin") {
                                model.discloseAnimator(id: model.makePerlinNoise())
                            }
                        }
                        Button("Oscillator") {
                            model.discloseAnimator(id: model.makeOscillatorAnimator())
                        }
                        Button("Random") {
                            model.discloseAnimator(id: model.makeRandomAnimator())
                        }
                        Button("Pan") {
                            model.discloseAnimator(id: model.makePanAnimator())
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
        AnimatorsView(model: .init())
    }
}
