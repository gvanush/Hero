//
//  EditPositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import SwiftUI

struct EditPositionComponentView: View {
    
    @ObservedObject var component: PositionComponent
    @State private var scale = FloatField.Scale._1
    
    var body: some View {
        if let axis = component.selectedProperty {
            FloatField(value: $component.value[axis.rawValue], scale: $scale)
                .id(axis.rawValue)
        }
    }
}
