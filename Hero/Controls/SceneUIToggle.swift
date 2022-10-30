//
//  SceneUIToggle.swift
//  Hero
//
//  Created by Vanush Grigoryan on 15.09.22.
//

import SwiftUI


struct SceneUIToggle: View {
    
    @Binding var isOn: Bool?
    let offStateIconName: String
    let onStateIconName: String
    
    var body: some View {
        Button {
            isOn?.toggle()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 9.0)
                    .fill(.shadow(.inner(radius: 2.0)))
                    .foregroundColor(Color.systemFill)
                    .padding(3.0)
                    .visible(isOn ?? false)
                Image(systemName: isOn ?? false ? onStateIconName : offStateIconName)
                    .imageScale(.medium)
                    .tint(.primary)
            }
            .frame(width: SceneViewConst.uiButtonSize, height: SceneViewConst.uiButtonSize, alignment: .center)
        }
        .background(SceneViewConst.uiBgrMaterial, ignoresSafeAreaEdges: [])
        .cornerRadius(12.0)
        .shadow(radius: 1.0)
        .disabled(isOn == nil)
    }
    
}
