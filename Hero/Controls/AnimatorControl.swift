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
            Text(SPTAnimator.get(id: animatorId).name)
                .foregroundColor(.controlValue)
            Spacer()
            Button {
                showsAnimatorSelector = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
            }
        }
        .sheet(isPresented: $showsAnimatorSelector) {
            AnimatorSelector { animatorId in
                if let animatorId = animatorId {
                    self.animatorId = animatorId
                }
                showsAnimatorSelector = false
            }
            .tint(Color.accentColor)
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
        let id1 = SPTAnimator.make(.init(name: "TestAnimator.1", source: .init(panWithAxis: .horizontal, bottomLeft: .zero, topRight: .one)))
        _ = SPTAnimator.make(.init(name: "TestAnimator.2", source: .init(panWithAxis: .horizontal, bottomLeft: .zero, topRight: .one)))
        _ = SPTAnimator.make(.init(name: "TestAnimator.3", source: .init(panWithAxis: .horizontal, bottomLeft: .zero, topRight: .one)))
        return ContentView(animatorId: id1)
    }
}
