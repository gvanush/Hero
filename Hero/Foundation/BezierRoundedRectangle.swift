//
//  View+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.10.21.
//

import SwiftUI

struct BezierRoundedRectangle: Shape {

    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( BezierRoundedRectangle(radius: radius, corners: corners) )
    }
}
