//
//  AnimatorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 13.08.22.
//

import SwiftUI


struct AnimatorSelector: View {
    
    let onComplete: (SPTAnimatorId?) -> Void
    
    var body: some View {
        NavigationView {
            List(SPTAnimator.getAllIds()) { animatorId in
                HStack {
                    Text(SPTAnimator.get(id: animatorId).name.capitalizingFirstLetter())
                    Spacer()
                    Button("Select") {
                        onComplete(animatorId)
                    }
                }
            }
            .navigationTitle("Select Animator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onComplete(nil)
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
