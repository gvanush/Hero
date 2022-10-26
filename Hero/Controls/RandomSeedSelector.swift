//
//  RandomSeedSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 21.10.22.
//

import SwiftUI


struct RandomSeedSelector: View {
    
    @Binding var seed: UInt32
    
    var body: some View {
        HStack {
            Button {
            } label: {
                Image(systemName: "keyboard")
                    .imageScale(.large)
                    .frame(width: 44.0, height: 44.0)
            }
            .hidden()
            Spacer()
            Text(seed, format: .number)
                .foregroundColor(.controlValue)
            Spacer()
            Button {
                seed = .randomInFullRange()
            } label: {
                Image(systemName: "arrow.2.squarepath")
                    .imageScale(.large)
                    .frame(width: 44.0, height: 44.0)
            }

        }
        .padding(Self.padding)
        .frame(maxWidth: .infinity)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
    }
    
    static let padding = 4.0
    static let cornerRadius = 11.0
}

struct RandomSeedSelector_Previews: PreviewProvider {
    
    struct ContentView: View {
        
        @State var seed: UInt32 = 1
        
        var body: some View {
            RandomSeedSelector(seed: $seed)
                .padding()
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
