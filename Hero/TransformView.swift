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
    @State var activeAxes = [Axis](repeating: .x, count: Tool.allCases.count)
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
            .navigationBarHidden(isNavigating)
        }
        // TODO: Remove when the bug is fixed (Needed to avoid iOS auto-layout warnings on startup)
        .navigationViewStyle(.stack)
        .onChange(of: activeValue) { newValue in
            let axis = activeAxes[activeTool.rawValue]
            let transform = sceneViewModel.selectedObject!.transform!
            switch activeTool {
            case .move:
                transform.position[axis.rawValue] = Float(newValue)
            case .orient:
                transform.rotation[axis.rawValue] = Float(toRadians(degrees: newValue))
            case .scale:
                transform.scale[axis.rawValue] = Float(newValue)
            }
            
        }
        .onReceive(sceneViewModel.objectWillChange) { _ in
            updateActiveValue(tool: activeTool, axis: activeAxes[activeTool.rawValue])
        }
        .onChange(of: activeTool) { newTool in
            updateActiveValue(tool: newTool, axis: activeAxes[newTool.rawValue])
        }
        .onChange(of: activeAxes) { newActiveAxes in
            updateActiveValue(tool: activeTool, axis: newActiveAxes[activeTool.rawValue])
        }
    }
    
    var controls: some View {
        VStack(spacing: Self.controlsSpacing) {
            FloatSelector(value: $activeValue, formatter: formatter, formatterSubjectProvider: formatterSubjectProvider)
            PropertySelector(selected: $activeAxes[activeTool.rawValue])
        }
    }
    
    var formatter: Formatter {
        switch activeTool {
        case .move:
            let positionFormatter = NumberFormatter()
            positionFormatter.numberStyle = .decimal
            positionFormatter.maximumFractionDigits = 2
            return positionFormatter
        case .orient:
            let rotationFormatter = MeasurementFormatter()
            rotationFormatter.unitStyle = .short
            rotationFormatter.numberFormatter.maximumFractionDigits = 2
            return rotationFormatter
        case .scale:
            let scaleFormatter = NumberFormatter()
            scaleFormatter.numberStyle = .decimal
            scaleFormatter.maximumFractionDigits = 2
            return scaleFormatter
        }
    }
    
    var formatterSubjectProvider: FloatSelector.FormatterSubjectProvider {
        switch activeTool {
        case .move:
            return { value in
                NSNumber(value: value)
            }
        case .orient:
            return { value in
                Measurement<UnitAngle>(value: value, unit: .degrees) as NSObject
            }
        case .scale:
            return { value in
                NSNumber(value: value)
            }
        }
    }
    
    func updateActiveValue(tool: Tool, axis: Axis) {
        let transform = sceneViewModel.selectedObject!.transform!
        switch tool {
        case .move:
            activeValue = Double(transform.position[axis.rawValue])
        case .orient:
            activeValue = Double(toDegrees(radians: transform.rotation[axis.rawValue]))
        case .scale:
            activeValue = Double(transform.scale[axis.rawValue])
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
