//
//  PanAnimatorSetBoundsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.07.22.
//

import SwiftUI


class PanAnimatorSetBoundsViewModel: ObservableObject {
    
    @Published private(set) var animator: SPTAnimator
    
    init(animatorId: SPTAnimatorId) {
        animator = SPTAnimatorGet(animatorId)
        
        SPTAnimatorAddWillChangeListener(animatorId, Unmanaged.passUnretained(self).toOpaque(), { listener, newValue  in
            let me = Unmanaged<PanAnimatorSetBoundsViewModel>.fromOpaque(listener).takeUnretainedValue()
            me.animator = newValue
        })
    }
    
    deinit {
        SPTAnimatorRemoveWillChangeListener(animator.id, Unmanaged.passUnretained(self).toOpaque())
    }
    
    func commit() {
        SPTAnimatorUpdate(animator)
    }
    
    var name: String {
        animator.name.capitalizingFirstLetter()
    }
    
    func updateTopLeft(delta: CGSize, screenSize: CGSize, minSize: CGSize) {
        let normDelta = normDelta(delta: delta, screenSize: screenSize)
        let normMinSize = normSize(size: minSize, screenSize: screenSize)
        updateTopRightY(delta: normDelta.y, minSize: normMinSize.y)
        updateBottomLeftX(delta: normDelta.x, minSize: normMinSize.x)
    }

    func updateTopRight(delta: CGSize, screenSize: CGSize, minSize: CGSize) {
        let normDelta = normDelta(delta: delta, screenSize: screenSize)
        let normMinSize = normSize(size: minSize, screenSize: screenSize)
        updateTopRightX(delta: normDelta.x, minSize: normMinSize.x)
        updateTopRightY(delta: normDelta.y, minSize: normMinSize.y)
    }

    func updateBottomLeft(delta: CGSize, screenSize: CGSize, minSize: CGSize) {
        let normDelta = normDelta(delta: delta, screenSize: screenSize)
        let normMinSize = normSize(size: minSize, screenSize: screenSize)
        updateBottomLeftX(delta: normDelta.x, minSize: normMinSize.x)
        updateBottomLeftY(delta: normDelta.y, minSize: normMinSize.y)
    }

    func updateBottomRight(delta: CGSize, screenSize: CGSize, minSize: CGSize) {
        let normDelta = normDelta(delta: delta, screenSize: screenSize)
        let normMinSize = normSize(size: minSize, screenSize: screenSize)
        updateTopRightX(delta: normDelta.x, minSize: normMinSize.x)
        updateBottomLeftY(delta: normDelta.y, minSize: normMinSize.y)
    }
    
    private func normDelta(delta: CGSize, screenSize: CGSize) -> simd_float2 {
        simd_float2(Float(delta.width / screenSize.width), -Float(delta.height / screenSize.height))
    }
    
    private func normSize(size: CGSize, screenSize: CGSize) -> simd_float2 {
        simd_float2(Float(size.width / screenSize.width), Float(size.height / screenSize.height))
    }
    
    private func updateTopRightX(delta: Float, minSize: Float) {
        animator.topRight.x = simd_clamp(animator.topRight.x + delta, animator.bottomLeft.x + minSize, 1.0)
    }
    
    private func updateTopRightY(delta: Float, minSize: Float) {
        animator.topRight.y = simd_clamp(animator.topRight.y + delta, animator.bottomLeft.y + minSize, 1.0)
    }
    
    private func updateBottomLeftX(delta: Float, minSize: Float) {
        animator.bottomLeft.x = simd_clamp(animator.bottomLeft.x + delta, 0.0, animator.topRight.x - minSize)
    }
    
    private func updateBottomLeftY(delta: Float, minSize: Float) {
        animator.bottomLeft.y = simd_clamp(animator.bottomLeft.y + delta, 0.0, animator.topRight.y - minSize)
    }
    
    func updateCenter(delta: CGSize, screenSize: CGSize) {
        let normDelta = normDelta(delta: delta, screenSize: screenSize)
        let normSize = animator.topRight - animator.bottomLeft

        if normDelta.x >= 0.0 {
            animator.topRight.x = min(animator.topRight.x + normDelta.x, 1.0)
            animator.bottomLeft.x = animator.topRight.x - normSize.x
        } else {
            animator.bottomLeft.x = max(animator.bottomLeft.x + normDelta.x, 0.0)
            animator.topRight.x = animator.bottomLeft.x + normSize.x
        }

        if normDelta.y >= 0.0 {
            animator.topRight.y = min(animator.topRight.y + normDelta.y, 1.0)
            animator.bottomLeft.y = animator.topRight.y - normSize.y
        } else {
            animator.bottomLeft.y = max(animator.bottomLeft.y + normDelta.y, 0.0)
            animator.topRight.y = animator.bottomLeft.y + normSize.y
        }
    }
    
    func boundsRect(screenSize: CGSize) -> CGRect {
        let topLeft = simd_float2(animator.bottomLeft.x, animator.topRight.y)
        return CGRect(origin: CGPoint(x: CGFloat(topLeft.x) * screenSize.width, y: CGFloat(1.0 - topLeft.y) * screenSize.height), size: animator.boundsSizeOnScreenSize(screenSize))
    }
}

struct PanAnimatorSetBoundsView: View {
    
    enum Handle: Int {
        case bottomLeft
        case bottomRight
        case topRight
        case topLeft
        case center
    }
    
    @ObservedObject var model: PanAnimatorSetBoundsViewModel
    @GestureState var isDragging = false
    @State var prevTranslation: CGSize?
    @State var activeHandle: Handle?
    @State var showsViewBoundsView = false
    
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    screenArea(screenSize: geometry.size)
                    boundsView(screenSize: geometry.size)
                        .allowsHitTesting(false)
                }
                
            }
            .padding(32)
            .navigationTitle("\(model.name) Bounds")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        model.commit()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("View") {
                        showsViewBoundsView = true
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showsViewBoundsView) {
            PanAnimatorViewBoundsView(model: PanAnimatorViewBoundsViewModel(animator: model.animator))   
        }
        .onChange(of: isDragging) { newValue in
            if !newValue {
                prevTranslation = nil
                activeHandle = nil
            }
        }
    }
    
    func screenArea(screenSize: CGSize) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Screen Area")
                    .foregroundColor(.tertiaryLabel)
                Spacer()
            }
            Spacer()
        }
        .background(Color.secondarySystemBackground)
        .gesture(dragGesture(screenSize: screenSize))
    }
    
    func boundsView(screenSize: CGSize) -> some View {
        Rectangle()
            .foregroundColor(.accentColor.opacity(0.2))
            .overlay {
                ZStack {
                    VStack {
                        HStack {
                            mainDiagEdgeHandle
                            Spacer()
                            minorDiagEdgeHandle
                        }
                        Spacer()
                        HStack {
                            minorDiagEdgeHandle
                            Spacer()
                            mainDiagEdgeHandle
                        }
                    }
                    handle(iconName: Self.centerHandleIconName)
                }
            }
            .frame(size: model.animator.boundsSizeOnScreenSize(screenSize))
            .offset(model.animator.boundsOffsetOnScreenSize(screenSize))
    }
    
    var mainDiagEdgeHandle: some View {
        handle(iconName: Self.edgeHandleIconName)
    }
    
    var minorDiagEdgeHandle: some View {
        handle(iconName: Self.edgeHandleIconName)
            .rotationEffect(.degrees(90))
    }
    
    func handle(iconName: String) -> some View {
        Image(systemName: iconName)
            .imageScale(.large)
            .foregroundColor(.accentColor)
    }
    
    func dragGesture(screenSize: CGSize) -> some Gesture {
        
        DragGesture(minimumDistance: 0.0)
            .updating($isDragging, body: { value, state, _ in
                state = true
            })
            .onChanged { value in
                var delta = value.translation
                if let prevTranslation = prevTranslation {
                    delta.width -= prevTranslation.width
                    delta.height -= prevTranslation.height
                }
                prevTranslation = value.translation
                
                if activeHandle == nil {
                    let boundsRect = model.boundsRect(screenSize: screenSize)
                    let bottomLeftRect = CGRect(origin: .init(x: boundsRect.minX, y: boundsRect.maxY - Self.edgeHandleSize.height), size: Self.edgeHandleSize)
                    let bottomRightRect = CGRect(origin: .init(x: boundsRect.maxX - Self.edgeHandleSize.width, y: boundsRect.maxY - Self.edgeHandleSize.height), size: Self.edgeHandleSize)
                    let topRightRect = CGRect(origin: .init(x: boundsRect.maxX - Self.edgeHandleSize.width, y: boundsRect.minY), size: Self.edgeHandleSize)
                    let topLeftRect = CGRect(origin: .init(x: boundsRect.minX, y: boundsRect.minY), size: Self.edgeHandleSize)
                    
                    if(bottomLeftRect.contains(value.location)) {
                        activeHandle = .bottomLeft
                    } else if(bottomRightRect.contains(value.location)) {
                        activeHandle = .bottomRight
                    } else if(topRightRect.contains(value.location)) {
                        activeHandle = .topRight
                    } else if(topLeftRect.contains(value.location)) {
                        activeHandle = .topLeft
                    } else {
                        activeHandle = .center
                    }
                }
                
                updateHandle(activeHandle!, delta: delta, screenSize: screenSize)
                
            }
            .onEnded { value in
                let delta = CGSize(width: value.translation.width - prevTranslation!.width, height: value.translation.height - prevTranslation!.height)
                updateHandle(activeHandle!, delta: delta, screenSize: screenSize)
            }
    }
    
    func updateHandle(_ handle: Handle, delta: CGSize, screenSize: CGSize) {
        switch activeHandle! {
        case .bottomLeft:
            model.updateBottomLeft(delta: delta, screenSize: screenSize, minSize: Self.areaMinSize)
        case .bottomRight:
            model.updateBottomRight(delta: delta, screenSize: screenSize, minSize: Self.areaMinSize)
        case .topRight:
            model.updateTopRight(delta: delta, screenSize: screenSize, minSize: Self.areaMinSize)
        case .topLeft:
            model.updateTopLeft(delta: delta, screenSize: screenSize, minSize: Self.areaMinSize)
        case .center:
            model.updateCenter(delta: delta, screenSize: screenSize)
        }
    }
    
    static let edgeHandleSize = CGSize(width: 44, height: 44)
    static let edgeHandleIconName = "arrow.up.left.and.arrow.down.right"
    static let centerHandleIconName = "arrow.up.and.down.and.arrow.left.and.right"
    static let areaMinSize = CGSize(width: 88.0, height: 88.0)
}

fileprivate struct BoundsView: View {
    
    let bottomLeft: simd_float2
    let topRight: simd_float2
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let x = CGFloat(bottomLeft.x) * geometry.size.width
                let y = CGFloat(1 - topRight.y) * geometry.size.height
                let width = CGFloat(topRight.x - bottomLeft.x) * geometry.size.width
                let height = CGFloat(topRight.y - bottomLeft.y) * geometry.size.height
                path.addRect(.init(x: x, y: y, width: width, height: height))
            }
            .stroke(Color.accentColor, lineWidth: 1.0)
        }
        .background(Color.accentColor.opacity(0.2))
    }
    
}

struct PanAnimatorSetAreaView_Previews: PreviewProvider {
    static var previews: some View {
        PanAnimatorSetBoundsView(model: .init(animatorId:
                                                    SPTAnimatorMake(SPTAnimator(name: "Pan 1",
                                                                                bottomLeft: .init(0.1, 0.1),
                                                                                topRight: .init(0.5, 0.7)))
                                                 ))
    }
}
