//
//  OscillatorAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.12.22.
//

import SwiftUI

enum OscillatorAnimatorProperty: Int, DistinctValueSet, Displayable {
    case frequency
    case interpolation
}

class OscillatorAnimatorComponent: BasicComponent<OscillatorAnimatorProperty> {

    @SPTObservedAnimator var animator: SPTAnimator
    let frequencyFormatter = Formatters.frequency
    
    init(animatorId: SPTAnimatorId) {
        _animator = .init(id: animatorId)
        
        super.init(selectedProperty: .frequency, parent: nil)
        
        _animator.publisher = self.objectWillChange
    }
    
    override var title: String {
        "Oscillator"
    }
    
    var frequency: Float {
        get {
            animator.source.oscillator.frequency
        }
        set {
            animator.source.oscillator.frequency = newValue
        }
    }
    
    var interpolation: SPTEasingType {
        get {
            animator.source.oscillator.interpolation
        }
        set {
            animator.source.oscillator.interpolation = newValue
        }
    }
    
}

class OscillatorAnimatorComponentViewProvider: ComponentViewProvider<OscillatorAnimatorComponent> {
    
    override func viewForRoot(_ root: OscillatorAnimatorComponent) -> AnyView? {
        AnyView(OscillatorAnimatorComponentView(component: root))
    }
}

struct OscillatorAnimatorComponentView: View {
    
    @ObservedObject var component: OscillatorAnimatorComponent
    @State private var scale = FloatSelector.Scale._1
    @State private var isSnappingEnabled = true
    
    var body: some View {
        if let property = component.selectedProperty {
            Group {
                switch property {
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
    
}

struct OscillatorAnimatorOutlineView: View {
    
    @ObservedObject var component: OscillatorAnimatorComponent
    var onEnterEditMode: () -> Void
    
    var body: some View {
        Form {
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

class OscillatorAnimatorViewModel: BasicAnimatorViewModel<OscillatorAnimatorComponent> {
    
    private var willChangeSubscription: SPTAnySubscription?
    
    init(animatorId: SPTAnimatorId) {
        
        super.init(rootComponent: .init(animatorId: animatorId), animatorId: animatorId)
        
        willChangeSubscription = SPTAnimator.onWillChangeSink(id: animatorId) { [weak self] newValue in
            guard let self = self else { return }
            if newValue.source.oscillator.interpolation != self.animator.source.oscillator.interpolation {
                self.restartFlag = true
            }
        }
    }
    
}

struct OscillatorAnimatorView: View {
    
    @StateObject var model: OscillatorAnimatorViewModel
    @State private var isEditing = false
    
    static let componentViewProvider = OscillatorAnimatorComponentViewProvider()
    
    var body: some View {
        BasicAnimatorView(model: model, componentViewProvider: Self.componentViewProvider, isEditing: $isEditing) {
            OscillatorAnimatorOutlineView(component: model.rootComponent) {
                isEditing = true
            }
        }
    }
    
}

struct OscillatorAnimatorView_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        let animatorId: SPTAnimatorId
        
        var body: some View {
            NavigationStack {
                OscillatorAnimatorView(model: .init(animatorId: animatorId))
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    static var previews: some View {
        let id = SPTAnimator.make(.init(name: "Oscillator.1", source: .init(oscillatorWithFrequency: 1.0, interpolation: .smoothStep)))
        SPTAnimator.reset(id: id)
        return ContentView(animatorId: id)
    }
    
}
