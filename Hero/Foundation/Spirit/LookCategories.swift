//
//  LookCategories.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.09.22.
//

import Foundation


struct LookCategories: OptionSet {
    let rawValue: SPTLookCategories

    static let renderable           = LookCategories(rawValue: 1 << 0)
    static let renderableModel      = LookCategories(rawValue: 1 << 1)
    static let guide                = LookCategories(rawValue: 1 << 2)

    static let all                  = LookCategories(rawValue: kSPTLookCategoriesAll)
}
