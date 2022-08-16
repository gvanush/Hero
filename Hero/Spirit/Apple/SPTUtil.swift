//
//  Util.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.08.22.
//

import Foundation


typealias ObjectWillEmergeCallback<O> = (O) -> Void
typealias ObjectWillChangeCallback<O> = (O) -> Void
typealias ObjectWillPerishCallback = () -> Void


protocol SPTComponent: Equatable {
    
    typealias WillEmergeCallback = ObjectWillEmergeCallback<Self>
    typealias WillEmergeSubscription = SPTSubscription<WillEmergeCallback>
    
    typealias WillChangeCallback = ObjectWillChangeCallback<Self>
    typealias WillChangeSubscription = SPTSubscription<WillChangeCallback>
    
    typealias WillPerishCallback = ObjectWillPerishCallback
    typealias WillPerishSubscription = SPTSubscription<WillPerishCallback>
    
    static func make(_ component: Self, object: SPTObject)
    
    static func makeOrUpdate(_ component: Self, object: SPTObject)
    
    static func update(_ component: Self, object: SPTObject)
    
    static func destroy(object: SPTObject)
    
    static func get(object: SPTObject) -> Self
    
    static func tryGet(object: SPTObject) -> Self?
    
    static func onWillEmergeSink(object: SPTObject, callback: @escaping WillEmergeCallback) -> SPTAnySubscription
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription
    
}


protocol SPTAnimatableProperty {
    
    typealias AnimatorBindingWillEmergeCallback = ObjectWillEmergeCallback<SPTAnimatorBinding>
    typealias AnimatorBindingWillEmergeSubscription = SPTSubscription<AnimatorBindingWillEmergeCallback>
    
    typealias AnimatorBindingWillChangeCallback = ObjectWillChangeCallback<SPTAnimatorBinding>
    typealias AnimatorBindingWillChangeSubscription = SPTSubscription<AnimatorBindingWillChangeCallback>
    
    typealias AnimatorBindingWillPerishCallback = ObjectWillPerishCallback
    typealias AnimatorBindingWillPerishSubscription = SPTSubscription<AnimatorBindingWillPerishCallback>
    
    func bindAnimator(_ binding: SPTAnimatorBinding, object: SPTObject)
    
    func bindOrUpdate(_ binding: SPTAnimatorBinding, object: SPTObject)
    
    func updateAnimatorBinding(_ binding: SPTAnimatorBinding, object: SPTObject)
    
    func unbindAnimator(object: SPTObject)
    
    func getAnimatorBinding(object: SPTObject) -> SPTAnimatorBinding
    
    func tryGetAnimatorBinding(object: SPTObject) -> SPTAnimatorBinding?
    
    func isAnimatorBound(object: SPTObject) -> Bool
    
    func onAnimatorBindingWillEmergeSink(object: SPTObject, callback: @escaping AnimatorBindingWillEmergeCallback) -> SPTAnySubscription
    
    func onAnimatorBindingWillChangeSink(object: SPTObject, callback: @escaping AnimatorBindingWillEmergeCallback) -> SPTAnySubscription
 
    func onAnimatorBindingWillPerishSink(object: SPTObject, callback: @escaping AnimatorBindingWillPerishCallback) -> SPTAnySubscription
}
