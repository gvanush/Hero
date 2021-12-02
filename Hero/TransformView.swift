//
//  ContentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.10.21.
//

import SwiftUI

enum Axis: Int, PropertySelectorItem {
    
    case x
    case y
    case z
    
    var id: Self { self }
    
    var displayText: String {
        switch self {
        case .x:
            return "X"
        case .y:
            return "Y"
        case .z:
            return "Z"
        }
    }
}

struct TransformView: View {
    
    @State var activeTool = Tool.move
    @State var axes = [Axis](repeating: .x, count: Tool.allCases.count)
    @State var scales = [FloatField.Scale._1, FloatField.Scale._10, FloatField.Scale._0_1]
    @State var activeValue = 0.0
    @StateObject var sceneViewModel = SceneViewModel()
    @State var isNavigating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                SceneView(model: sceneViewModel, isNavigating: $isNavigating)
                VStack(spacing: Self.controlsMargin) {
                    Spacer()
                    if sceneViewModel.selectedObject != nil {
                        controls
                            .padding(.horizontal, Self.controlsMargin)
                    }
                    Toolbar(selection: $activeTool)
                }
                .opacity(isNavigating ? 0.0 : 1.0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(activeTool.title)
            // WARNING: This is causing frame drop when isNavigating changes
            // frequently in a short period of time
            .navigationBarHidden(isNavigating)
        }
        // TODO: Remove when the bug is fixed (Needed to avoid iOS auto-layout warnings on startup)
        .navigationViewStyle(.stack)
        .onReceive(sceneViewModel.objectWillChange) { _ in
            updateActiveValue(tool: activeTool, axis: axes[activeTool.rawValue])
        }
        .onChange(of: activeTool) { newTool in
            updateActiveValue(tool: newTool, axis: axes[newTool.rawValue])
        }
        .onChange(of: axes) { newActiveAxes in
            updateActiveValue(tool: activeTool, axis: newActiveAxes[activeTool.rawValue])
        }
    }
    
    var controls: some View {
        VStack(spacing: Self.controlsSpacing) {
            floatField
                .id(10 * activeTool.rawValue + axes[activeTool.rawValue].rawValue)
            PropertySelector(selected: $axes[activeTool.rawValue])
                .id(activeTool.rawValue)
        }
    }
    
    var floatField: FloatField {
        if activeTool == .orient {
            let angleFormatter = MeasurementFormatter()
            angleFormatter.unitStyle = .short
            return FloatField(value: $activeValue.onChange(updateObject), scale: $scales[activeTool.rawValue], measurementFormatter: angleFormatter, formatterSubjectProvider: { value in
                Measurement<UnitAngle>(value: value, unit: .degrees) as NSObject
            })
                
        } else {
            return FloatField(value: $activeValue.onChange(updateObject), scale: $scales[activeTool.rawValue])
        }
    }
    
    func updateActiveValue(tool: Tool, axis: Axis) {
        guard let selectedObject = sceneViewModel.selectedObject else { return }
        
        switch tool {
        case .move:
            activeValue = Double(SPTGetPosition(selectedObject)[axis.rawValue])
        case .orient:
            activeValue = Double(toDegrees(radians: SPTGetEulerOrientation(selectedObject).rotation[axis.rawValue]))
        case .scale:
            activeValue = Double(SPTGetScale(selectedObject)[axis.rawValue])
        }
    }
    
    func updateObject(_ value: Double) {
        let axis = axes[activeTool.rawValue]
        let selectedObject = sceneViewModel.selectedObject!
        switch activeTool {
        case .move:
            var pos = SPTGetPosition(selectedObject)
            pos[axis.rawValue] = Float(value)
            SPTUpdatePosition(selectedObject, pos)
        case .orient:
            var eulerOrientation = SPTGetEulerOrientation(selectedObject)
            eulerOrientation.rotation[axis.rawValue] = Float(toRadians(degrees: value))
            SPTUpdateEulerOrientation(selectedObject, eulerOrientation)
        case .scale:
            var scale = SPTGetScale(selectedObject)
            scale[axis.rawValue] = Float(value)
            SPTUpdateScale(selectedObject, scale)
        }
    }
    
    static let controlsMargin = 8.0
    static let controlsSpacing = 8.0
    
    enum Tool: Int, CaseIterable, Identifiable {
        
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
    
    struct Toolbar: View {
        
        @Binding var selection: Tool
        
        var body: some View {
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
            .background(Material.bar)
            .compositingGroup()
            .shadow(color: .defaultShadowColor, radius: 0.0, x: 0, y: -0.5)
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
    
}

struct TransformView_Previews: PreviewProvider {
    static var previews: some View {
        TransformView()
    }
}
