//
//  EdgeInsetsUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.08.22.
//

import Foundation
import SwiftUI

extension EdgeInsets {
    
    func topInseted(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: self.top + value, leading: self.leading, bottom: self.bottom, trailing: self.trailing)
    }
    
    func bottomInseted(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: self.top, leading: self.leading, bottom: self.bottom + value, trailing: self.trailing)
    }
    
}
