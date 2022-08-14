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
        GeometryReader { geometry in
            NavigationView {
                GeometryReader { navigationGeometry in
                    ZStack {
                        SceneView(model: sceneViewModel, uiSafeAreaInsets: navigationGeometry.safeAreaInsets.bottomInseted(BottomBar.height), isNavigating: $isNavigating.animation(.sceneNavigationStateChangeAnimation)) {
                            
                            if let selectedObject = sceneViewModel.selectedObject {
                                ObjectControlView(tool: activeTool, axis: $axes[activeTool.rawValue], scale: $scales[activeTool.rawValue], model: ObjectControlViewModel(object: selectedObject))
                                    .id(activeTool.rawValue)
                            }
                            
                        }
                        VStack {
                            Spacer()
                            Toolbar(selection: $activeTool)
                                .padding(.bottom, geometry.safeAreaInsets.bottom)
                                .offset(y: isNavigating ? BottomBar.height + geometry.safeAreaInsets.bottom : 0.0)
                        }
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
                        }
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
                .selectedObjectUI(cornerRadius: FloatField.cornerRadius)
                .transition(.identity)
                .id(axis.rawValue)
            Selector(selected: $axis)
                .selectedObjectUI(cornerRadius: SelectorConst.cornerRadius)
        }
        .id(model.object.entity.rawValue)
    }
    
    var floatField: FloatField {
        switch tool {
        case .move:
            return FloatField(value: $model.position[axis.rawValue], scale: $scale)
        case .orient:
            return FloatField(value: $model.eulerRotation[axis.rawValue], scale: $scale, measurementFormatter: .angleFormatter, formatterSubjectProvider: MeasurementFormatter.angleSubjectProvider)
        case .scale:
            return FloatField(value: $model.scale[axis.rawValue], scale: $scale)
        }
    }
    
    static let controlsSpacing = 8.0
    static let height = controlsSpacing + FloatField.height + SelectorConst.height
}


fileprivate class ObjectControlViewModel: ObservableObject {
    
    let object: SPTObject
    @SPTObservedComponent var sptPosition: SPTPosition
    @SPTObservedComponent var sptScale: SPTScale
    @SPTObservedComponent var sptOrientation: SPTOrientation
    
    init(object: SPTObject) {
        self.object = object
        
        _sptPosition = SPTObservedComponent(object: object)
        _sptOrientation = SPTObservedComponent(object: object)
        _sptScale = SPTObservedComponent(object: object)
        
        _sptPosition.publisher = self.objectWillChange
        _sptOrientation.publisher = self.objectWillChange
        _sptScale.publisher = self.objectWillChange
    }
    
    var position: simd_float3 {
        set { sptPosition.xyz = newValue }
        get { sptPosition.xyz }
    }
    
    var eulerRotation: simd_float3 {
        set { sptOrientation.euler.rotation = SPTToRadFloat3(newValue) }
        get { SPTToDegFloat3(sptOrientation.euler.rotation) }
    }
    
    var scale: simd_float3 {
        set { sptScale.xyz = newValue }
        get { sptScale.xyz }
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
