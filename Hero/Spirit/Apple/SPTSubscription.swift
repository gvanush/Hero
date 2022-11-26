//
//  SPTCancellable.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.03.22.
//

import Foundation


protocol SPTSubscriptionProtocol {
    func cancel()
}

class SPTSubscription<O>: SPTSubscriptionProtocol {
    
    let observer: O
    var canceller: (() -> Void)!
    
    init(observer: O) {
        self.observer = observer
    }
    
    deinit {
        cancel()
    }
    
    func cancel() {
        canceller()
    }
    
    func eraseToAnySubscription() -> SPTAnySubscription {
        .init(subscription: self)
    }
    
}


class SPTAnySubscription: Hashable {
    
    let subscription: SPTSubscriptionProtocol
    
    init(subscription: SPTSubscriptionProtocol) {
        self.subscription = subscription
    }
    
    func cancel() {
        subscription.cancel()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    static func == (lhs: SPTAnySubscription, rhs: SPTAnySubscription) -> Bool {
        lhs === rhs
    }
    
}
