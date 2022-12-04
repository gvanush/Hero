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
    static let guide                = LookCategories(rawValue: 1 << 1)

    static let all                  = LookCategories(rawValue: kSPTLookCategoriesAll)
}
