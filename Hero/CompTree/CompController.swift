//
//  CompController.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import Foundation


protocol CompControllerProtocol: CompControllerBase {
    
    associatedtype Property: CompProperty
    
}

extension CompControllerProtocol {
    
    var activeProperty: Property? {
        get {
            .init(rawValue: self.activePropertyIndex)
        }
        set {
            self.activePropertyIndex = newValue?.rawValue
        }
    }
    
}

class CompControllerBase: ObservableObject, Equatable {
    
    let properties: [String]?
    @Published var activePropertyIndex: Int?
    private (set) var isActive = false
    private (set) var isDisclosed = false
    
    init(properties: [String]?, activePropertyIndex: Int?) {
        self.properties = properties
        self.activePropertyIndex = activePropertyIndex
    }
    
    init<P>(activeProperty: P) where P: CompProperty {
        self.properties = P.allCaseDisplayNames
        self.activePropertyIndex = activeProperty.rawValue
    }
    
    func activate() {
        isActive = true
        onActive()
    }
    
    func deactivate() {
        isActive = false
        onInactive()
    }
    
    func disclose() {
        isDisclosed = true
        onDisclose()
    }
    
    func close() {
        isDisclosed = false
        onClose()
    }
    
    func onVisible() { }
    
    func onInvisible() { }
    
    func onDisclose() { }
    
    func onClose() { }
    
    func onActive() { }
    
    func onInactive() { }
    
    func onActivePropertyWillChange() { }
    
    func onActivePropertyDidChange() { }
    
    static func == (lhs: CompControllerBase, rhs: CompControllerBase) -> Bool {
        lhs === rhs
    }
    
}

typealias CompController = CompControllerBase & CompControllerProtocol
