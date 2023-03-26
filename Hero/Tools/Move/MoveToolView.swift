//
//  MoveToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine


class MoveToolComponentViewProvider: MeshObjectComponentViewProvider<PositionComponent> {
    
    override func viewForRoot(_ root: PositionComponent) -> AnyView? {
        AnyView(PositionComponentView(component: root, viewProvider: self))
    }
    
}

class MoveToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<PositionComponent> {
}

fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: MoveToolSelectedObjectViewModel
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: MoveToolComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
            .padding(.horizontal, 8.0)
            .padding(.bottom, 8.0)
            .background {
                Color.clear
                    .contentShape(Rectangle())
            }
    }
    
}

class MoveToolViewModel: BasicToolViewModel<MoveToolSelectedObjectViewModel, PositionComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .move, sceneViewModel: sceneViewModel)
    }
}

// TODO
fileprivate class CoordinateSystemWrapper: ObservableObject {
    
    let object: SPTObject
    
    @SPTObservedComponentProperty<SPTPosition, SPTCoordinateSystem> var coordinateSystem: SPTCoordinateSystem
    
    init(object: SPTObject) {
        self.object = object
        
        _coordinateSystem = .init(object: object, keyPath: \.coordinateSystem)
        _coordinateSystem.publisher = self.objectWillChange
        
    }
    
}

fileprivate struct SelectedObjectView: View {
    
    private let object: SPTObject
    
    @State private var activeCompIndexPath = IndexPath()
    @State private var disclosedCompsData: [DisclosedCompData]?
    @StateObject private var coordinateSystemWrapper: CoordinateSystemWrapper
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        _coordinateSystemWrapper = .init(wrappedValue: .init(object: object))
    }
    
    var body: some View {
        CompTreeView(activeIndexPath: $activeCompIndexPath, defaultActionView: { controller in
            ObjectCompActionView(controller: (controller as! any ObjectCompController))
        }) {
            Comp("Position", subtitle: coordinateSystemWrapper.coordinateSystem.displayName)
                .controller {
                    switch coordinateSystemWrapper.coordinateSystem {
                    case .cartesian:
                        return CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel, editingParams: editingParams)
                    case .linear:
                        return CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel, editingParams: editingParams)
                    case .spherical:
                        return CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel, editingParams: editingParams)
                    case .cylindrical:
                        return CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel, editingParams: editingParams)
                    }
                }
            
        }
        .padding(.horizontal, 8.0)
        .padding(.bottom, 8.0)
        .background {
            Color.clear
                .contentShape(Rectangle())
        }
        .preference(key: ActiveToolItemViewPreferenceKey.self, value: .init(id: itemViewId, content: {
            itemView()
        }))
        .onPreferenceChange(DisclosedCompsPreferenceKey.self, perform: {
            self.disclosedCompsData = $0
        })
        .id(object)
    }
    
    private func itemView() -> some View {
        HStack {
            Divider()
            ScrollView(.horizontal, showsIndicators: false) {
                if let disclosedCompsData = disclosedCompsData {
                    ForEach(disclosedCompsData, id: \.comp.id) { data in
                        HStack {
                            if data.comp.id != disclosedCompsData.first!.comp.id {
                                Image(systemName: "chevron.right")
                                    .imageScale(.large)
                                    .foregroundColor(.secondary)
                            }
                            VStack(alignment: .leading) {
                                Text(data.comp.title)
                                    .fontWeight(activeCompIndexPath == data.comp.indexPath ? .regular : .medium)
                                    .fixedSize()
                                if let substitle = data.comp.subtitle {
                                    Text(substitle)
                                        .font(.system(.subheadline))
                                        .foregroundColor(Color.secondaryLabel)
                                        .fixedSize()
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                activeCompIndexPath = data.comp.indexPath
                            }
                        }
                    }
                }
            }
            coordinateSystemSelector()
        }
    }
    
    private func coordinateSystemSelector() -> some View {
        Menu {
            ForEach(SPTCoordinateSystem.allCases) { system in
                Button {
                    self.coordinateSystemWrapper.coordinateSystem = system
                } label: {
                    HStack {
                        Text(system.displayName)
                        Spacer()
                        if system == self.coordinateSystemWrapper.coordinateSystem {
                            Image(systemName: "checkmark.circle")
                                .imageScale(.small)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .imageScale(.medium)
        }
        .buttonStyle(.bordered)
        .shadow(radius: 0.5)
    }
    
    var itemViewId: Int {
        var hasher = Hasher()
        hasher.combine(self.coordinateSystemWrapper.coordinateSystem.rawValue)
        if let disclosedComps = disclosedCompsData {
            for comp in disclosedComps {
                hasher.combine(comp.comp.id)
            }
        }
        return hasher.finalize()
    }
    
}


struct MoveToolView: View {
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var body: some View {
        if let object = sceneViewModel.selectedObject {
            SelectedObjectView(object: object)
        }
    }
}
