//
//  SPTOrientationUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


extension SPTOrientation: SPTObservableComponent {
    
    init(eulerX x: Float, y: Float, z: Float) {
        self.init(eulerXYZ: .init(x: x, y: y, z: z))
    }
    
    init(eulerXYZ euler: simd_float3) {
        self.init(model: .eulerXYZ, .init(euler: euler))
    }
    
    init(eulerX x: Float, z: Float, y: Float) {
        self.init(eulerXZY: .init(x: x, y: y, z: z))
    }
    
    init(eulerXZY euler: simd_float3) {
        self.init(model: .eulerXZY, .init(euler: euler))
    }
    
    init(eulerY y: Float, x: Float, z: Float) {
        self.init(eulerYXZ: .init(x: x, y: y, z: z))
    }
    
    init(eulerYXZ euler: simd_float3) {
        self.init(model: .eulerYXZ, .init(euler: euler))
    }
    
    init(eulerY y: Float, z: Float, x: Float) {
        self.init(eulerYZX: .init(x: x, y: y, z: z))
    }
    
    init(eulerYZX euler: simd_float3) {
        self.init(model: .eulerYZX, .init(euler: euler))
    }
    
    init(eulerZ z: Float, x: Float, y: Float) {
        self.init(eulerZXY: .init(x: x, y: y, z: z))
    }
    
    init(eulerZXY euler: simd_float3) {
        self.init(model: .eulerZXY, .init(euler: euler))
    }
    
    init(eulerZ z: Float, y: Float, x: Float) {
        self.init(eulerZYX: .init(x: x, y: y, z: z))
    }
    
    init(eulerZYX euler: simd_float3) {
        self.init(model: .eulerZYX, .init(euler: euler))
    }
    
    init(direction: simd_float3, axis: SPTAxis, angle: Float) {
        self.init(model: .pointAtDirection, .init(pointAtDirection: .init(direction: direction, axis: axis, angle: angle)))
    }
    
    init(target: simd_float3, up: simd_float3, axis: SPTAxis, positive: Bool = true) {
        self.init(lookAtPoint: .init(target: target, up: up, axis: axis, positive: positive))
    }
    
    init(lookAtPoint: SPTLookAtPointOrientation) {
        self.init(model: .lookAtPoint, .init(lookAtPoint: lookAtPoint))
    }
    
    init(normDirection: simd_float3, up: simd_float3, axis: SPTAxis, positive: Bool = true) {
        self.init(lookAtDirection: .init(normDirection: normDirection, up: up, axis: axis, positive: positive))
    }
    
    init(lookAtDirection: SPTLookAtDirectionOrientation) {
        self.init(model: .lookAtDirection, .init(lookAtDirection: lookAtDirection))
    }
    
    init(orthoNormX: simd_float3, orthoNormY: simd_float3) {
        self.init(xyAxes: .init(orthoNormX: orthoNormX, orthoNormY: orthoNormY))
    }
    
    init(xyAxes: SPTXYAxesOrientation) {
        self.init(model: .xyAxis, .init(xyAxes: xyAxes))
    }
    
    init(orthoNormY: simd_float3, orthoNormZ: simd_float3) {
        self.init(yzAxes: .init(orthoNormY: orthoNormY, orthoNormZ: orthoNormZ))
    }
    
    init(yzAxes: SPTYZAxesOrientation) {
        self.init(model: .yzAxis, .init(yzAxes: yzAxes))
    }
    
    init(orthoNormZ: simd_float3, orthoNormX: simd_float3) {
        self.init(zxAxes: .init(orthoNormZ: orthoNormZ, orthoNormX: orthoNormX))
    }
    
    init(zxAxes: SPTZXAxesOrientation) {
        self.init(model: .zxAxis, .init(zxAxes: zxAxes))
    }
    
    public static func == (lhs: SPTOrientation, rhs: SPTOrientation) -> Bool {
        SPTOrientationEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTOrientation, object: SPTObject) {
        SPTOrientationMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTOrientation, object: SPTObject) {
        if SPTOrientationExists(object) {
            SPTOrientationUpdate(object, component)
        } else {
            SPTOrientationMake(object, component)
        }
    }
    
    static func update(_ component: SPTOrientation, object: SPTObject) {
        SPTOrientationUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTOrientationDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTOrientation {
        SPTOrientationGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTOrientation? {
        SPTOrientationTryGet(object)?.pointee
    }
    
    var toEulerXYZ: SPTOrientation {
        SPTOrientationToEulerXYZ(self)
    }
    
    var toEulerXZY: SPTOrientation {
        SPTOrientationToEulerXZY(self)
    }
    
    var toEulerYXZ: SPTOrientation {
        SPTOrientationToEulerYXZ(self)
    }
    
    var toEulerYZX: SPTOrientation {
        SPTOrientationToEulerYZX(self)
    }
    
    var toEulerZXY: SPTOrientation {
        SPTOrientationToEulerZXY(self)
    }
    
    var toEulerZYX: SPTOrientation {
        SPTOrientationToEulerZYX(self)
    }
    
    func toPointAtDirection(axis: SPTAxis, directionLength: Float = 1.0) -> SPTOrientation {
        SPTOrientationToPointAtDirection(self, axis, directionLength)
    }
    
    static func onDidEmergeSink(object: SPTObject, callback: @escaping DidEmergeCallback) -> SPTAnySubscription {
        
        let subscription = DidEmergeSubscription(observer: callback)
        
        let token = SPTOrientationAddDidEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveDidEmergeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTOrientationAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveWillChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onDidChangeSink(object: SPTObject, callback: @escaping DidChangeCallback) -> SPTAnySubscription {
        
        let subscription = DidChangeSubscription(observer: callback)
        
        let token = SPTOrientationAddDidChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveDidChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTOrientationAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveWillPerishObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
}
