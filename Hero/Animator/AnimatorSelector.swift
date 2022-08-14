//
//  AnimatorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 13.08.22.
//

import SwiftUI


struct AnimatorSelector: View {
    
    let onSelected: (SPTAnimatorId) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            List(SPTAnimatorGetAll()) { animator in
                HStack {
                    Text(animator.name.capitalizingFirstLetter())
                    Spacer()
                    Button("Select") {
                        onSelected(animator.id)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Select Animator")
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

struct AnimatorSelector_Previews: PreviewProvider {
    static var previews: some View {
        AnimatorSelector { _ in }
    }
}
