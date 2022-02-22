//
//  ArrangementView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.02.22.
//

import SwiftUI


class ArrangementComponent: MultiVariantComponent {
 
    enum VariantTag: Int, DistinctValueSet, Displayable {
        case point
        case linear
        case planar
        case spatial
        
        init(_ sptValue: SPTArrangementVariantTag) {
            switch sptValue {
            case .point:
                self = .point
            case .linear:
                self = .linear
            case .planar:
                self = .planar
            case .spatial:
                self = .spatial
            }
        }
        
        var sptValue: SPTArrangementVariantTag {
            switch self {
            case .point:
                return .point
            case .linear:
                return .linear
            case .planar:
                return .planar
            case .spatial:
                return .spatial
            }
        }
    }
    
    @ObjectBinding private var arrangement: SPTArrangement
    
    lazy var point = PointArrangementComponent(arrangement: $arrangement.point, parent: self)
    lazy var linear = LinearArrangementComponent(arrangement: $arrangement.linear, parent: self)
    lazy var planar = PlanarArrangementComponent(arrangement: $arrangement.planar, parent: self)
    lazy var spatial = SpatialArrangementComponent(arrangement: $arrangement.spatial, parent: self)
    
    private var storedPoint = SPTArrangement(variantTag: .point, .init(point: .init()))
    private var storedLinear = SPTArrangement(variantTag: .linear, .init(linear: .init(axis: .X)))
    private var storedPlanar = SPTArrangement(variantTag: .planar, .init(planar: .init(plain: .XY)))
    private var storedSpatial = SPTArrangement(variantTag: .spatial, .init(spatial: .init()))
    
    init(arrangement: ObjectBinding<SPTArrangement>, parent: Component?) {
        _arrangement = arrangement
        
        super.init(title: "Arrangement", parent: parent)
        
        updateStoredArrangement()
    }
    
    var variantTag: VariantTag {
        set {
            updateStoredArrangement()
            switch newValue {
            case .point:
                arrangement = storedPoint
            case .linear:
                arrangement = storedLinear
            case .planar:
                arrangement = storedPlanar
            case .spatial:
                arrangement = storedSpatial
            }
        }
        get {
            VariantTag(arrangement.variantTag)
        }
    }
    
    private func updateStoredArrangement() {
        switch variantTag {
        case .point:
            storedPoint = arrangement
        case .linear:
            storedLinear = arrangement
        case .planar:
            storedPlanar = arrangement
        case .spatial:
            storedSpatial = arrangement
        }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
    override var variants: [Component]! {
        [point, linear, planar, spatial]
    }
    
    override var activeVariantIndex: Int? {
        set { variantTag = .init(rawValue: newValue)! }
        get { variantTag.rawValue }
    }
}


class PointArrangementComponent: Component {
        
    @ObjectBinding private var arrangement: SPTPointArrangement
 
    init(arrangement: ObjectBinding<SPTPointArrangement>, parent: Component?) {
        _arrangement = arrangement
        super.init(title: "Point Arrangement", parent: parent)
    }
    
}

enum LinearArrangementComponentProperty: Int, DistinctValueSet, Displayable {
    case axis
}

class LinearArrangementComponent: BasicComponent<LinearArrangementComponentProperty> {
    
    @ObjectBinding private var arrangement: SPTLinearArrangement
    
    init(arrangement: ObjectBinding<SPTLinearArrangement>, parent: Component?) {
        _arrangement = arrangement
        super.init(title: "Linear Arrangement", selectedProperty: .axis, parent: parent)
    }
    
    var axis: Axis {
        set {
            arrangement.axis = newValue.sptValue
        }
        get {
            Axis(arrangement.axis)
        }
    }
    
    
    
}


class PlanarArrangementComponent: Component {
    @ObjectBinding private var arrangement: SPTPlanarArrangement
 
    init(arrangement: ObjectBinding<SPTPlanarArrangement>, parent: Component?) {
        _arrangement = arrangement
        super.init(title: "Planar Arrangement", parent: parent)
    }
}


class SpatialArrangementComponent: Component {
    @ObjectBinding private var arrangement: SPTSpatialArrangement
 
    init(arrangement: ObjectBinding<SPTSpatialArrangement>, parent: Component?) {
        _arrangement = arrangement
        super.init(title: "Spatial Arrangement", parent: parent)
    }
}


struct ArrangementView: View {
    
    @ObservedObject var component: ArrangementComponent
    @Binding var editedComponent: Component?
    
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
                SceneEditableParam(title: LinearArrangementComponentProperty.axis.displayName, value: component.linear.selectedProperty?.displayName) {
                    component.linear.selectedProperty = .axis
                    editedComponent = component
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
    
    static var arrangement = SPTArrangement(variantTag: .linear, .init(linear: SPTLinearArrangement(axis: .X)))
    
    static var binding: ObjectBinding<SPTArrangement> {
        ObjectBinding {
            arrangement
        } setter: { newValue in
            arrangement = newValue
        }
    }
    
    static var previews: some View {
        NavigationView {
            Form {
                ArrangementView(component: ArrangementComponent(arrangement: binding, parent: nil), editedComponent: .constant(nil))
            }
            // NOTE: This is necessary for unknown reason to prevent 'Form' row
            // from being selectable when there is a button inside.
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}
