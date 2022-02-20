//
//  TransformView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.10.21.
//

import SwiftUI

struct TransformView: View {
    
    @ObservedObject var sceneViewModel: SceneViewModel
    @State private var activeTool = Tool.move
    @State private var axes = [Axis](repeating: .x, count: Tool.allCases.count)
    @State private var scales = [FloatField.Scale._1, FloatField.Scale._10, FloatField.Scale._0_1]
    @State private var isNavigating = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometryProxy in
            NavigationView {
                ZStack {
                    SceneView(model: sceneViewModel, isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation))
                    VStack(spacing: Self.margin) {
                        Spacer()
                        if let selectedObject = sceneViewModel.selectedObject {
                            ObjectControlView(tool: activeTool, axis: $axes[activeTool.rawValue], scale: $scales[activeTool.rawValue], model: ObjectControlViewModel(object: selectedObject))
                                .padding(.horizontal, Self.margin)
                                .id(activeTool.rawValue)
                        }
                        Toolbar(selection: $activeTool)
                            .padding(.bottom, geometryProxy.safeAreaInsets.bottom)
                    }
                    .visible(!isNavigating)
                }
                .navigationTitle("Tools")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(isNavigating)
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .visible(!isNavigating)
                    }
                }
            }
        }
    }
    
    static let margin = 8.0
}


struct ObjectControlView: View {
    
    fileprivate let tool: Tool
    @Binding fileprivate var axis: Axis
    @Binding fileprivate var scale: FloatField.Scale
    @ObservedObject fileprivate var model: ObjectControlViewModel
    
    var body: some View {
        VStack(spacing: Self.controlsSpacing) {
            floatField
                .transition(.identity)
                .id(axis.rawValue)
            Selector(selected: $axis)
        }
        .id(model.object.entity.rawValue)
    }
    
    var floatField: FloatField {
        switch tool {
        case .move:
            return FloatField(value: $model.position[axis.rawValue], scale: $scale)
        case .orient:
            let angleFormatter = MeasurementFormatter()
            angleFormatter.unitStyle = .short
            return FloatField(value: $model.eulerRotation[axis.rawValue], scale: $scale, measurementFormatter: angleFormatter, formatterSubjectProvider: { value in
                Measurement<UnitAngle>(value: Double(value), unit: .degrees) as NSObject
            })
        case .scale:
            return FloatField(value: $model.scale[axis.rawValue], scale: $scale)
        }
    }
    
    static let controlsMargin = 8.0
    static let controlsSpacing = 8.0
}


//import Combine
//
//@propertyWrapper
//class SPTPublishedPosition {
//
//    let object: SPTObject
//    let publisher = PassthroughSubject<Void, Never>()
//
//    init(object: SPTObject) {
//        self.object = object
//
//        SPTAddPositionListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer in
//            let me = Unmanaged<SPTPublishedPosition>.fromOpaque(observer!).takeUnretainedValue()
//            me.publisher.send()
//        })
//    }
//
//    deinit {
//        SPTRemovePositionListener(object, Unmanaged.passUnretained(self).toOpaque())
//    }
//
//    var wrappedValue: simd_float3 {
//        set { SPTUpdatePosition(object, newValue) }
//        get { SPTGetPosition(object) }
//    }
//}

fileprivate class ObjectControlViewModel: ObservableObject {
    
    let object: SPTObject
    
    init(object: SPTObject) {
        self.object = object
        
        SPTAddPositionWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer in
            let me = Unmanaged<ObjectControlViewModel>.fromOpaque(observer!).takeUnretainedValue()
            me.objectWillChange.send()
        })
        
        SPTAddEulerOrientationWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer in
            let me = Unmanaged<ObjectControlViewModel>.fromOpaque(observer!).takeUnretainedValue()
            me.objectWillChange.send()
        })
        
        SPTAddScaleWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer in
            let me = Unmanaged<ObjectControlViewModel>.fromOpaque(observer!).takeUnretainedValue()
            me.objectWillChange.send()
        })
        
    }
    
    deinit {
        SPTRemovePositionWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
        SPTRemoveEulerOrientationWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
        SPTRemoveScaleWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
    
    var position: simd_float3 {
        set { SPTUpdatePosition(object, newValue) }
        get { SPTGetPosition(object) }
    }
    
    var eulerRotation: simd_float3 {
        set { SPTUpdateEulerOrientationRotation(object, SPTToRadFloat3(newValue)) }
        get { SPTToDegFloat3(SPTGetEulerOrientation(object).rotation) }
    }
    
    var scale: simd_float3 {
        set { SPTUpdateScale(object, newValue) }
        get { SPTGetScale(object) }
    }
}


fileprivate struct Toolbar: View {
    
    @Binding var selection: Tool
    
    var body: some View {
        BottomBar()
            .overlay {
                HStack(spacing: 0.0) {
                    ForEach(Tool.allCases) { tool in
                        itemFor(tool)
                            .foregroundColor(selection == tool ? .accentColor : .gray)
                            .onTapGesture {
                                selection = tool
                            }
                    }
                }
                .padding(.top, Self.topPadding)
            }
    }
    
    static let topPadding = 4.0
    
    func itemFor(_ tool: Tool) -> some View {
        Label(tool.title, systemImage: tool.image)
            .labelStyle(ItemLabelStyle())
            .frame(maxWidth: .infinity, minHeight: Self.itemHeight)
    }
    
    static let itemHeight = 44.0
    
    struct ItemLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            VStack(alignment: .center, spacing: Self.iconTextSpacing) {
                configuration.icon.imageScale(.large)
                configuration.title.font(.system(.caption2))
            }
        }
        
        static let iconTextSpacing = 2.0
    }
    
}


fileprivate enum Tool: Int, CaseIterable, Identifiable {
    
    case move
    case orient
    case scale
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .move:
            return "Move"
        case .orient:
            return "Orient"
        case .scale:
            return "Scale"
        }
    }
    
    var image: String {
        switch self {
        case .move:
            return "move.3d"
        case .orient:
            return "rotate.3d"
        case .scale:
            return "scale.3d"
        }
    }
}

struct TransformView_Previews: PreviewProvider {
    
    struct TransformViewContainer: View {
        
        @StateObject var sceneViewModel = SceneViewModel()
        
        var body: some View {
            TransformView(sceneViewModel: sceneViewModel)
        }
    }
    
    static var previews: some View {
        TransformViewContainer()
    }
}
