//
//  AnimatorBindingOptionsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.05.23.
//

import SwiftUI



struct AnimatorBindingOptionsView<P>: View
where P: SPTAnimatableProperty {
    
    let property: P
    let object: SPTObject
    
    @State private var showsAnimatorSelector = false
    
    var body: some View {
        Menu {
            Button {
                showsAnimatorSelector = true
            } label: {
                HStack {
                    Text("Edit")
                    Spacer()
                    Image(systemName: "bolt")
                        .imageScale(.small)
                }
            }
            Button {
                property.unbindAnimator(object: object)
            } label: {
                HStack {
                    Text("Unbind")
                    Spacer()
                    Image(systemName: "bolt.slash")
                        .imageScale(.small)
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .imageScale(.medium)
        }
        .buttonStyle(.bordered)
        .shadow(radius: 0.5)
        .sheet(isPresented: $showsAnimatorSelector) {
            AnimatorSelector { animatorId in
                if let animatorId {
                    var binding = property.getAnimatorBinding(object: object)
                    binding.animatorId = animatorId
                    property.updateAnimatorBinding(binding, object: object)
                }
                showsAnimatorSelector = false
            }
        }
    }
    
}
