//
//  NoiseAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.10.22.
//

import SwiftUI

enum NoiseAnimatorProperty: Int, DistinctValueSet, Displayable {
    case seed
    case frequency
    case interpolation
}

class NoiseAnimatorComponent: BasicComponent<NoiseAnimatorProperty> {

    @SPTObservedAnimator var animator: SPTAnimator
    let frequencyFormatter = Formatters.frequency
    
    init(animatorId: SPTAnimatorId) {
        _animator = .init(id: animatorId)
        
        super.init(selectedProperty: .seed, parent: nil)
        
        _animator.publisher = self.objectWillChange
    }
    
    override var title: String {
        "Noise"
    }
    
    var seed: UInt32 {
        get {
            animator.source.noise.seed
        }
        set {
            animator.source.noise.seed = newValue
        }
    }
    
    var frequency: Float {
        get {
            animator.source.noise.frequency
        }
        set {
            animator.source.noise.frequency = newValue
        }
    }
    
    var interpolation: SPTEasingType {
        get {
            animator.source.noise.interpolation
        }
        set {
            animator.source.noise.interpolation = newValue
        }
    }
    
}

class NoiseAnimatorComponentViewProvider: ComponentViewProvider<NoiseAnimatorComponent> {
    
    override func viewForRoot(_ root: NoiseAnimatorComponent) -> AnyView? {
        AnyView(NoiseAnimatorComponentView(component: root))
    }
}

struct NoiseAnimatorComponentView: View {
    
    @ObservedObject var component: NoiseAnimatorComponent
    @State private var scale = FloatSelector.Scale._1
    @State private var isSnappingEnabled = true
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .seed:
                RandomSeedSelector(seed: $component.seed)
            case .frequency:
                FloatSelector(value: $component.frequency, valueTransformer: .frequency, scale: $scale, isSnappingEnabled: $isSnappingEnabled, formatter: component.frequencyFormatter)
            case .interpolation:
                EasingSelector(easing: $component.interpolation)
            }
        }
        .tint(.primary)
        .transition(.identity)
    }
    
}

struct NoiseAnimatorOutlineView: View {
    
    @ObservedObject var component: NoiseAnimatorComponent
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
            LabeledContent("Interpolation") {
                HStack {
                    Text(component.interpolation.displayName)
                    EasingTypeSelector(easing: $component.interpolation)
                }
            }
        }
        // NOTE: This is necessary for unknown reason to prevent 'Form' row
        // from being selectable when there is a button inside.
        .buttonStyle(BorderlessButtonStyle())
    }
}

class NoiseAnimatorViewModel: BasicAnimatorViewModel<NoiseAnimatorComponent> {
    
    private var willChangeSubscription: SPTAnySubscription?
    
    init(animatorId: SPTAnimatorId) {
        
        super.init(rootComponent: .init(animatorId: animatorId), animatorId: animatorId)
        
        willChangeSubscription = SPTAnimator.onWillChangeSink(id: animatorId) { [weak self] newValue in
            guard let self = self else { return }
            if newValue.source.noise.seed != self.animator.source.noise.seed || newValue.source.noise.interpolation != self.animator.source.noise.interpolation {
                self.restartFlag = true
            }
        }
    }
    
}

struct NoiseAnimatorView: View {
    
    @StateObject var model: NoiseAnimatorViewModel
    @State private var isEditing = false
    
    static let componentViewProvider = NoiseAnimatorComponentViewProvider()
    
    var body: some View {
        BasicAnimatorView(model: model, componentViewProvider: Self.componentViewProvider, isEditing: $isEditing) {
            NoiseAnimatorOutlineView(component: model.rootComponent) {
                isEditing = true
            }
        }
    }
    
}

struct NoiseAnimatorView_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        let animatorId: SPTAnimatorId
        
        var body: some View {
            NavigationStack {
                NoiseAnimatorView(model: .init(animatorId: animatorId))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    static var previews: some View {
        let id = SPTAnimator.make(.init(name: "Noise.1", source: .init(noiseWithType: .value, seed: 1, frequency: 1.0, interpolation: .smoothStep)))
        SPTAnimator.reset(id: id)
        return ContentView(animatorId: id)
    }
}
