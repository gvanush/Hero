//
//  TestView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/4/20.
//

import SwiftUI

class TestModel {
    @Published var x: Int
    
    init(x: Int) {
        self.x = x
    }
}

class TestViewModel: ObservableObject {
    var model = TestModel(x: 1)
    var cancellable: Any? = nil
    
    init() {
        self.cancellable = model.$x.sink { _ in
            self.objectWillChange.send()
        }
    }
}

struct TestView: View {
    
    @State private var isTopBarVisible = true
    @State private var isBottomBarVisible = true

    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            Button(action: {
                withAnimation {
                    isTopBarVisible.toggle()
                    isBottomBarVisible.toggle()
                }
            }, label: {
                Text("Button")
            })
            VStack {
                TopBar()
                    .opacity(isTopBarVisible ? 1.0 : 0.0)
                ObjectToolbar()
                    .opacity(isBottomBarVisible ? 1.0 : 0.0)
            }
        }
        .statusBar(hidden: !isTopBarVisible)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
