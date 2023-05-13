//
//  ObjectHierarchyView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.04.23.
//

import SwiftUI


struct ObjectHierarchyView: View {
    var body: some View {
        Form {
            DisclosureGroup {
                Button("Object 5") {
                    
                }
            } label: {
                Button("Object 1") {
                    
                }
            }

            Button("Object 2") {
                
            }
        }
    }
}


struct ObjectHierarchyView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectHierarchyView()
    }
}
