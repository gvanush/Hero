//
//  PlayView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.09.22.
//

import SwiftUI


class PlayViewModel: ObservableObject {
    
    let scene: SPTScene
    let viewCameraObject: SPTObject
    
    init(scene: SPTScene, viewCameraObject: SPTObject) {
        self.scene = scene
        self.viewCameraObject = viewCameraObject
    }
}


struct PlayView: View {
    
    @ObservedObject var model: PlayViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        SPTView(scene: model.scene, clearColor: UIColor.lightGray.mtlClearColor, viewCameraObject: model.viewCameraObject, lookCategories: LookCategories.userCreated.rawValue)
            .ignoresSafeArea()
            .statusBarHidden()
    }
}
