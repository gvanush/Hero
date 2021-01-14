//
//  UIGraphicsUtils.swift
//  Hero
//
//  Created by Vanush Grigoryan on 1/13/21.
//

import SwiftUI

class GraphicsSyncViewModel: ObservableObject, UIRepresentableObserver {
    let graphicsViewModel: GraphicsViewModel
    var observables = [UIRepresentable]()
    
    init(graphicsViewModel: GraphicsViewModel) {
        self.graphicsViewModel = graphicsViewModel
    }
    
    deinit {
        for uiRepresentable in observables {
            graphicsViewModel.renderer.removeObserver(self, for: uiRepresentable)
        }
    }
    
    func observe(uiRepresentable: UIRepresentable) {
        observables.append(uiRepresentable)
        graphicsViewModel.renderer.addObserver(self, for: uiRepresentable)
    }
    
    // UIRepresentableObserver
    func onUIUpdateRequired() {
        objectWillChange.send()
    }
}

enum Vector3Field: Int {
    case x = 0
    case y = 1
    case z = 2
    
    var name: String {
        switch self {
        case .x:
            return "x"
        case .y:
            return "y"
        case .z:
            return "z"
        }
    }
}

func name(for eulerOrder: EulerOrder) -> String? {
    switch eulerOrder {
    case EulerOrder_xyz:
        return "xyz"
    case EulerOrder_xzy:
        return "xzy"
    case EulerOrder_yxz:
        return "yxz"
    case EulerOrder_yzx:
        return "yzx"
    case EulerOrder_zxy:
        return "zxy"
    case EulerOrder_zyx:
        return "zyx"
    default:
        return nil
    }
}
