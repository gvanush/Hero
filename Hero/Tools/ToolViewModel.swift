//
//  ToolViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.10.22.
//

import Foundation


enum Tool: Int, CaseIterable, Identifiable {

    enum Purpose {
        case build
        case animate
    }
    
    case move
    case orient
    case scale
    case shade
    case animatePosition
    case animateOrientation
    case animateScale
    case animateShade
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .move:
            return "Move"
        case .orient:
            return "Orient"
        case .scale:
            return "Scale"
        case .shade:
            return "Shade"
        case .animatePosition:
            return "Animate Position"
        case .animateOrientation:
            return "Animate Orientation"
        case .animateScale:
            return "Animate Scale"
        case .animateShade:
            return "Animate Shade"
        }
    }
    
    var iconName: String {
        switch self {
        case .move:
            return "move"
        case .orient:
            return "orient"
        case .scale:
            return "scale"
        case .shade:
            return "shade"
        case .animatePosition:
            return "animmove"
        case .animateOrientation:
            return "animorient"
        case .animateScale:
            return "animscale"
        case .animateShade:
            return "animshade"
        }
    }
    
    var purpose: Purpose {
        switch self {
        case .move, .orient, .scale, .shade:
            return .build
        case .animatePosition, .animateScale, .animateOrientation, .animateShade:
            return .animate
        }
    }
}


class ToolViewModel: ObservableObject, Identifiable, Equatable {
    
    let tool: Tool
    let sceneViewModel: SceneViewModel
    
    init(tool: Tool, sceneViewModel: SceneViewModel) {
        self.tool = tool
        self.sceneViewModel = sceneViewModel
    }
    
    func onActive() {}
    
    func onInactive() {}
    
    var activeComponent: Component? {
        set { }
        get { nil }
    }
    
    func onObjectDuplicate(original: SPTObject, duplicate: SPTObject) {
    }
    
    func onObjectDestroy(_ object: SPTObject) {
    }
    
    static func == (lhs: ToolViewModel, rhs: ToolViewModel) -> Bool {
        lhs === rhs
    }
    
}
