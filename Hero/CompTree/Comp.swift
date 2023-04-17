//
//  Comp.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import Foundation


protocol CompProperty: RawRepresentable, CaseIterable, Displayable where Self.RawValue == Int {
}

struct Comp: Identifiable {
    
    let title: String
    private(set) var subtitle: String?
    private(set) var subs: [Comp]
    
    fileprivate(set) var makeController: () -> CompControllerBase = { .init(properties: nil, activePropertyIndex: nil) }
    
    private var declarationID = IndexPath()
    private var variationID = IndexPath()
    
    init(_ title: String, subtitle: String? = nil, @CompBuilder _ builder: () -> [Comp]) {
        self.title = title
        self.subtitle = subtitle
        self.subs = builder()
    }
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.subs = []
    }
    
    init(_ title: String, subs: [Comp]) {
        self.title = title
        self.subs = subs
    }
    
    var id: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(declarationID)
        hasher.combine(variationID)
        return hasher.finalize()
    }
    
    func controller(_ controller: @escaping () -> CompControllerBase) -> Comp {
        var comp = self
        comp.makeController = controller
        return comp
    }
    
    func compAtIndexPath(_ indexPath: IndexPath) -> Comp? {
        guard let firstIndex = indexPath.first else {
            return self
        }
            
        guard firstIndex < subs.count else {
            return nil
        }
        
        return subs[firstIndex].compAtIndexPath(indexPath.dropFirst())
    }
    
    func declarationID(_ id: Int) -> Comp {
        var comp = self
        comp.extendDeclarationID(id)
        return comp
    }
    
    private mutating func extendDeclarationID(_ id: Int) {
        self.declarationID.append(id)
        for index in self.subs.indices {
            self.subs[index].extendDeclarationID(id)
        }
    }
    
    func variationID(_ id: Int) -> Comp {
        var comp = self
        comp.variationID.append(id)
        return comp
    }
    
}
