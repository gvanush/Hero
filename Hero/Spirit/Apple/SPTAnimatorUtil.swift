//
//  SPTAnimatorUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 19.07.22.
//

import Foundation
import Combine

extension SPTAnimatorId: Identifiable, Hashable {
    
    public var id: Self.RawValue {
        self.rawValue
    }
    
}

extension SPTAnimatorIdSlice: SPTArraySlice {

    public typealias Element = SPTAnimatorId

}

extension SPTAnimatorSource {
    
    init(panWithAxis axis: SPTPanAnimatorSourceAxis, bottomLeft: simd_float2 , topRight: simd_float2) {
        self.init(type: .pan, .init(pan: .init(bottomLeft: bottomLeft, topRight: topRight, axis: axis)))
    }
    
    init(randomWithSeed seed: UInt32, frequency: Float) {
        self.init(type: .random, .init(random: .init(seed: seed, frequency: frequency)))
    }
    
    init(noiseWithType type: SPTNoiseType, seed: UInt32, frequency: Float, interpolation: SPTEasingType) {
        self.init(type: .noise, .init(noise: .init(type: type, seed: seed, frequency: frequency, interpolation: interpolation)))
    }
    
    init(oscillatorWithFrequency frequency: Float, interpolation: SPTEasingType) {
        self.init(type: .oscillator, .init(oscillator: .init(frequency: frequency, interpolation: interpolation)))
    }
}

extension SPTAnimator: Equatable {
    
    init(name: String, source: SPTAnimatorSource) {
        self.init()
        self.source = source
        self.name = name
    }
    
    var name: String {
        get {
            withUnsafePointer(to: _name, { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: Int(kSPTAnimatorNameMaxLength) + 1) { charPtr in
                    String(cString: charPtr)
                }
            })
        }
        set {
            withUnsafeMutablePointer(to: &_name) { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: Int(kSPTAnimatorNameMaxLength) + 1) { charPtr in
                    newValue.utf8CString.withUnsafeBufferPointer { sourceCharPtr in
                        let length = min(sourceCharPtr.count, Int(kSPTAnimatorNameMaxLength))
                        charPtr.update(from: sourceCharPtr.baseAddress!, count: length)
                        charPtr[length] = 0
                    }
                }
            }
        }
    }
    
    public static func == (lhs: SPTAnimator, rhs: SPTAnimator) -> Bool {
        SPTAnimatorEqual(lhs, rhs)
    }
    
    static func make(_ animator: SPTAnimator) -> SPTAnimatorId {
        SPTAnimatorMake(animator)
    }
    
    static func update(_ animator: SPTAnimator, id: SPTAnimatorId) {
        SPTAnimatorUpdate(id, animator)
    }
    
    static func destroy(id: SPTAnimatorId) {
        SPTAnimatorDestroy(id)
    }
    
    static func get(id: SPTAnimatorId) -> SPTAnimator {
        SPTAnimatorGet(id)
    }
    
    static func getAllIds() -> SPTAnimatorIdSlice {
        SPTAnimatorGetAllIds()
    }
    
    static func exists(id: SPTAnimatorId) -> Bool {
        SPTAnimatorExists(id)
    }
    
    typealias WillChangeCallback = (SPTAnimator) -> Void
    typealias WillChangeSubscription = SPTSubscription<WillChangeCallback>
    
    static func onWillChangeSink(id: SPTAnimatorId, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTAnimatorAddWillChangeObserver(id, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTAnimatorRemoveWillChangeObserver(id, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func getCount() -> Int {
        SPTAnimatorGetCount()
    }
    
    typealias CountWillChangeCallback = (Int) -> Void
    typealias CountWillChangeSubscription = SPTSubscription<CountWillChangeCallback>
    
    static func onCountWillChangeSink(callback: @escaping CountWillChangeCallback) -> SPTAnySubscription {
        
        let subscription = CountWillChangeSubscription(observer: callback)
        
        let token = SPTAnimatorAddCountWillChangeObserver({ newValue, userInfo in
            let subscription = Unmanaged<CountWillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTAnimatorRemoveCountWillChangeObserver(token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func evaluateValue(id: SPTAnimatorId, context: SPTAnimatorEvaluationContext) -> Float {
        SPTAnimatorEvaluateValue(id, context)
    }
    
    static func reset(id: SPTAnimatorId) {
        SPTAnimatorReset(id)
    }
    
    static func resetAll() {
        SPTAnimatorResetAll()
    }
    
}

@propertyWrapper
class SPTObservedAnimator {
    
    let id: SPTAnimatorId
    var willChangeSubscription: SPTAnySubscription?
    
    weak var publisher: ObservableObjectPublisher?
    
    init(id: SPTAnimatorId) {
        self.id = id
        
        willChangeSubscription = SPTAnimator.onWillChangeSink(id: id) { [weak self] newValue in
            self?.publisher?.send()
        }
        
    }
 
    var wrappedValue: SPTAnimator {
        set { SPTAnimator.update(newValue, id: id) }
        get { SPTAnimator.get(id: id) }
    }
    
}
