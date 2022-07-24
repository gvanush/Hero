//
//  SPTGeneratortUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.03.22.
//

import Foundation


@propertyWrapper
@dynamicMemberLookup
class SPTObservedGenerator: SPTObservedObject {
    
    private let object: SPTObject
    internal let binding: SPTObjectBinding<SPTGenerator>
    
    init(object: SPTObject) {
        self.object = object
        
        binding = SPTObjectBinding(value: SPTGeneratorGet(object), setter: { newValue in
            SPTGeneratorUpdate(object, newValue)
        })
        
        SPTGeneratorAddWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { listener, newValue  in
            let me = Unmanaged<SPTObservedGenerator>.fromOpaque(listener).takeUnretainedValue()
            me.binding.onWillChange(newValue: newValue)
        })
        
    }
    
    deinit {
        SPTGeneratorRemoveWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
 
    var wrappedValue: SPTGenerator {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTObjectBinding<SPTGenerator> {
        binding
    }
    
}


extension SPTGenerator: Equatable {
    
    public static func == (lhs: SPTGenerator, rhs: SPTGenerator) -> Bool {
        SPTGeneratorEqual(lhs, rhs)
    }
    
}


extension SPTArrangement: Equatable {
    
    public static func == (lhs: SPTArrangement, rhs: SPTArrangement) -> Bool {
        SPTArrangementEqual(lhs, rhs)
    }
    
}

extension SPTPointArrangement: Equatable {
    
    public static func == (lhs: SPTPointArrangement, rhs: SPTPointArrangement) -> Bool {
        SPTPointArrangementEqual(lhs, rhs)
    }
    
}


extension SPTLinearArrangement: Equatable {
    
    public static func == (lhs: SPTLinearArrangement, rhs: SPTLinearArrangement) -> Bool {
        SPTLinearArrangementEqual(lhs, rhs)
    }
    
}


extension SPTPlanarArrangement: Equatable {
    
    public static func == (lhs: SPTPlanarArrangement, rhs: SPTPlanarArrangement) -> Bool {
        SPTPlanarArrangementEqual(lhs, rhs)
    }
    
}


extension SPTSpatialArrangement: Equatable {
    
    public static func == (lhs: SPTSpatialArrangement, rhs: SPTSpatialArrangement) -> Bool {
        SPTSpatialArrangementEqual(lhs, rhs)
    }
    
}
