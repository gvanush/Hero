//
//  SPTMeshLookUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.09.22.
//

import Foundation


extension SPTMeshLook: SPTComponent {
    
    init(material: SPTPlainColorMaterial, meshId: SPTMeshId, categories: SPTLookCategories = kSPTLookCategoriesAll) {
        self.init(.init(plainColor: material), shading: .plainColor, meshId: meshId, categories: categories)
    }
    
    init(material: SPTPhongMaterial, meshId: SPTMeshId, categories: SPTLookCategories = kSPTLookCategoriesAll) {
        self.init(.init(blinnPhong: material), shading: .blinnPhong, meshId: meshId, categories: categories)
    }
    
    public static func == (lhs: SPTMeshLook, rhs: SPTMeshLook) -> Bool {
        SPTMeshLookEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTMeshLook, object: SPTObject) {
        SPTMeshLookMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTMeshLook, object: SPTObject) {
        if SPTMeshLookExists(object) {
            SPTMeshLookUpdate(object, component)
        } else {
            SPTMeshLookMake(object, component)
        }
    }
    
    static func update(_ component: SPTMeshLook, object: SPTObject) {
        SPTMeshLookUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTMeshLookDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTMeshLook {
        SPTMeshLookGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTMeshLook? {
        SPTMeshLookTryGet(object)?.pointee
    }
}
