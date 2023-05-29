//
//  BasicToolElementActionViewPlaceholder.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.05.23.
//

import SwiftUI

struct BasicToolElementActionViewPlaceholder: View {
    
    // TODO
    let object: SPTObject
    
    @EnvironmentObject private var model: BasicToolModel
    
    var body: some View {
        if let data = model[object].disclosedElementsData?.last, data.hasActionView {
            Color.clear
                .frame(height: 75.0)
                .matchedGeometryEffect(id: elementActionViewMatchedGeometryID, in: data.namespace, properties: .frame)
        }
    }
}
