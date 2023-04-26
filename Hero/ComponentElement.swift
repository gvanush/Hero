//
//  ComponentElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.04.23.
//

import SwiftUI

struct ComponentElementData: Equatable {
    let id: AnyHashable
    let title: String
    var subtitle: String?
    let indexPath: IndexPath
}

struct ComponentDisclosedElementsPreferenceKey: PreferenceKey {
    static var defaultValue = [ComponentElementData]()

    static func reduce(value: inout [ComponentElementData], nextValue: () -> [ComponentElementData]) {
        value.append(contentsOf: nextValue())
    }
}


protocol ComponentElement: Element {
    
    associatedtype ID: Hashable
    var id: ID { get }
    
    var title: String { get }
    
    var subtitle: String? { get }
    
}

extension ComponentElement {
    
    var faceView: some View {
        Text(title)
            .font(Font.system(size: 15, weight: .regular))
            .foregroundColor(.secondary)
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
            .contentShape(Rectangle())
            .overlay {
                VStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .imageScale(.small)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 1.0)
            }
            .scaleEffect(x: textHorizontalScale)
            .preference(key: ComponentDisclosedElementsPreferenceKey.self, value: isDisclosed ? [.init(id: id, title: title, subtitle: subtitle, indexPath: indexPath)] : [])
    }
    
    private var textHorizontalScale: CGFloat {
        guard let distance = distanceToActiveAncestor else { return 1.0 }
        return pow(1.3, 1.0 - CGFloat(distance))
    }
    
    private var distanceToActiveAncestor: Int? {
        guard indexPath.starts(with: activeIndexPath) else {
            return nil
        }
        return indexPath.count - activeIndexPath.count
    }
    
    var subtitle: String? {
        nil
    }
    
}
