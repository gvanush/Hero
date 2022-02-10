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
        IntegerField(value: $component.quantity, range: kSPTGeneratorMinQuantity...kSPTGeneratorMaxQuantity)
    }
}
