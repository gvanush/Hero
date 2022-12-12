//
//  BasicAnimatorView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.12.22.
//

import SwiftUI

class BasicAnimatorViewModel<RC>: AnimatorViewModel where RC: Component {
    
    let rootComponent: RC
    @Published var activeComponent: Component
    
    init(rootComponent: RC, animatorId: SPTAnimatorId) {
        self.rootComponent = rootComponent
        self.activeComponent = rootComponent
        
        super.init(animatorId: animatorId)
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


struct BasicAnimatorView<RC, OV>: View where RC: Component, OV: View {
    
    @ObservedObject var model: BasicAnimatorViewModel<RC>
    let componentViewProvider: ComponentViewProvider<RC>
    @Binding var isEditing: Bool
    let outlineView: OV
    
    init(model: BasicAnimatorViewModel<RC>, componentViewProvider: ComponentViewProvider<RC>, isEditing: Binding<Bool>, @ViewBuilder outlineView: () -> OV) {
        _model = .init(wrappedValue: model)
        self.componentViewProvider = componentViewProvider
        _isEditing = isEditing
        self.outlineView = outlineView()
    }
    
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
                    outlineView
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
            ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: componentViewProvider, setupViewProvider: EmptyComponentSetupViewProvider())
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
