//
//  ArrangementView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.02.22.
//

import SwiftUI


class ArrangementComponent: Component {
 
    enum VariantTag: DistinctValueSet, Displayable {
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
    
    lazy var point = PointArrangementComponentVariant(arrangement: $arrangement.point)
    lazy var linear = LinearArrangementComponentVariant(arrangement: $arrangement.linear)
    lazy var planar = PlanarArrangementComponentVariant(arrangement: $arrangement.planar)
    lazy var spatial = SpatialArrangementComponentVariant(arrangement: $arrangement.spatial)
    
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
 
    override var properties: [String]? {
        switch variantTag {
        case .point:
            return point.properties
        case .linear:
            return linear.properties
        case .planar:
            return planar.properties
        case .spatial:
            return spatial.properties
        }
    }
    
    override var activePropertyIndex: Int? {
        set {
            switch variantTag {
            case .point:
                point.activePropertyIndex = newValue
            case .linear:
                linear.activePropertyIndex = newValue
            case .planar:
                planar.activePropertyIndex = newValue
            case .spatial:
                spatial.activePropertyIndex = newValue
            }
        }
        get {
            switch variantTag {
            case .point:
                return point.activePropertyIndex
            case .linear:
                return linear.activePropertyIndex
            case .planar:
                return planar.activePropertyIndex
            case .spatial:
                return spatial.activePropertyIndex
            }
        }
    }
    
    override var subcomponents: [Component]? {
        switch variantTag {
        case .point:
            return point.subcomponents
        case .linear:
            return linear.subcomponents
        case .planar:
            return planar.subcomponents
        case .spatial:
            return spatial.subcomponents
        }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}


class PointArrangementComponentVariant: ComponentVariant {
        
    @ObjectBinding private var arrangement: SPTPointArrangement
 
    init(arrangement: ObjectBinding<SPTPointArrangement>) {
        _arrangement = arrangement
    }
    
}


class LinearArrangementComponentVariant: ComponentVariant {
    
    enum Property: Int, DistinctValueSet, Displayable {
        case axis
    }
    
    @Published var selected: Property? = .axis

    @ObjectBinding private var arrangement: SPTLinearArrangement
    
    init(arrangement: ObjectBinding<SPTLinearArrangement>) {
        _arrangement = arrangement
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


class PlanarArrangementComponentVariant: ComponentVariant {
    @ObjectBinding private var arrangement: SPTPlanarArrangement
 
    init(arrangement: ObjectBinding<SPTPlanarArrangement>) {
        _arrangement = arrangement
    }
}


class SpatialArrangementComponentVariant: ComponentVariant {
    @ObjectBinding private var arrangement: SPTSpatialArrangement
 
    init(arrangement: ObjectBinding<SPTSpatialArrangement>) {
        _arrangement = arrangement
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
                SceneEditableParam(title: LinearArrangementComponentVariant.Property.axis.displayName, value: component.linear.selected?.displayName) {
                    component.linear.selected = .axis
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
