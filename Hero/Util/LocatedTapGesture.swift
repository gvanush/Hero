//
//  LcoatedTapGesture.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.10.21.
//

import SwiftUI

struct LocatedTapGesture: Gesture {
    
    let count: Int
    let coordinateSpace: CoordinateSpace
    
    init(count: Int = 1, coordinateSpace: CoordinateSpace = .local) {
        precondition(count > 0, "Count must be greater than or equal to 1.")
        self.count = count
        self.coordinateSpace = coordinateSpace
    }
    
    var body: SimultaneousGesture<TapGesture, DragGesture> {
        SimultaneousGesture(TapGesture(count: count), DragGesture(minimumDistance: 0.0, coordinateSpace: coordinateSpace))
    }
    
    func onEnded(perform action: @escaping (CGPoint) -> Void) -> _EndedGesture<LocatedTapGesture> {
        self.onEnded { (value: Value) -> Void in
            guard value.first != nil else { return }
            guard let location = value.second?.startLocation else { return }
            guard let endLocation = value.second?.location else { return }
            let xRange = ((location.x - Self.displacementTolerance)...(location.x + Self.displacementTolerance))
            let yRange = ((location.y - Self.displacementTolerance)...(location.y + Self.displacementTolerance))
            guard xRange.contains(endLocation.x),
                  yRange.contains(endLocation.y) else {
                return
            }
            action(location)
        }
    }
    
    static let displacementTolerance = 0.0
    
    typealias Value = SimultaneousGesture<TapGesture, DragGesture>.Value
    typealias Body = SimultaneousGesture<TapGesture, DragGesture>
    
}

extension View {
    
    func onLocatedTapGesture(count: Int, coordinateSpace: CoordinateSpace = .local, perform action: @escaping (CGPoint) -> Void) -> some View {
        gesture(LocatedTapGesture(count: count, coordinateSpace: coordinateSpace)
            .onEnded(perform: action)
        )
    }
    
    func onLocatedTapGesture(count: Int, perform action: @escaping (CGPoint) -> Void) -> some View {
        onLocatedTapGesture(count: count, coordinateSpace: .local, perform: action)
    }
    
    func onLocatedTapGesture(perform action: @escaping (CGPoint) -> Void) -> some View {
        onLocatedTapGesture(count: 1, coordinateSpace: .local, perform: action)
    }
    
}
