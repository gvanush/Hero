//
//  ObjectHSBColorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.05.23.
//

import SwiftUI


struct ObjectHSBColorSelector: View {
    
    let channel: HSBColorChannel
    @Binding var value: SPTHSBAColor
    
    @EnvironmentObject private var userInteractionState: UserInteractionState
    
    var body: some View {
        HSBColorSelector(hsbaColor: $value, channel: channel) { isEditing in
            userInteractionState.isEditing = isEditing
        }
    }
}
