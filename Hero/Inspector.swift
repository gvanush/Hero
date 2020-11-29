//
//  Inspector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10/22/20.
//

import SwiftUI

struct Inspector: View {
    
    enum DragState {
        case inactive
        case dragging(normTranslationY: CGFloat)
        
        var normTranslationY: CGFloat {
            switch self {
            case .inactive:
                return .zero
            case .dragging(let normTranslationY):
                return normTranslationY
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive:
                return false
            case .dragging:
                return true
            }
        }
    }
    
    @ObservedObject var model: InspectorModel
    @GestureState var dragState = DragState.inactive
    @State var isOpen = false {
        willSet {
            normOffsetY = (newValue ? 0.0 : 1.0)
        }
    }
    @State var normOffsetY: CGFloat = 1.0
    @State var lastDragValue: DragGesture.Value?
    @State var isToolEditingModeEnabled = true
    @State private var isAnimating = false
    @EnvironmentObject private var graphicsViewModel: GraphicsViewModel
    @EnvironmentObject private var rootViewModel: RootViewModel
        
    var body: some View {
        GeometryReader { proxy in
            Group {
                VStack(spacing: 0.0) {
                    header(proxy)
                    body(proxy)
                }
                    .offset(x: 0.0, y: contentOffset(proxy))
            }
                .background(BlurView(style: .systemMaterial))
                .offset(x: 0.0, y: offsetY(proxy))
                .gesture(self.dragGesture(proxy))
                .edgesIgnoringSafeArea([.bottom, .top])
        }
    }
    
    func header(_ proxy: GeometryProxy) -> some View {
        ZStack {
            HStack(spacing: 0.0) {
                Group {
                    ObjectToolbar()
                    Divider()
                        .background(Color(.opaqueSeparator))
                }
                    .opacity(isToolEditingModeEnabled ? 1.0 : 0.0)
                objectOptionsControl
            }
            Text(model.sceneObject.name)
                .font(.system(size: 30, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
                .opacity(isToolEditingModeEnabled ? 0.0 : 1.0)
                .offset(x: 0.0, y: isToolEditingModeEnabled ? proxy.safeAreaInsets.top : 0.0)
                .foregroundColor(Color(.label))
            
            handle
        }
            .frame(maxWidth: .infinity, maxHeight: Inspector.topBarHeight, alignment: .center)
    }
    
    func body(_ proxy: GeometryProxy) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            if isOpen || isAnimating || dragState.isDragging {
                ZStack {
                    Color.black
                    Text("dadas")
                }
            }
        }
        .opacity(isToolEditingModeEnabled ? 0.0 : 1.0)
        .offset(x: 0.0, y: isToolEditingModeEnabled ? proxy.safeAreaInsets.top : 0.0)
        .padding(.horizontal, 20)
        .onAnimationCompleted(for: normOffsetY) {
            isAnimating = false
        }
    }
    
    func contentOffset(_ proxy: GeometryProxy) -> CGFloat {
        switch dragState {
        case .dragging(let normTranslationY):
            if isOpen {
                return (1.0 - max(normTranslationY, 0.0)) * proxy.safeAreaInsets.top
            } else {
                return (-min(normTranslationY, 0.0)) * proxy.safeAreaInsets.top
            }
        case .inactive:
            return (1.0 - normOffsetY) * proxy.safeAreaInsets.top
        }
    }
    
    var objectOptionsControl: some View {
        Image(systemName: "ellipsis")
            .font(.system(size: 25, weight: .regular))
            .foregroundColor(Color(.label))
            .frame(maxHeight: .infinity)
            .padding(20)
            .contentShape(Rectangle())
            .onTapGesture {
                
            }
    }
    
    var handle: some View {
        Image(systemName: "minus")
            .font(.system(size: 45, weight: .regular))
            .foregroundColor(Color.white.opacity(0.5))
            .offset(x: 0, y: -0.5 * Inspector.topBarHeight + 8.0)
    }
    
    func offsetY(_ proxy: GeometryProxy) -> CGFloat {
        let maxOffset = proxy.size.height + proxy.safeAreaInsets.top - Inspector.topBarHeight
        switch dragState {
        case .dragging(let normTranslationY):
            if isOpen {
                return max(normTranslationY, 0.0) * maxOffset
            } else {
                return (1.0 + min(normTranslationY, 0.0)) * maxOffset
            }
        case .inactive:
            return normOffsetY * maxOffset
        }
    }
    
    func normTranslationY(_ value: DragGesture.Value, _ proxy: GeometryProxy) -> CGFloat {
        clamp(value.translation.height / (proxy.size.height - Inspector.topBarHeight), lower: -1.0, upper: 1.0)
    }
    
    func dragGesture(_ proxy: GeometryProxy) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .updating($dragState, body: { value, state, _ in
                state = .dragging(normTranslationY: normTranslationY(value, proxy))
            })
            .onChanged { value in
                lastDragValue = value
                if isToolEditingModeEnabled {
                    withAnimation(.easeOut(duration: Inspector.editingModeSwitchDuration)) {
                        isToolEditingModeEnabled = false
                        model.isTopBarVisible = false
                    }
                    graphicsViewModel.preferredFramesPerSecond = 10
                }
            }
            .onEnded { value in
                guard let lastDragValue = self.lastDragValue else {
                    return
                }
                
                let normTranY = normTranslationY(value, proxy)
                normOffsetY = clamp(normOffsetY + normTranY, lower: 0.0, upper: 1.0)
                
                let normTranDelta = abs(normTranY - normTranslationY(lastDragValue, proxy))
                let speed = max(normTranDelta / CGFloat(value.time.timeIntervalSince(lastDragValue.time)), 1.5)
                
                let normPredictedTran = value.predictedEndTranslation.height / (proxy.size.height - Inspector.topBarHeight)
                var shouldToggle = true
                if normPredictedTran > 0.0 {
                    shouldToggle = (isOpen && normPredictedTran > 0.5)
                } else {
                    shouldToggle = (!isOpen && normPredictedTran < -0.5)
                }
                
                let normRemainingDist = (shouldToggle ? 1.0 - abs(normTranY) : abs(normTranY))
                let duration = max(Double(normRemainingDist / speed), Inspector.editingModeSwitchDuration)
                
                let isOpen = (shouldToggle ? !self.isOpen : self.isOpen)
                graphicsViewModel.preferredFramesPerSecond = (isOpen ? 10 : 60)
                
                isAnimating = true
                withAnimation(.easeOut(duration: duration)) {
                    self.isOpen = isOpen
                    isToolEditingModeEnabled = !isOpen
                    model.isTopBarVisible = !isOpen
                }
                
            }
    }
        
    static let editingModeSwitchDuration = 0.2
    static let topBarHeight: CGFloat = 70.0
    
}

struct ObjectToolbar_Previews: PreviewProvider {
    static var previews: some View {
        Inspector(model: InspectorModel(sceneObject: SceneObject(), isTopBarVisible: Binding.constant(true)))
    }
}
