//
//  SPTCancellable.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.03.22.
//

import Foundation

public protocol SPTAnyCancellable {
    
}

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
