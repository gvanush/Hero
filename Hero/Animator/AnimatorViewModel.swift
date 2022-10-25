//
//  AnimatorViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.10.22.
//

import Foundation


class AnimatorViewModel: ObservableObject {
    
    @SPTObservedAnimator var animator: SPTAnimator
    @Published var restartFlag = false
    
    init(animatorId: SPTAnimatorId) {
        _animator = .init(id: animatorId)
        _animator.publisher = self.objectWillChange
    }
    
    var animatorId: SPTAnimatorId {
        _animator.id
    }
    
    var name: String {
        animator.name.capitalizingFirstLetter()
    }
    
    func getAnimatorValue(context: SPTAnimatorEvaluationContext) -> Float? {
        // TODO: @Vanush
        if isAlive {
            return SPTAnimator.evaluateValue(id: _animator.id, context: context)
        }
        return nil
    }
    
    func destroy() {
        SPTAnimator.destroy(id: _animator.id)
    }
    
    var isAlive: Bool {
        SPTAnimator.exists(id: animatorId)
    }
    
    func resetAnimator() {
        SPTAnimator.reset(id: _animator.id)
    }
}
