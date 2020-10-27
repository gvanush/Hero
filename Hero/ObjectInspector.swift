//
//  ObjectInspector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10/22/20.
//

import SwiftUI

enum ObjectTool: CaseIterable {
    case move
    case scale
    case rotate
    
    var iconName: String {
        switch self {
        case .move:
            return "move.3d"
        case .scale:
            return "scale.3d"
        case .rotate:
            return "rotate.3d"
        }
    }
}

struct ObjectToolbarItem: View {
    
    let iconName: String
    let onSelected: () -> Void
        
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 25, weight: .regular))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelected)
    }
}

struct ObjectToolbar: View {
    
    @State var selectedTool = ObjectTool.move
    
    var body: some View {
        HStack(alignment: .center, spacing: 0.0) {
            ForEach(ObjectTool.allCases, id: \.self) {tool in
                ObjectToolbarItem(iconName: tool.iconName) {
                    self.selectedTool = tool
                }
                .foregroundColor(tool == selectedTool ? Color.accentColor : Color.white.opacity(0.5))
            }
        }
    }
}

struct ObjectInspector: View {
    
    @State var normOffsetY: CGFloat = 0.0
    @State var isOpen = false {
        willSet {
            normOffsetY = (newValue ? 1.0 : 0.0)
        }
    }
    @State var lastDragValue: DragGesture.Value?
    @State var isDragging = false
    
    var body: some View {
        GeometryReader { proxy in
            Group {
                VStack(spacing: 0.0) {
                    header(proxy)
                    body(proxy)
                }
                .offset(x: 0.0, y: normOffsetY * proxy.safeAreaInsets.top)
            }
//                .padding(.top, proxy.safeAreaInsets.top)
                .background(BlurView(style: .systemUltraThinMaterial))
                .offset(x: 0.0, y: offsetY(proxy))
                .edgesIgnoringSafeArea([.bottom, .top])
        }
    }
    
    func header(_ proxy: GeometryProxy) -> some View {
        ZStack {
            HStack(spacing: 0.0) {
                Group {
                    ObjectToolbar()
                    Divider()
                }
                    .opacity(isDragging || isOpen ? 0.0 : 1.0)
//                    .offset(x: 0.0, y: isDragging || isOpen ? -proxy.safeAreaInsets.top : 0.0)
                objectOptionsControl
            }
            Text("Object 0")
                .font(.system(size: 30, weight: .regular))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
                .opacity(isOpen || isDragging ? 1.0 : 0.0)
                .offset(x: 0.0, y: isOpen || isDragging ? 0.0 : proxy.safeAreaInsets.top)
            
            handle
        }
            .frame(maxWidth: .infinity, maxHeight: ObjectInspector.topBarHeight, alignment: .center)
            .contentShape(Rectangle())
            .gesture(self.dragGesture(proxy))
    }
    
    func body(_ proxy: GeometryProxy) -> some View {
        HStack(spacing: 0.0) {
            edgeDragArea(proxy)
            ScrollView() {

            }
//                        .background(Color.red)
            edgeDragArea(proxy)
        }
    }
    
    var objectOptionsControl: some View {
        Image(systemName: "ellipsis")
            .font(.system(size: 25, weight: .regular))
            .foregroundColor(Color.white)
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
            .offset(x: 0, y: -0.5 * ObjectInspector.topBarHeight + 8.0)
    }
    
    func offsetY(_ proxy: GeometryProxy) -> CGFloat {
        (1.0 - normOffsetY) * (proxy.size.height + proxy.safeAreaInsets.top - ObjectInspector.topBarHeight)
    }
    
    func computeNormOffsetY(_ value: DragGesture.Value, _ proxy: GeometryProxy) -> CGFloat {
        if isOpen {
            return 1.0 - clamp(value.translation.height / (proxy.size.height - ObjectInspector.topBarHeight), lower: 0.0, upper: 1.0)
        } else {
            return -clamp(value.translation.height / (proxy.size.height - ObjectInspector.topBarHeight), lower: -1.0, upper: 0.0)
        }
    }
    
    func dragGesture(_ proxy: GeometryProxy) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                normOffsetY = computeNormOffsetY(value, proxy)
                lastDragValue = value
                if !isDragging {
                    withAnimation {
                        isDragging = true
                    }
                }
            }
            .onEnded { value in
                guard let lastDragValue = self.lastDragValue else {
                    isDragging = false
                    return
                }
                
                let normOffset = computeNormOffsetY(value, proxy)
                let normDist = abs(normOffset - self.normOffsetY)
                let speed = max(normDist / CGFloat(value.time.timeIntervalSince(lastDragValue.time)), 1.5)
                
                let normPredictedTranslation = value.predictedEndTranslation.height / (proxy.size.height - ObjectInspector.topBarHeight)
                var shouldToggle = true
                if normPredictedTranslation > 0.0 {
                    shouldToggle = (isOpen && normPredictedTranslation > 0.5)
                } else {
                    shouldToggle = (!isOpen && normPredictedTranslation < -0.5)
                }
                
                let shouldAnimateUp = (shouldToggle && !isOpen) || (!shouldToggle && isOpen)
                let normRemainingDist = (shouldAnimateUp ? 1.0 - normOffset : normOffset)
                let duration = max(Double(normRemainingDist / speed), 0.15)
                    
                withAnimation(.easeOut(duration: duration)) {
                    if shouldToggle {
                        isOpen.toggle()
                    } else {
                        isOpen = (isOpen ? true : false)
                    }
                    isDragging = false
                }
                
            }
    }
    
    func edgeDragArea(_ proxy: GeometryProxy) -> some View {
        Color.clear
            .frame(minWidth: ObjectInspector.edgeDragAreaWidth, idealWidth: ObjectInspector.edgeDragAreaWidth, maxWidth: ObjectInspector.edgeDragAreaWidth, minHeight: 0.0, idealHeight: 0.0, maxHeight: .infinity
                   , alignment: .center)
            .contentShape(Rectangle())
            .gesture(dragGesture(proxy))
    }
    
    static let topBarHeight: CGFloat = 70.0
    static let edgeDragAreaWidth: CGFloat = 20.0
    
}

struct ObjectToolbar_Previews: PreviewProvider {
    static var previews: some View {
//        ObjectToolbar()
        ObjectInspector()
    }
}
