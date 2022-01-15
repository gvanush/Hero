//
//  TemplateObjectSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 15.01.22.
//

import SwiftUI

struct TemplateObjectSelector: View {
    
    let onSelected: (MeshRecord) -> Void
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            List(sceneViewModel.meshRecords) { record in
                HStack {
                    Image(systemName: record.iconName)
                    Text(record.name.capitalizingFirstLetter())
                    Spacer()
                    Button("Select") {
                        onSelected(record)
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
