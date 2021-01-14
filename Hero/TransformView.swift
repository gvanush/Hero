//
//  TransformView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 1/10/21.
//

import SwiftUI

class TransformViewModel: GraphicsSyncViewModel {
    
    let transform: Transform
    let positionFormatter = NumberFormatter()
    let scaleFormatter = NumberFormatter()
    let rotationFormatter = MeasurementFormatter()
    
    init(transform: Transform, graphicsViewModel: GraphicsViewModel) {
        self.transform = transform
        super.init(graphicsViewModel: graphicsViewModel)
        observe(uiRepresentable: transform)
        
        positionFormatter.numberStyle = .decimal
        scaleFormatter.numberStyle = .decimal
        rotationFormatter.unitStyle = .short
    }
    
    func setPosition(_ text: String, at field: Vector3Field) {
        var value = transform.position[field.rawValue]
        if let newValue = positionFormatter.number(from: text) {
            value = newValue.floatValue
        }
        transform.position[field.rawValue] = value
    }
    
    func position(at field: Vector3Field) -> String {
        positionFormatter.string(from: NSNumber(value: transform.position[field.rawValue]))!
    }
    
    func rawPosition(at field: Vector3Field) -> String {
        positionFormatter.usesGroupingSeparator = false
        let result = positionFormatter.string(from: NSNumber(value: transform.position[field.rawValue]))!
        positionFormatter.usesGroupingSeparator = true
        return result
    }
    
    func setRotation(_ text: String, at field: Vector3Field) {
        var angle = transform.rotation[field.rawValue]
        if let newAngle = rotationFormatter.numberFormatter.number(from: text) {
            angle = deg2rad(newAngle.floatValue)
        }
        transform.rotation[field.rawValue] = angle
    }
    
    func rotation(at field: Vector3Field) -> String {
        let angle = rad2deg(transform.rotation[field.rawValue])
        return rotationFormatter.string(from: Measurement<UnitAngle>(value: Double(angle), unit: .degrees))
    }
    
    func rawRotation(at field: Vector3Field) -> String {
        rotationFormatter.numberFormatter.string(from: NSNumber(value: rad2deg(transform.rotation[field.rawValue])))!
    }
    
    func setScale(_ text: String, at field: Vector3Field) {
        var value = transform.scale[field.rawValue]
        if let newValue = scaleFormatter.number(from: text) {
            value = newValue.floatValue
        }
        transform.scale[field.rawValue] = value
    }
    
    func scale(at field: Vector3Field) -> String {
        scaleFormatter.string(from: NSNumber(value: transform.scale[field.rawValue]))!
    }
    
    func rawScale(at field: Vector3Field) -> String {
        scaleFormatter.usesGroupingSeparator = false
        let result = scaleFormatter.string(from: NSNumber(value: transform.scale[field.rawValue]))!
        scaleFormatter.usesGroupingSeparator = true
        return result
    }
    
}

struct PositionFieldView: View {
    
    @State private var text = ""
    let field: Vector3Field
    @EnvironmentObject var model: TransformViewModel
    
    init(field: Vector3Field) {
        self.field = field
    }
    
    var body: some View {
        HStack {
            Text(field.name)
            TextField(field.name, text: $text, onEditingChanged:  { isEditing in
                if isEditing {
                    text = model.rawPosition(at: field)
                } else {
                    model.setPosition(text, at: field)
                    text = model.position(at: field)
                }
            })
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
        }
        .onAppear {
            text = model.position(at: field)
        }
    }
}

struct RotationFieldView: View {
    
    @State private var text = ""
    let field: Vector3Field
    @EnvironmentObject var model: TransformViewModel
    
    init(field: Vector3Field) {
        self.field = field
    }
    
    var body: some View {
        HStack {
            Text(field.name)
            TextField(field.name, text: $text,  onEditingChanged: { isEditing in
                if isEditing {
                    text = model.rawRotation(at: field)
                } else {
                    model.setRotation(text, at: field)
                    text = model.rotation(at: field)
                }
            })
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
        }
        .onAppear {
            text = model.rotation(at: field)
        }
    }
    
}

struct ScaleFieldView: View {
    
    @State private var text = ""
    let field: Vector3Field
    @EnvironmentObject var model: TransformViewModel
    
    init(field: Vector3Field) {
        self.field = field
    }
    
    var body: some View {
        HStack {
            Text(field.name)
            TextField(field.name, text: $text, onEditingChanged:  { isEditing in
                if isEditing {
                    text = model.rawScale(at: field)
                } else {
                    model.setScale(text, at: field)
                    text = model.scale(at: field)
                }
            })
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
        }
        .onAppear {
            text = model.scale(at: field)
        }
    }
}

struct TransformView: View {
    
    @ObservedObject var model: TransformViewModel
    @State var eulerOrder = "xyz"
    
    var body: some View {
        Form {
            Section(header: Text("Position")) {
                PositionFieldView(field: .x)
                PositionFieldView(field: .y)
                PositionFieldView(field: .z)
            }
            
            Section(header: Text("Rotation")) {
                RotationFieldView(field: .x)
                RotationFieldView(field: .y)
                RotationFieldView(field: .z)
            }
            Section {
                Picker("Euler order", selection: $eulerOrder) {
                    Group {
                        Text("xyz").tag("xyz")
                        Text("xyz1").tag("xyz1")
                        Text("xyz2").tag("xyz2")
                        Text("xyz3").tag("xyz3")
                    }
                }
            }
            Section(header: Text("Scale")) {
                ScaleFieldView(field: .x)
                ScaleFieldView(field: .y)
                ScaleFieldView(field: .z)
            }
        }
        .navigationTitle("Transform")
        .environmentObject(model)
    }
}

struct TransformView_Previews: PreviewProvider {
    
    static let graphicsViewModel = GraphicsViewModel(scene: Hero.Scene(), renderer: Renderer.make()!)
    
    static var previews: some View {
        let sceneObject = graphicsViewModel.scene.makeBasicObject()
        TransformView(model: TransformViewModel(transform: sceneObject.transform, graphicsViewModel: graphicsViewModel))
    }
}
