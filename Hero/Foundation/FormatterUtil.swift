//
//  FormatterUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import Foundation

class FloatFormatter: Formatter {
    
    func updateFractionDigits(_ digits: Int) {}
    
}

class MeasurementFloatFormatter: FloatFormatter {
    
    let measurementFormatter = MeasurementFormatter()
    
    override func updateFractionDigits(_ digits: Int) {
        // NOTE: This is needed because measurement formatter is buggy in a sense that
        // changing underlying number formatter directly does not have any effect
        // after first formatting is requested, therefore new one is supplied
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = digits
        numberFormatter.maximumFractionDigits = digits
        measurementFormatter.numberFormatter = numberFormatter
    }
    
}


class BasicFloatFormatter: FloatFormatter {
    
    let numberFormatter = NumberFormatter()
    
    override func string(for obj: Any?) -> String? {
        numberFormatter.string(for: obj)
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        numberFormatter.getObjectValue(obj, for: string, errorDescription: error)
    }
    
    override func updateFractionDigits(_ digits: Int) {
        numberFormatter.minimumFractionDigits = digits
        numberFormatter.maximumFractionDigits = digits
    }
}

class PositionComponentFormatter: BasicFloatFormatter {
    
    override init() {
        super.init()
        numberFormatter.roundingMode = .halfEven
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ScaleComponentFormatter: BasicFloatFormatter {
    
    override init() {
        super.init()
        numberFormatter.roundingMode = .halfEven
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class AngleFormatter: MeasurementFloatFormatter {
    
    override init() {
        super.init()
        
        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter.roundingMode = .halfEven
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func string(for obj: Any?) -> String? {
        guard let number = obj as? NSNumber else {
            return nil
        }
        return measurementFormatter.string(from: .init(value: number.doubleValue, unit: UnitAngle.degrees))
    }
    
}

class FrequencyFormatter: MeasurementFloatFormatter {
    
    override func string(for obj: Any?) -> String? {
        guard let number = obj as? NSNumber else {
            return nil
        }
        if number.doubleValue < 1.0 {
            return "1 / " + measurementFormatter.string(from: .init(value: 1.0 / number.doubleValue, unit: UnitFrequency.hertz))
        }
        return measurementFormatter.string(from: .init(value: number.doubleValue, unit: UnitFrequency.hertz))
    }
    
}
