//
//  TemplateObjectSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 15.01.22.
//

import SwiftUI

struct TemplateObjectSelector: View {
    
    let onSelected: (SPTMeshId) -> Void
    @EnvironmentObject private var sceneViewModel: SceneViewModel
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
            .navigationTitle("Select Source Object")
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


struct TemplateObjectSelector_Previews: PreviewProvider {
    static var previews: some View {
        TemplateObjectSelector(onSelected: { _ in
        })
            .environmentObject(SceneViewModel())
    }
}
