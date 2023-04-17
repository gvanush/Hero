//
//  CompTreeView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.03.23.
//

import SwiftUI


struct CompTreeView<AV>: View where AV: View {
    
    @Binding var activeIndexPath: IndexPath
    let defaultActionView: (CompControllerBase) -> AV?
    
    private var rootView: AnyView
    @State private var disclosedCompsData: [DisclosedCompData]?
    
    init(activeIndexPath: Binding<IndexPath>, defaultActionView: @escaping (CompControllerBase) -> AV? = { _ in Optional<EmptyView>.none }, @CompBuilder builder: () -> [Comp]) {
        _activeIndexPath = activeIndexPath
        self.defaultActionView = defaultActionView
        
        var rootComp: Comp? = nil
        
        let comps = builder()
        switch comps.count {
        case 0:
            break
        case 1:
            rootComp = comps.first!
        default:
            rootComp = .init("<Root>", subs: comps)
        }
        
        if let rootComp = rootComp {
            rootView = Self.build(comp: rootComp, indexPath: .init(), activeIndexPath: _activeIndexPath)
        } else {
            rootView = AnyView(EmptyView())
        }
    }
    
    var body: some View { 
        VStack {
            if let activeCompData = activeCompData, let controller = activeCompData.controller {
                defaultActionView(controller)
            }
            
            rootView
                .padding(3.0)
                .frame(height: 38.0)
                .background(Material.regular)
                .cornerRadius(SelectorConst.cornerRadius)
                .compositingGroup()
                .shadow(radius: 1.0)
        }
        .onPreferenceChange(DisclosedCompsPreferenceKey.self) { data in
            disclosedCompsData = data
        }
    }
    
    private var activeCompData: DisclosedCompData? {
        disclosedCompsData?.last
    }
    
    static func build(comp: Comp, indexPath: IndexPath, activeIndexPath: Binding<IndexPath>) -> AnyView {
        AnyView(CompView(compId: comp.id, title: comp.title, subtitle: comp.subtitle, indexPath: indexPath, activeIndexPath: activeIndexPath, controllerProvider: comp.makeController) {
            
            ForEach(Array(comp.subs.enumerated()), id: \.element.id) { index, subcomp in
                build(comp: subcomp, indexPath: indexPath.appending(index), activeIndexPath: activeIndexPath)
            }
            
        }
        .id(comp.id))
    }
}

struct DisclosedCompData: Equatable {
    
    let compId: Int
    let title: String
    let subtitle: String?
    let indexPath: IndexPath
    
    private(set) weak var controller: CompControllerBase?
    
    static func == (lhs: DisclosedCompData, rhs: DisclosedCompData) -> Bool {
        lhs.compId == rhs.compId
    }
}

struct DisclosedCompsPreferenceKey: PreferenceKey {
    static var defaultValue = [DisclosedCompData]()
    
    static func reduce(value: inout [DisclosedCompData], nextValue: () -> [DisclosedCompData]) {
        value.append(contentsOf: nextValue())
    }
}

struct ActiveCompPropertyChangePreferenceKey: PreferenceKey {
    
    struct Data: Equatable {
        let compId: Int
        private(set) weak var controller: CompControllerBase?
        let activePropertyIndex: Int
        
        static func == (lhs: Data, rhs: Data) -> Bool {
            lhs.compId == rhs.compId && lhs.activePropertyIndex == rhs.activePropertyIndex
        }
    }
    
    static var defaultValue: Data?
    
    static func reduce(value: inout Data?, nextValue: () -> Data?) {
        value = value ?? nextValue()
    }
}

struct CompTreeView_Previews: PreviewProvider {
    
    class DummyController: CompController {
        
        enum Property: Int, CompProperty {
            case a
            case b
            case c
        }
        
        convenience init() {
            self.init(activeProperty: Property.a)
        }
    }
    
    struct ContentView: View {
        
        @State var activeIndexPath = IndexPath()
        @State var toggleAAA = false
        @State var indicator = false
        @State var coordSystem = SPTCoordinateSystem.cartesian
        
        var body: some View {
            VStack {
                CompTreeView(activeIndexPath: $activeIndexPath, defaultActionView: { _ in
                    Color.red
                }) {
                    Comp("Human") {
                        Comp("Head")
                            .controller {
                                DummyController()
                            }
                        Comp("Belly")
                            .controller {
                                DummyController()
                            }
                    }
                    
                    Comp("Car") {
                        Comp("Frame")
                            .controller { DummyController() }
                        Comp("Motor")
                            .controller { DummyController() }
                    }
                    
                    if toggleAAA {
                        Comp("ToggleTrue")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    }
                    
                    if !toggleAAA {
                        Comp("ToggleFalse")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    }
                    
                    switch coordSystem {
                    case .cartesian:
                        Comp("Cartesian")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    case .linear:
                        Comp("Linear")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    case .cylindrical:
                        Comp("Cylindrical")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    case .spherical:
                        Comp("Spherical")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    }
                    
                }
                
                HStack() {
                    Button("Back") {
                        withAnimation {
                            _ = activeIndexPath.removeLast()
                        }
                    }
                    .disabled(activeIndexPath.isEmpty)
                    
                    Spacer()
                    
                    Button("Toggle") {
                        withAnimation {
                            toggleAAA.toggle()
                        }
                    }
                    
                    Spacer()
                    
                    Picker("Coordinate System", selection: $coordSystem) {
                        ForEach(SPTCoordinateSystem.allCases, id: \.self) { s in
                            Text(s.displayName)
                                .tag(s)
                        }
                    }
                }
                
                Toggle(isOn: $indicator, label: {
                    Text("Indicator")
                })
            }
            .padding()
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
