//
//  RandomAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.10.22.
//

import SwiftUI

class RandomAnimatorViewModel: AnimatorViewModel {
    
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
                SignalGraphView(connectSamples: false, resetGraph: resetGraph) {
                    model.getAnimatorValue(context: .init())
                }
                .padding()
                .layoutPriority(1)
                Form {
                    LabeledContent("Seed") {
                        HStack {
                            Text(model.seed, format: .number)
                            Button {
                                model.seed = .randomInFullRange()
                                resetGraph.toggle()
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
        let id = SPTAnimator.make(.init(name: "Rand.1", source: SPTAnimatorSourceMakeRandom(1)))
        return ContentView(animatorId: id)
    }
}
