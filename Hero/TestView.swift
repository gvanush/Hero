//
//  TestView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/4/20.
//

import SwiftUI

struct TestView: View {

    @State var slidingViewState = SlidingViewState.closed
    
    var body: some View {
        SlidingView(state: $slidingViewState, content: Color(.blue).padding())
            .ignoresSafeArea()
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
