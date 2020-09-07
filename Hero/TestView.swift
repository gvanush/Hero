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
    
    @ObservedObject var viewModel: TestViewModel
    
    var body: some View {
        Text("Hello \(viewModel.model.x)")
            .onTapGesture(count: 1, perform: {
                viewModel.model.x = 5
            })
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView(viewModel: TestViewModel())
    }
}
