//
//  ObjectRGBColorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.05.23.
//

import SwiftUI


struct ObjectRGBColorSelector: View {
    
    let channel: RGBColorChannel
    @Binding var value: SPTRGBAColor
    
    @EnvironmentObject private var userInteractionState: UserInteractionState
    
    var body: some View {
        RGBColorSelector(rgbaColor: $value, channel: channel) { isEditing in
            userInteractionState.isEditing = isEditing
        }
    }
}
