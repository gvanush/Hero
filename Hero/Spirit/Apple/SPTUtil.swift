//
//  Util.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.08.22.
//

import Foundation


typealias ObjectDidEmergeCallback<O> = (O) -> Void
typealias ObjectWillChangeCallback<O> = (O) -> Void
typealias ObjectDidChangeCallback<O> = (O) -> Void
typealias ObjectWillPerishCallback = () -> Void

protocol SPTComponent: Equatable {
    
    static func make(_ component: Self, object: SPTObject)
    
    static func makeOrUpdate(_ component: Self, object: SPTObject)
    
    static func update(_ component: Self, object: SPTObject)
    
    static func destroy(object: SPTObject)
    
    static func get(object: SPTObject) -> Self
    
    static func tryGet(object: SPTObject) -> Self?
    
}

protocol SPTObservableComponent: SPTComponent {
    
    typealias DidEmergeCallback = ObjectDidEmergeCallback<Self>
    typealias DidEmergeSubscription = SPTSubscription<DidEmergeCallback>
    
    typealias WillChangeCallback = ObjectWillChangeCallback<Self>
    typealias WillChangeSubscription = SPTSubscription<WillChangeCallback>
    
    typealias DidChangeCallback = ObjectDidChangeCallback<Self>
    typealias DidChangeSubscription = SPTSubscription<DidChangeCallback>
    
    typealias WillPerishCallback = ObjectWillPerishCallback
    typealias WillPerishSubscription = SPTSubscription<WillPerishCallback>
    
    static func onDidEmergeSink(object: SPTObject, callback: @escaping DidEmergeCallback) -> SPTAnySubscription
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription
    
    static func onDidChangeSink(object: SPTObject, callback: @escaping DidChangeCallback) -> SPTAnySubscription
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription
    
}


protocol SPTAnimatableProperty: Identifiable {
    
    typealias AnimatorBindingDidEmergeCallback = ObjectDidEmergeCallback<SPTAnimatorBinding>
    typealias AnimatorBindingDidEmergeSubscription = SPTSubscription<AnimatorBindingDidEmergeCallback>
    
    typealias AnimatorBindingWillChangeCallback = ObjectWillChangeCallback<SPTAnimatorBinding>
    typealias AnimatorBindingWillChangeSubscription = SPTSubscription<AnimatorBindingWillChangeCallback>
    
    typealias AnimatorBindingDidChangeCallback = ObjectDidChangeCallback<SPTAnimatorBinding>
    typealias AnimatorBindingDidChangeSubscription = SPTSubscription<AnimatorBindingDidChangeCallback>
    
    typealias AnimatorBindingWillPerishCallback = ObjectWillPerishCallback
    typealias AnimatorBindingWillPerishSubscription = SPTSubscription<AnimatorBindingWillPerishCallback>
    
    func bind(_ binding: SPTAnimatorBinding, object: SPTObject)
    
    func bindOrUpdate(_ binding: SPTAnimatorBinding, object: SPTObject)
    
    func updateAnimatorBinding(_ binding: SPTAnimatorBinding, object: SPTObject)
    
    func unbindAnimator(object: SPTObject)
    
    func getAnimatorBinding(object: SPTObject) -> SPTAnimatorBinding
    
    func tryGetAnimatorBinding(object: SPTObject) -> SPTAnimatorBinding?
    
    func isAnimatorBound(object: SPTObject) -> Bool
    
    func onAnimatorBindingDidEmergeSink(object: SPTObject, callback: @escaping AnimatorBindingDidEmergeCallback) -> SPTAnySubscription
    
    func onAnimatorBindingWillChangeSink(object: SPTObject, callback: @escaping AnimatorBindingWillChangeCallback) -> SPTAnySubscription
    
    func onAnimatorBindingDidChangeSink(object: SPTObject, callback: @escaping AnimatorBindingDidChangeCallback) -> SPTAnySubscription
 
    func onAnimatorBindingWillPerishSink(object: SPTObject, callback: @escaping AnimatorBindingWillPerishCallback) -> SPTAnySubscription
}
