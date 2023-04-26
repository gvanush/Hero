//
//  CompositeElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


struct CompositeElement<C>: Element
where C: Element {
    
    let title: String
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    var content: C
    
    @Namespace var namespace
    
    init(title: String, @ElementBuilder content: () -> C) {
        self.title = title
        self.content = content()
    }
    
    var faceView: some View {
        Text(title)
            .font(.callout)
            .overlay {
                VStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .imageScale(.small)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 1.0)
                .padding(.bottom, -3.0)
            }
    }
    
}
