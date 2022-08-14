//
//  SPTObjectBinding.swift
//  Hero
//
//  Created by Vanush Grigoryan on 15.02.22.
//

import Foundation
import Combine


@propertyWrapper
@dynamicMemberLookup
class SPTObjectBinding<Object> where Object: Equatable {
    
    private var value: Object
    private let setter: (Object) -> Void
    
    typealias Listener = (binding: WeakWrapper, callback: (Object) -> Void)
    private var listeners = [Listener]()
    
    weak var publisher: ObservableObjectPublisher?
    
    init(value: Object, setter: @escaping (Object) -> Void) {
        self.value = value
        self.setter = setter
    }
    
    var wrappedValue: Object {
        set { setter(newValue) }
        get { value }
    }
    
    var projectedValue: SPTObjectBinding<Object> {
        self
    }
    
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Object, Subject>) -> SPTObjectBinding<Subject> {
        let binding = SPTObjectBinding<Subject>(value: value[keyPath: keyPath]) { newValue in
            var updatedValue = self.value
            updatedValue[keyPath: keyPath] = newValue
            self.setter(updatedValue)
        }
        
        let callback = { [weak weakBinding = binding] (newValue: Object) in
            if let binding = weakBinding {
                binding.onWillChange(newValue: newValue[keyPath: keyPath])
            }
        }

        listeners.append((binding: WeakWrapper(value: binding), callback: callback))
        
        return binding
    }
 
    func onWillChange(newValue: Object) {
        
        guard newValue != value else { return }
        
        publisher?.send()
        
        for listener in listeners {
            listener.callback(newValue)
        }
        listeners.removeAll { $0.binding.value == nil }
        
        value = newValue
    }
    
    struct WeakWrapper {
        private(set) weak var value: AnyObject?
    }
    
}


// TODO: Remove
protocol SPTObservedObject {
    
    associatedtype Object: Equatable
    
    var binding: SPTObjectBinding<Object> { get }

}


extension SPTObservedObject {
    
    var publisher: ObservableObjectPublisher? {
        set { binding.publisher = newValue }
        get { binding.publisher }
    }
    
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Object, Subject>) -> SPTObjectBinding<Subject> {
        binding[dynamicMember: keyPath]
    }
    
}
