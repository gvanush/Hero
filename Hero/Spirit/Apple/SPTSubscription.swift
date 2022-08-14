//
//  SPTCancellable.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.03.22.
//

import Foundation

// TODO: Remove
public protocol SPTAnyCancellable {

}

// TODO: Remove
public class SPTCancellableListener<CT>: SPTAnyCancellable {
    
    let callback: (CT) -> Void
    private let cancel: (SPTCancellableListener<CT>) -> Void
    
    init(callback: @escaping (CT) -> Void, _ cancel: @escaping (SPTCancellableListener<CT>) -> Void) {
        self.callback = callback
        self.cancel = cancel
    }
    
    deinit {
        cancel(self)
    }
    
}


public protocol SPTAnySubscription {

}

public class SPTSubscription<C, T>: SPTAnySubscription {
    
    let callback: C
    private let cancel: (T) -> Void
    var token: T!
    
    init(callback: C, _ cancel: @escaping (T) -> Void) {
        self.callback = callback
        self.cancel = cancel
    }
    
    deinit {
        cancel(token)
    }
    
}
