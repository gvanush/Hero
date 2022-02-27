//
//  EditScaleComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import SwiftUI


struct EditScaleComponentView: View {
    
    @ObservedObject var component: ScaleComponent
    @State private var scale = FloatField.Scale._0_1
    
    var body: some View {
        if let axis = component.selectedProperty {
            FloatField(value: $component.value[axis.rawValue], scale: $scale)
                .id(axis.rawValue)
        }
    }
}
