//
//  ViewModifiers.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/30/20.
//

import SwiftUI

struct MinTappableFrame: ViewModifier {
    
    private let alignemnt: Alignment
    
    init(alignment: Alignment) {
        self.alignemnt = alignment
    }
    
    func body(content: Content) -> some View {
        content.frame(minWidth: (alignemnt.horizontal == .center ? 44 : nil), idealWidth: nil, maxWidth: nil, minHeight: (alignemnt.vertical == .center ? 44 : nil), idealHeight: nil, maxHeight: nil, alignment: alignemnt)
    }
    
}

extension View {
    func minTappableFrame(alignment: Alignment) -> some View {
        self.modifier(MinTappableFrame(alignment: alignment))
    }
}

struct AnimationCompletionModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    private var targetValue: Value
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        DispatchQueue.main.async {
            self.completion()
        }
    }

    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionModifier<Value>> {
        modifier(AnimationCompletionModifier(observedValue: value, completion: completion))
    }
}
