//
//  SPTCancellable.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.03.22.
//

import Foundation


protocol SPTAnySubscription {
    func cancel()
}

class SPTSubscription<O>: SPTAnySubscription {
    
    let observer: O
    var canceller: (() -> Void)! = nil
    
    init(observer: O) {
        self.observer = observer
    }
    
    deinit {
        cancel()
    }
    
    func cancel() {
        canceller()
    }
    
}
