//
//  RandomAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.10.22.
//

import SwiftUI

class RandomAnimatorViewModel: AnimatorViewModel {
    
    var animatorLastValue: Float?
    
    var seed: UInt32 {
        get {
            animator.source.random.seed
        }
        set {
            animator.source.random.seed = newValue
        }
    }
    
    
}

struct RandomAnimatorView: View {
    
    @StateObject var model: RandomAnimatorViewModel
    @State private var resetGraph = false
    
    var body: some View {
        ZStack {
            Color.systemBackground
            VStack(spacing: 0.0) {
                SignalGraphView(resetGraph: $resetGraph) { samplingRate, time in
                    
                    var context = SPTAnimatorEvaluationContext()
                    context.samplingRate = samplingRate
                    context.time = time
                    
                    let lastValue = model.animatorLastValue
                    let value = model.getAnimatorValue(context: context)
                    
                    model.animatorLastValue = value
                    
                    guard let value = value else {
                        return nil
                    }
                    
                    var interpolate = false
                    if let lastValue = lastValue {
                        interpolate = (lastValue == value)
                    }
                    
                    return .init(value: value, interpolate: interpolate)
                    
                }
                .padding()
                .layoutPriority(1)
                Form {
                    LabeledContent("Seed") {
                        HStack {
                            Text(model.seed, format: .number)
                            Button {
                                model.seed = .randomInFullRange()
                                model.resetAnimator()
                                resetGraph = true
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .imageScale(.large)
                            }

                        }
                        
                    }
                }
            }
        }
        .navigationTitle(model.name)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button {
                    model.destroy()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .onAppear {
            model.resetAnimator()
        }
    }
}

struct RandomAnimatorView_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        let animatorId: SPTAnimatorId
        
        var body: some View {
            NavigationStack {
                RandomAnimatorView(model: .init(animatorId: animatorId))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    static var previews: some View {
        let id = SPTAnimator.make(.init(name: "Rand.1", source: .init(randomWithSeed: 1, frequency: 1.0)))
        return ContentView(animatorId: id)
    }
}
