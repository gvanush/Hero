//
//  BundleUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 15.12.22.
//

import Foundation


extension Bundle {
    
    var releaseVersionString: String {
        infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildVersionString: String {
        infoDictionary?["CFBundleVersion"] as! String
    }
    
}
