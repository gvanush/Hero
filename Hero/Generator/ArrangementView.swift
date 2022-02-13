//
//  ArrangementView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.02.22.
//

import SwiftUI


class ArrangementComponent: MultiVariantComponent4<PointArrangementComponentVariant, LinearArrangementComponentVariant, PlanarArrangementComponentVariant, SpatialArrangementComponentVariant> {
 
    enum VariantTag: DistinctValueSet, Displayable {
        case point
        case linear
        case planar
        case spatial
    }
    
    let object: SPTObject
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Arrangement", variantTag: .linear, parent: parent)
    }
 
    var point: PointArrangementComponentVariant {
        variant1
    }
    
    var linear: LinearArrangementComponentVariant {
        variant2
    }
    
    var planar: PlanarArrangementComponentVariant {
        variant3
    }
    
    var spatial: SpatialArrangementComponentVariant {
        variant4
    }
}


class PointArrangementComponentVariant: ComponentVariant {
        
    required init() {}
    
    static var tag: ArrangementComponent.VariantTag {
        ArrangementComponent.VariantTag.point
    }
    
}


class LinearArrangementComponentVariant: ComponentVariant {
    
    enum Property: Int, DistinctValueSet, Displayable {
        case axis
    }
    
    @Published var selected: Property? = .axis
    
    required init() {}
    
    static var tag: ArrangementComponent.VariantTag {
        ArrangementComponent.VariantTag.linear
    }
    
}


class PlanarArrangementComponentVariant: ComponentVariant {
    
    required init() {}
    
    static var tag: ArrangementComponent.VariantTag {
        ArrangementComponent.VariantTag.planar
    }
    
}


class SpatialArrangementComponentVariant: ComponentVariant {
    
    required init() {}
    
    static var tag: ArrangementComponent.VariantTag {
        ArrangementComponent.VariantTag.spatial
    }
    
}


struct ArrangementView: View {
    
    @ObservedObject var component: ArrangementComponent
    
    var body: some View {
        Section(component.title) {
            Picker(selection: $component.variantTag) {
                ForEach(ArrangementComponent.VariantTag.allCases) { variant in
                    Text(variant.displayName)
                }
            } label: { }
            .pickerStyle(.segmented)
            
            switch component.variantTag {
            case .point:
                Text("Not implemented")
            case .linear:
                SceneEditableParam(title: LinearArrangementComponentVariant.Property.axis.displayName, value: component.linear.selected?.displayName) {

                }
                
                SceneEditableCompositeParam(title: "Rule", value: "Random") {
                    
                } destionation: {
                    Color.red
                }
            case .planar:
                Text("Not implemented")
            case .spatial:
                Text("Not implemented")
            }
            
        }
    }
}


struct ArrangementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                ArrangementView(component: ArrangementComponent(object: kSPTNullObject, parent: nil))
            }
            // NOTE: This is necessary for unknown reason to prevent 'Form' row
            // from being selectable when there is a button inside.
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
