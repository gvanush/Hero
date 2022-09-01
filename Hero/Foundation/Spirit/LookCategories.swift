//
//  LookCategories.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.09.22.
//

import Foundation


struct LookCategories: OptionSet {
    let rawValue: SPTLookCategories

    static let userCreated          = LookCategories(rawValue: 1 << 0)
    static let sceneGuide           = LookCategories(rawValue: 1 << 1)
    static let objectSelection      = LookCategories(rawValue: 1 << 2)
    static let toolGuide            = LookCategories(rawValue: 1 << 3)

    static let all                  = LookCategories(rawValue: kSPTLookCategoriesAll)
}
