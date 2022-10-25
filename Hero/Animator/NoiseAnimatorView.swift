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
}

class NoiseAnimatorComponent: BasicComponent<NoiseAnimatorProperty> {

    @SPTObservedAnimator var animator: SPTAnimator
    let frequencyFormatter = FrequencyFormatter()
    
    init(animatorId: SPTAnimatorId) {
        _animator = .init(id: animatorId)
        
        super.init(title: "Noise", selectedProperty: .seed, parent: nil)
        
        _animator.publisher = self.objectWillChange
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
    
}

class NoiseAnimatorComponentViewProvider: ComponentViewProvider<NoiseAnimatorComponent> {
    
    override func viewForRoot(_ root: NoiseAnimatorComponent) -> AnyView? {
        AnyView(NoiseAnimatorComponentView(component: root))
    }
}

struct NoiseAnimatorComponentView: View {
    
    @ObservedObject var component: NoiseAnimatorComponent
    @State private var scale = FloatSelector.Scale._1
    @State private var isSnappingEnabled = false
    
    var body: some View {
        if let property = component.selectedProperty {
            Group {
                switch property {
                case .seed:
                    RandomSeedSelector(seed: component.seed) { newValue in
                        component.seed = newValue
                    }
                case .frequency:
                    FloatSelector(value: $component.frequency, valueTransformer: .frequency, scale: $scale, isSnappingEnabled: $isSnappingEnabled, formatter: component.frequencyFormatter)
                }
            }
            .tint(.primary)
            .transition(.identity)
        }
    }
    
}

class NoiseAnimatorViewModel: AnimatorViewModel {
    
    fileprivate let rootComponent: NoiseAnimatorComponent
    @Published fileprivate var activeComponent: Component
    
    private var willChangeSubscription: SPTAnySubscription?
    
    override init(animatorId: SPTAnimatorId) {
        
        self.rootComponent = NoiseAnimatorComponent(animatorId: animatorId)
        self.activeComponent = self.rootComponent
        
        super.init(animatorId: animatorId)
        
        willChangeSubscription = SPTAnimator.onWillChangeSink(id: animatorId) { [weak self] newValue in
            guard let self = self else { return }
            if newValue.source.noise.seed != self.animator.source.noise.seed {
                self.restartFlag = true
            }
        }
    }
    
    func getValueItem(samplingRate: Int, time: TimeInterval) -> SignalValueItem? {
        
        var context = SPTAnimatorEvaluationContext()
        context.samplingRate = samplingRate
        context.time = time

        if let value = getAnimatorValue(context: context) {
            return .init(value: value, interpolate: true)
        }
        
        return nil
    }
    
}

struct NoiseAnimatorView: View {
    
    @StateObject var model: NoiseAnimatorViewModel
    @State private var isEditing = false
    
    static let componentViewProvider = NoiseAnimatorComponentViewProvider()
    
    var body: some View {
        ZStack {
            Color.systemBackground
            VStack(spacing: 0.0) {
                SignalGraphView(restartFlag: $model.restartFlag) { samplingRate, time in
                    model.getValueItem(samplingRate: samplingRate, time: time)
                } onStart: {
                    model.resetAnimator()
                }
                .padding()
                .layoutPriority(1)
                
                if isEditing {
                    componentNavigationView()
                } else {
                    Form {
                        SceneEditableParam(title: "Seed", valueText: Text(model.rootComponent.seed, format: .number)) {
                            withAnimation {
                                model.rootComponent.selectedProperty = .seed
                                isEditing = true
                            }
                        }
                        SceneEditableParam(title: "Frequency", valueText: Text(NSNumber(value: model.rootComponent.frequency), formatter: model.rootComponent.frequencyFormatter)) {
                            withAnimation {
                                model.rootComponent.selectedProperty = .frequency
                                isEditing = true
                            }
                        }
                    }
                    // NOTE: This is necessary for unknown reason to prevent 'Form' row
                    // from being selectable when there is a button inside.
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .navigationTitle(model.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Spacer()
                Button {
                    model.destroy()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    func componentNavigationView() -> some View {
        VStack {
            Spacer()
            ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: Self.componentViewProvider, setupViewProvider: EmptyComponentSetupViewProvider())
                .padding(.horizontal, 8.0)
            bottomBar()
        }
        .transition(.move(edge: .bottom))
    }
    
    func bottomBar() -> some View {
        HStack {
            ScrollView(.horizontal) {
                
            }
            .tint(.primary)
            Button {
                withAnimation {
                    isEditing = false
                }
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.large)
                    .frame(width: 44.0, height: 44.0)
            }

        }
        .padding(.horizontal, 8.0)
        .padding(.vertical, 4.0)
        .frame(height: 56.0)
        .background(Material.bar)
        .compositingGroup()
        .shadow(radius: 0.5)
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
        let id = SPTAnimator.make(.init(name: "Noise.1", source: .init(noiseWithSeed: 1, frequency: 1.0)))
        SPTAnimator.reset(id: id)
        return ContentView(animatorId: id)
    }
}
