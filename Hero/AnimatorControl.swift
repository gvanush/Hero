//
//  AnimatorControl.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.10.22.
//

import SwiftUI

struct AnimatorControl: View {
    
    @Binding var animatorId: SPTAnimatorId
    @State private var showsAnimatorSelector = false
    
    var body: some View {
        HStack {
            Text(SPTAnimatorGet(animatorId).name)
                .foregroundColor(.controlValue)
            Spacer()
            Button {
                showsAnimatorSelector = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
            }
            .tint(Color.objectSelectionColor)

        }
        .sheet(isPresented: $showsAnimatorSelector) {
            AnimatorSelector { animatorId in
                if let animatorId = animatorId {
                    self.animatorId = animatorId
                }
                showsAnimatorSelector = false
            }
        }
        .padding(Self.padding)
        .frame(height: Self.height)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
    }
    
    static let padding = 8.0
    static let height = 50.0
    static let cornerRadius = 11.0
}

struct AnimatorControl_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State var animatorId: SPTAnimatorId
        
        init(animatorId: SPTAnimatorId) {
            self.animatorId = animatorId
        }
        
        var body: some View {
            ZStack {
                Color.lightGray
                AnimatorControl(animatorId: $animatorId)
                    .padding()
            }
        }
    }
    
    static var previews: some View {
        
        let id1 = SPTAnimatorMake(.init(name: "TestAnimator1", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))
        SPTAnimatorMake(.init(name: "TestAnimator2", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))
        SPTAnimatorMake(.init(name: "TestAnimator3", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))
        
        return ContentView(animatorId: id1)
    }
}
