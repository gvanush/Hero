//
//  BasicToolElementActionViewPlaceholder.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.05.23.
//

import SwiftUI

struct BasicToolElementActionViewPlaceholder: View {
    
    let object: SPTObject
    
    @EnvironmentObject private var model: BasicToolModel
    
    var body: some View {
        if let namespace = model[object].disclosedElementsData?.last?.namespace {
            Color.clear
                .frame(height: 75.0)
                .matchedGeometryEffect(id: elementActionViewMatchedGeometryID, in: namespace, properties: .frame)
        }
    }
}
