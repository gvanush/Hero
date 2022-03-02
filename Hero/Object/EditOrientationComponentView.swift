//
//  EditOrientationComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import SwiftUI

struct EditOrientationComponentView: View {
    
    @ObservedObject var component: OrientationComponent
    @State private var scale = FloatField.Scale._10
    
    var body: some View {
        if let axis = component.selectedProperty {
            FloatField(value: $component.value[axis.rawValue], scale: $scale, measurementFormatter: .angleFormatter, formatterSubjectProvider: MeasurementFormatter.angleSubjectProvider)
                .transition(.identity)
                .id(axis.rawValue)
        }
    }
}
