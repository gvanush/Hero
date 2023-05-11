//
//  ElementView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


extension Element {
    
    var body: some View {
        defaultBody
    }
    
    var defaultBody: some View {
        ZStack {
            
            faceView
                .visible(isChildOfActive)
                .onTapGesture {
                    if isReady {
                        withAnimation(elementNavigationAnimation) {
                            activeIndexPath = indexPath
                        }
                    } else {
                        onPrepare()
                    }
                }
                .allowsHitTesting(isChildOfActive)
            
            if isReady {
                rearView
            }
            
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
        .overlay(alignment: .center) {
            if isActive {
                actionView
                    .transition(.identity)
                    .matchedGeometryEffect(id: elementActionViewMatchedGeometryID, in: namespace, properties: .frame, isSource: false)
            }
        }
        .overlay {
            if isActive {
                optionsView
                    .transition(.identity)
                    .matchedGeometryEffect(id: elementOptionsViewMatchedGeometryID, in: namespace, properties: .position, isSource: false)
            }
        }
        .onChange(of: isReady, perform: { newValue in
            if isReady {
                onAwake()
            }
        })
        .onChange(of: isParentDisclosed, perform: { newValue in
            if newValue {
                onParentDisclosed()
            }
        })
        .onChange(of: isDisclosed, perform: { newValue in
            if newValue {
                onDisclose()
            }
        })
        .onChange(of: isActive) { newValue in
            if newValue {
                onActive()
            } else {
                onInactive()
            }
        }
        .onChange(of: isDisclosed, perform: { newValue in
            if !newValue {
                onClose()
            }
        })
        .onChange(of: isParentDisclosed, perform: { newValue in
            if !newValue {
                onParentClosed()
            }
        })
        .onChange(of: isReady, perform: { newValue in
            if !isReady {
                onSleep()
                if activeIndexPath == indexPath {
                    withAnimation(elementNavigationAnimation) {
                        _ = activeIndexPath.removeLast()
                    }
                }
            }
        })
        .onChange(of: activeProperty) { _ in
            onActivePropertyChange()
        }
        .onAppear {
            
            guard isReady else {
                return
            }
            
            onAwake()
            
            if isParentDisclosed {
                onParentDisclosed()
            }
            
            if isDisclosed {
                onDisclose()
            }
            
            if isActive {
                onActive()
            }
            
        }
        .onDisappear {
            guard isReady else {
                return
            }
            
            if isActive {
                onInactive()
            }
            
            if isDisclosed {
                onClose()
            }
            
            if isParentDisclosed {
                onParentClosed()
            }
            
            onSleep()
            
        }
    }
    
    var rearView: some View {
        defaultRearView
    }
    
    var defaultRearView: some View {
        HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
            propertyView
            
            content
                .indexPath(indexPath.appending(0))
                .activeIndexPath(_activeIndexPath.projectedValue)
        }
        .transition(.identity)
    }
    
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
                    Image(systemName: isReady ? "ellipsis" : "minus")
                        .imageScale(.small)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, isReady ? 1.0 : 2.0)
            }
            .scaleEffect(x: textHorizontalScale)
            .preference(key: DisclosedElementsPreferenceKey.self, value: isDisclosed ? [.init(id: id, title: title, subtitle: subtitle, indexPath: indexPath, namespace: namespace)] : [])
    }
    
    var propertyView: some View {
        ForEach(Array(Property.allCases), id: \.self) { prop in
            Text(prop.displayName)
                .font(Font.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: true, vertical: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
                .contentShape(Rectangle())
                .background {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(.systemFill)
                        .visible(prop == activeProperty)
                        .matchedGeometryEffect(id: "Selected", in: namespace, isSource: prop == activeProperty)
                }
                .onTapGesture {
                    withAnimation(elementPropertyNavigationAnimation) {
                        activeProperty = prop
                    }
                }
        }
        .frame(maxWidth: isActive ? .infinity : 0.0)
        .visible(isActive)
        .allowsHitTesting(isActive)
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
    
}


extension Element where ActionView == EmptyView {
    
    var actionView: ActionView {
        .init()
    }
    
}

extension Element where OptionsView == EmptyView {

    var optionsView: OptionsView {
        .init()
    }

}
