//
//  FormatterUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import Foundation


extension MeasurementFormatter {
    
    static var angleFormatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        return formatter
    }
    
    static func angleSubjectProvider(_ value: Float) -> NSObject {
        Measurement<UnitAngle>(value: Double(value), unit: .degrees) as NSObject
    }
}
