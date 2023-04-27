//
//  SPTPositionUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation
import simd


extension SPTPosition: SPTInspectableComponent {
    
    init(cartesian: simd_float3) {
        self.init(coordinateSystem: .cartesian, .init(cartesian: cartesian))
    }
    
    init(x: Float, y: Float, z: Float) {
        self.init(cartesian: .init(x: x, y: y, z: z))
    }
    
    init(linear: SPTLinearCoordinates) {
        self.init(coordinateSystem: .linear, .init(linear: linear))
    }
    
    init(origin: simd_float3, direction: simd_float3, offset: Float) {
        self.init(linear: .init(origin: origin, direction: direction, offset: offset))
    }
    
    init(spherical: SPTSphericalCoordinates) {
        self.init(coordinateSystem: .spherical, .init(spherical: spherical))
    }
    
    init(origin: simd_float3, radius: Float, longitude: Float, latitude: Float) {
        self.init(spherical: .init(origin: origin, radius: radius, longitude: longitude, latitude: latitude))
    }
    
    init(cylindrical: SPTCylindricalCoordinates) {
        self.init(coordinateSystem: .cylindrical, .init(cylindrical: cylindrical))
    }
    
    init(origin: simd_float3, radius: Float, longitude: Float, height: Float) {
        self.init(cylindrical: .init(origin: origin, radius: radius, longitude: longitude, height: height))
    }
    
    var origin: simd_float3 {
        SPTPositionGetOrigin(self)
    }
    
    var toCartesian: SPTPosition {
        SPTPositionToCartesian(self)
    }
    
    func toLinear(origin: simd_float3) -> SPTPosition {
        SPTPositionToLinear(self, origin)
    }
    
    func toSpherical(origin: simd_float3) -> SPTPosition {
        SPTPositionToSpherical(self, origin)
    }
    
    func toCylindrical(origin: simd_float3) -> SPTPosition {
        SPTPositionToCylindrical(self, origin)
    }
    
    public static func == (lhs: SPTPosition, rhs: SPTPosition) -> Bool {
        SPTPositionEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTPosition, object: SPTObject) {
        SPTPositionMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTPosition, object: SPTObject) {
        if SPTPositionExists(object) {
            SPTPositionUpdate(object, component)
        } else {
            SPTPositionMake(object, component)
        }
    }
    
    static func update(_ component: SPTPosition, object: SPTObject) {
        SPTPositionUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTPositionDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTPosition {
        SPTPositionGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTPosition? {
        SPTPositionTryGet(object)?.pointee
    }
    
    static func exists(object: SPTObject) -> Bool {
        SPTPositionExists(object)
    }
    
    static func onDidEmergeSink(object: SPTObject, callback: @escaping DidEmergeCallback) -> SPTAnySubscription {
        
        let subscription = DidEmergeSubscription(observer: callback)
        
        let token = SPTPositionAddDidEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTPositionRemoveDidEmergeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTPositionAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTPositionRemoveWillChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onDidChangeSink(object: SPTObject, callback: @escaping DidChangeCallback) -> SPTAnySubscription {
        
        let subscription = DidChangeSubscription(observer: callback)
        
        let token = SPTPositionAddDidChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTPositionRemoveDidChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTPositionAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTPositionRemoveWillPerishObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
}
