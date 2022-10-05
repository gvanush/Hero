//
//  AnimmoveToolControlsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.10.22.
//

import SwiftUI
import Combine


fileprivate class SelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let rootComponent: PositionAnimatorBindingsComponent
    @Published var activeComponent: Component
    
    @SPTObservedComponent private var sptPosition: SPTPosition
    
    init(object: SPTObject, sceneViewModel: SceneViewModel) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        self.rootComponent = PositionAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: nil)
        self.activeComponent = rootComponent
        
        _sptPosition = SPTObservedComponent(object: object)
        _sptPosition.publisher = self.objectWillChange
    }
    
    var position: simd_float3 {
        set { sptPosition.xyz = newValue }
        get { sptPosition.xyz }
    }
    
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: SelectedObjectViewModel
    
    var body: some View {
        PropertyTreeNavigationVIew(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, actionViewViewProvider: MeshObjectComponentActionViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
    }
    
}


fileprivate struct SelectedObjectOptionsView: View {
    
    @ObservedObject var model: SelectedObjectViewModel
    
    var body: some View {
        if let animatorBindingComponent = model.activeComponent as? PositionAnimatorBindingComponent {
            AnimatorBindingOptionsView(component: animatorBindingComponent)
        }
    }
    
}

fileprivate struct AnimatorBindingOptionsView<AP>: View where AP: SPTAnimatableProperty {
    
    @ObservedObject var component: AnimatorBindingComponent<AP>
    
    @State private var showsAnimatorSelector = false
    
    var body: some View {
        if let animator = component.animator {
            HStack {
                
                Button {
                    
                } label: {
                    Image(systemName: "slider.horizontal.below.rectangle")
                        .imageScale(.large)
                }
                
                Spacer()
                
                Button {
                    showsAnimatorSelector = true
                } label: {
                    HStack(spacing: 0.0) {
                        Image(systemName: "bolt")
                            .imageScale(.large)
                        Text(animator.name)
                            .font(Font.system(size: 15, weight: .light))
                    }
                }
                .tint(.objectSelectionColor)
                
                Spacer()
                
                Button {
                    withAnimation(PropertyTreeNavigationVIew.defaultNavigationAnimation) {
                        //                    model.activeComponent = component
                        component.unbindAnimator()
                    }
                } label: {
                    Image(systemName: "bolt.slash")
                        .imageScale(.large)
                }
                .tint(.objectSelectionColor)
                
            }
            .sheet(isPresented: $showsAnimatorSelector) {
                AnimatorSelector { animatorId in
                    if let animatorId = animatorId {
                        component.bindAnimator(id: animatorId)
                    }
                    showsAnimatorSelector = false
                }
            }
        }
    }
}


class AnimmoveToolViewModel: ObservableObject {
    
    let sceneViewModel: SceneViewModel
    
    @Published fileprivate var selectedObjectViewModel: SelectedObjectViewModel?
    
    private var selectedObjectSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        self.sceneViewModel = sceneViewModel
        
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [weak self] selected in
            self?.setupSelectedObjectViewModel(object: selected)
        }
        
        setupSelectedObjectViewModel(object: sceneViewModel.selectedObject)
        
    }
    
    private func setupSelectedObjectViewModel(object: SPTObject?) {
        if let object = object {
            selectedObjectViewModel = .init(object: object, sceneViewModel: sceneViewModel)
        } else {
            selectedObjectViewModel = nil
        }
    }
    
}


struct AnimmoveToolControlsView: View {
    
    @ObservedObject var model: AnimmoveToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
        } else {
            EmptyView()
        }
    }
}

struct AnimmoveToolOptionsView: View {
    
    @ObservedObject var model: AnimmoveToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectOptionsView(model: selectedObjectVM)
        } else {
            EmptyView()
        }
    }
    
}
