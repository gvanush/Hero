//
//  SPTComponentBinding.swift
//  Hero
//
//  Created by Vanush Grigoryan on 15.02.22.
//

import Foundation
import Combine


protocol SPTObservedComponent {
    
    associatedtype Component: Equatable
    
    var binding: SPTComponentBinding<Component> { get }

}

extension SPTObservedComponent {
    
    var publisher: ObservableObjectPublisher? {
        set { binding.publisher = newValue }
        get { binding.publisher }
    }
    
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Component, Subject>) -> SPTComponentBinding<Subject> {
        binding[dynamicMember: keyPath]
    }
    
}

@propertyWrapper
@dynamicMemberLookup
class SPTComponentBinding<Component> where Component: Equatable {
    
    private var value: Component
    private let setter: (Component) -> Void
    
    typealias Listener = (binding: WeakWrapper, callback: (Component) -> Void)
    private var listeners = [Listener]()
    
    var publisher: ObservableObjectPublisher?
    
    init(value: Component, setter: @escaping (Component) -> Void) {
        self.value = value
        self.setter = setter
    }
    
    var wrappedValue: Component {
        set { setter(newValue) }
        get { value }
    }
    
    var projectedValue: SPTComponentBinding<Component> {
        self
    }
    
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Component, Subject>) -> SPTComponentBinding<Subject> {
        let binding = SPTComponentBinding<Subject>(value: value[keyPath: keyPath]) { newValue in
            var updatedValue = self.value
            updatedValue[keyPath: keyPath] = newValue
            self.setter(updatedValue)
        }
        
        let callback = { [weak weakBinding = binding] (newValue: Component) in
            if let binding = weakBinding {
                binding.onWillChange(newValue: newValue [keyPath: keyPath])
            }
        }

        listeners.append((binding: WeakWrapper(value: binding), callback: callback))
        
        return binding
    }
 
    func onWillChange(newValue: Component) {
        
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
