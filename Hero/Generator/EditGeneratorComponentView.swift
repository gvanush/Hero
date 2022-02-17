//
//  EditGeneratorComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.02.22.
//

import SwiftUI

struct EditGeneratorComponentView: View {
    
    @ObservedObject var component: GeneratorComponent
    
    var body: some View {
        IntegerField(value: $component.quantity, range: kSPTGeneratorMinQuantity...kSPTGeneratorMaxQuantity, deltaOptions: [1, 5, 10, 100])
    }
}


struct EditArrangementComponentView: View {
    
    @ObservedObject var component: ArrangementComponent
    
    var body: some View {
        switch component.variantTag {
        case .point:
            EmptyView()
        case .linear:
            PropertyValueSelector(selected: $component.linear.axis)
        case .planar:
            EmptyView()
        case .spatial:
            EmptyView()
        }
    }
}
