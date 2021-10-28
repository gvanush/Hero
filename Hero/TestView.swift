//
//  TestView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.21.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    Text("Hello, World!")
                    Text("Hello, World!")
                }
                .padding(.bottom, geo.safeAreaInsets.bottom)
                .background(.green)
            }
            .ignoresSafeArea()
            .background(.gray)
        }
        .background(.red)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
