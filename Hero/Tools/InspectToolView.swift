//
//  InspectToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.10.22.
//

import SwiftUI

class InspectToolViewModel: ToolViewModel {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .inspect, sceneViewModel: sceneViewModel)
    }
}

struct InspectToolView: View {
    var body: some View {
        EmptyView()
    }
}

struct InspectToolView_Previews: PreviewProvider {
    static var previews: some View {
        InspectToolView()
    }
}
