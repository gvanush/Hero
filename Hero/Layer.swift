//
//  Layer.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

import UIKit

class Layer {
    
    enum Source {
        case image(UIImage)
        case color(UIColor)
    }
    
    init(source: Source) {
        self.source = source
    }
    
    var source: Source
    
}
