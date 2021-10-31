//
//  TestView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.21.
//

import SwiftUI

struct MyFloatSelector<FT>: View {
    var body: some View {
        valueText
    }
    
    var valueText: some View {
        Text("Default")
    }
}

extension MyFloatSelector where FT: NumberFormatter {
    var valueText: some View {
        Text("NumberFormatter")
    }
}


struct TestView: View {
    @State private var myDate = Date()
    
    var body: some View {
        VStack {
            Text(myDate, format: Date.FormatStyle(date: .numeric, time: .omitted))
            Text(Measurement<UnitAngle>(value: 50.0134, unit: .degrees), format: Measurement<UnitAngle>.FormatStyle(width: .narrow))
            MyFloatSelector<Int>()
            MyFloatSelector<NumberFormatter>()
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
