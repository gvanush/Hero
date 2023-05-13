//
//  RandomAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.10.22.
//

import SwiftUI

enum RandomAnimatorProperty: Int, DistinctValueSet, Displayable {
    case seed
    case frequency
}

class RandomAnimatorComponent: BasicComponent<RandomAnimatorProperty> {

    @SPTObservedAnimator var animator: SPTAnimator
    let frequencyFormatter = FrequencyFormatter()
    
    init(animatorId: SPTAnimatorId) {
        _animator = .init(id: animatorId)
        
        super.init(selectedProperty: .seed, parent: nil)
        
        _animator.publisher = self.objectWillChange
    }
    
    override var title: String {
        "Random"
    }
    
    var seed: UInt32 {
        get {
            animator.source.random.seed
        }
        set {
            animator.source.random.seed = newValue
        }
    }
    
    var frequency: Float {
        get {
            animator.source.random.frequency
        }
        set {
            animator.source.random.frequency = newValue
        }
    }
    
}

class RandomAnimatorComponentViewProvider: ComponentViewProvider<RandomAnimatorComponent> {
    
    override func viewForRoot(_ root: RandomAnimatorComponent) -> AnyView? {
        AnyView(RandomAnimatorComponentView(component: root))
    }
}

struct RandomAnimatorComponentView: View {
    
    @ObservedObject var component: RandomAnimatorComponent
    @State private var scale = FloatSelector.Scale._1
    @State private var isSnappingEnabled = true
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .seed:
                RandomSeedSelector(seed: $component.seed)
            case .frequency:
                FloatSelector(value: $component.frequency, valueTransformer: .frequency, scale: $scale, isSnappingEnabled: $isSnappingEnabled, formatter: component.frequencyFormatter)
            }
        }
        .tint(.primary)
        .transition(.identity)
    }
    
}

struct RandomAnimatorOutlineView: View {
    
    @ObservedObject var component: RandomAnimatorComponent
    var onEnterEditMode: () -> Void
    
    var body: some View {
        Form {
            SceneEditableParam(title: "Seed", valueText: Text(component.seed, format: .number)) {
                withAnimation {
                    component.selectedProperty = .seed
                    onEnterEditMode()
                }
            }
            SceneEditableParam(title: "Frequency", valueText: Text(NSNumber(value: component.frequency), formatter: component.frequencyFormatter)) {
                withAnimation {
                    component.selectedProperty = .frequency
                    onEnterEditMode()
                }
            }
        }
    }
    
}

class RandomAnimatorViewModel: BasicAnimatorViewModel<RandomAnimatorComponent> {
    
    private var animatorLastValue: Float?
    private var willChangeSubscription: SPTAnySubscription?
    
    init(animatorId: SPTAnimatorId) {
        
        super.init(rootComponent: .init(animatorId: animatorId), animatorId: animatorId)
        
        willChangeSubscription = SPTAnimator.onWillChangeSink(id: animatorId) { [weak self] newValue in
            guard let self = self else { return }
            if newValue.source.noise.seed != self.animator.source.noise.seed {
                self.restartFlag = true
            }
        }
    }
    
    override func getValueItem(samplingRate: Int, time: TimeInterval) -> SignalValueItem? {
        
        var context = SPTAnimatorEvaluationContext()
        context.samplingRate = samplingRate
        context.time = time

        let lastValue = animatorLastValue
        let value = getAnimatorValue(context: context)
        animatorLastValue = value

        guard let value = value else {
            return nil
        }

        var interpolate = false
        if let lastValue {
            interpolate = (lastValue == value)
        }

        return .init(value: value, interpolate: interpolate)
    }
    
}

struct RandomAnimatorView: View {
    
    @StateObject var model: RandomAnimatorViewModel
    @State private var isEditing = false
    
    static let componentViewProvider = RandomAnimatorComponentViewProvider()
    
    var body: some View {
        BasicAnimatorView(model: model, componentViewProvider: Self.componentViewProvider, isEditing: $isEditing) {
            RandomAnimatorOutlineView(component: model.rootComponent) {
                isEditing = true
            }
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
