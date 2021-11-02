//
//  AnimationCompletionObserver.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.21.
//

import SwiftUI

struct AnimationCompletionObserver<Value>: AnimatableModifier where Value: VectorArithmetic {

    private let targetValue: Value
    private let completion: () -> Void
    
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }
    
    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    func body(content: Content) -> some View {
        content
    }
    
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        DispatchQueue.main.async {
            self.completion()
        }
    }
}

extension View {
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserver<Value>> {
        return modifier(AnimationCompletionObserver(observedValue: value, completion: completion))
    }
}
