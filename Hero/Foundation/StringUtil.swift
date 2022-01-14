//
//  StringUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.01.22.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
