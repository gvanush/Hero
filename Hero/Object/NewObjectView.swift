//
//  NewObjectView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.09.22.
//

import SwiftUI

struct NewObjectView: View {
    
    let onSelected: (SPTMeshId) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            List(MeshRegistry.standard.meshRecords) { record in
                HStack {
                    Image(systemName: record.iconName)
                    Text(record.name.capitalizingFirstLetter())
                    Spacer()
                    Button("Select") {
                        onSelected(record.id)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("New Object")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct NewObjectView_Previews: PreviewProvider {
    static var previews: some View {
        NewObjectView() {_ in }
    }
}
