//
//  UserObject.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.05.23.
//

import Foundation
import UIKit
import Combine


enum UserObjectCategory: Int32 {
    case mesh
}

protocol UserObject<S>: LocatableObject, OrientableObject, ScalableObject, RayCastableObject {
    
    var name: String { get set }
 
    var category: UserObjectCategory { get }
    
    var _parent: (any UserObject<S>)? { get set }
    
    var _children: [any UserObject<S>] { get set }
    
    func clone() -> Self
    
}

extension UserObject where S == MainScene {
    
    func _buildUserObject(position: simd_float3 = .zero, scale: Float = 1.0) {
        _buildLocatableObject(position: .init(cartesian: position))
        _buildOrientableObject()
        _buildScalableObject(scale: .init(uniform: scale))
        _buildRayCastableObject();
    }
    
    func _cloneUserObject(original: SPTObject) {
        _cloneLocatableObject(original: original)
        _cloneOrientableObject(original: original)
        _cloneScalableObject(original: original)
        _cloneRayCastableObject(original: original)
    }
    
    var parent: (any UserObject<S>)? {
        get {
            _parent
        }
        set {
            guard parent !== newValue else {
                return
            }
            
            transformationParent = newValue
            
            if let parent {
                parent._children.removeAll { $0 === self }
            } else {
                scene._removeRootUserObject(self)
            }
            
            if let newParent = newValue {
                newParent._children.append(self)
            } else {
                scene._addRootUserObject(self)
            }
        }
    }
    
    var children: [any UserObject<S>] {
        _children
    }
    
    func die() {
        if let parent {
            parent.objectWillChange.send()
            parent._children.removeAll { $0 === self }
        } else {
            scene._removeRootUserObject(self)
        }
        guard scene._destroyObject(self) else {
            fatalError()
        }
    }
    
    var _isSelected: Bool {
        get {
            SPTOutlineLookExists(sptObject)
        }
        set {
            if newValue {
                SPTOutlineLook.make(.init(color: UIColor.primarySelectionColor.rgba, thickness: 5.0, categories: LookCategories.guide.rawValue), object: sptObject)
            } else {
                SPTOutlineLook.destroy(object: sptObject)
            }
        }
    }
    
    var isSelected: Bool {
        _isSelected
    }
    
}


// Note: This needs to be removed when existential 'any' supports conformance to protocol
@propertyWrapper
@dynamicMemberLookup
class ObservableAnyUserObject: ObservableObject {
    
    var wrappedValue: any UserObject
    var cancellable: AnyCancellable?
    
    init(wrappedValue: any UserObject) {
        self.wrappedValue = wrappedValue
        self.cancellable = wrappedValue.objectWillChange.sink(receiveValue: { [unowned self] in
            self.objectWillChange.send()
        })
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<any UserObject, T>) -> T {
        get {
            wrappedValue[keyPath: keyPath]
        }
        set {
            // This is necessary to prevent simultaneous access to 'wrappedValue'
            self.objectWillChange.send()
            
            wrappedValue[keyPath: keyPath] = newValue
        }
    }
    
}
