//
//  SPTCancellable.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.03.22.
//

import Foundation

public class SPTAnyCancellable {
    
}

public class SPTListener<CT>: SPTAnyCancellable {
    
    let callback: (CT) -> Void
    private let cancel: (SPTListener<CT>) -> Void
    
    init(callback: @escaping (CT) -> Void, _ cancel: @escaping (SPTListener<CT>) -> Void) {
        self.callback = callback
        self.cancel = cancel
    }
    
    deinit {
        cancel(self)
    }
    
}
