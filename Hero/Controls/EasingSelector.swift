//
//  EasingSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.22.
//

import SwiftUI

struct EasingTypeSelector: View {
    
    @Binding var easing: SPTEasingType
    
    var body: some View {
        Menu {
            itemForType(.smoothStep)
            itemForType(.smootherStep)
            itemForType(.linear)
        } label: {
            Image(systemName: "square.and.pencil")
                .imageScale(.large)
        }
    }
    
    func itemForType(_ type: SPTEasingType) -> some View {
        Button(type.displayName) {
            easing = type
        }
    }
    
}

struct EasingSelector: View {
    
    @Binding var easing: SPTEasingType
    
    var body: some View {
        HStack {
            Text(easing.displayName)
                .foregroundColor(.controlValue)
            Spacer()
            EasingTypeSelector(easing: $easing)
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

struct EasingSelector_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State var easing = SPTEasingType.linear
        
        var body: some View {
            EasingSelector(easing: $easing)
                .padding()
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
