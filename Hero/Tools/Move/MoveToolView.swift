//
//  MoveToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI


fileprivate struct SelectedObjectView: View {
    
    @ObservedObject @ObservableAnyUserObject var object: any UserObject
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: any UserObject) {
        _object = .init(wrappedValue: .init(wrappedValue: object))
    }
    
    var body: some View {
        VStack {
            
            BasicToolElementActionViewPlaceholder(object: object.sptObject)
            
            ElementTreeView(activeIndexPath: $editingParams[tool: .move, object.sptObject].activeElementIndexPath) {
                
                switch object.position.coordinateSystem {
                case .cartesian:
                    CartesianPositionElement(object: object, keyPath: \SPTPosition.cartesian, position: $object.position.cartesian, optionsView: {
                        ObjectCoordinateSystemSelector(object: object)
                    })
                case .linear:
                    LinearPositionElement(object: object)
                case .cylindrical:
                    CylindricalPositionElement(object: object)
                case .spherical:
                    SphericalPositionElement(object: object)
                }
                
            }
        }
        .onPreferenceChange(DisclosedElementsPreferenceKey.self) {
            model[object.sptObject].disclosedElementsData = $0
        }
        .onAppear {
            SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: object.sptObject)
        }
        .onDisappear {
            model[object.sptObject] = nil
            SPTPointLook.destroy(object: object.sptObject)
        }
    }
    
}


struct MoveToolView: View {
    
    @ObservedObject var model: BasicToolModel
    
    @EnvironmentObject var scene: MainScene
    
    var body: some View {
        if let object = scene.selectedObject {
            SelectedObjectView(object: object)
                .id(object.id)
                .environmentObject(model)
        }
    }
}
