//
//  ObjectBinding.swift
//  Hero
//
//  Created by Vanush Grigoryan on 15.02.22.
//

import Foundation


@propertyWrapper
@dynamicMemberLookup
struct ObjectBinding<ObjectType> {
    
    private let getter: () -> ObjectType
    private let setter: (ObjectType) -> Void
    
    init(getter: @escaping () -> ObjectType, setter: @escaping (ObjectType) -> Void) {
        self.getter = getter
        self.setter = setter
    }
    
    var wrappedValue: ObjectType {
        // 'nonmutating' is a must here otherwise Swift thinks that ObjectBinding
        // is modified and raises exclusive access issues when 'get' is called
        // from within 'set'-s call tree (https://www.swift.org/blog/swift-5-exclusivity/)
        nonmutating set { setter(newValue) }
        get { getter() }
    }
    
    var projectedValue: Self {
        self
    }
    
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<ObjectType, Subject>) -> ObjectBinding<Subject> {
        ObjectBinding<Subject> {
            getter() [keyPath: keyPath]
        } setter: { newValue in
            var object = getter()
            object[keyPath: keyPath] = newValue
            setter(object)
        }

    }
    
}
