//
//  ContentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.10.21.
//

import SwiftUI

struct TransformView: View {
    
    @State var tool = Tool.move
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Toolbar(selection: $tool)
                }
            }
            .navigationTitle(tool.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        // TODO: Remove when the bug is fixed (Needed to avoid iOS auto-layout warnings)
        .navigationViewStyle(.stack)
        .accentColor(.indigo)
    }
    
    enum Tool: CaseIterable, Identifiable {
        
        case move
        case orient
        case scale
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .move:
                return "Move"
            case .orient:
                return "Orient"
            case .scale:
                return "Scale"
            }
        }
        
        var image: String {
            switch self {
            case .move:
                return "move.3d"
            case .orient:
                return "rotate.3d"
            case .scale:
                return "scale.3d"
            }
        }
    }
    
    struct Toolbar: View {
        
        var selection: Binding<Tool>
        
        var body: some View {
            HStack(spacing: 0.0) {
                ForEach(Tool.allCases) { tool in
                    item(title: tool.title, image: tool.image)
                        .foregroundColor(selection.wrappedValue == tool ? .accentColor : .gray)
                        .onTapGesture {
                            selection.wrappedValue = tool
                        }
                }
            }
            .padding(.top, Self.topPadding)
            .background(.bar)
        }
        
        static let topPadding = 4.0
        
        func item(title: String, image: String) -> some View {
            Label(title, systemImage: image)
                .labelStyle(ItemLabelStyle())
                .frame(maxWidth: .infinity, minHeight: Self.itemHeight)
        }
        
        static let itemHeight = 44.0
        
        struct ItemLabelStyle: LabelStyle {
            func makeBody(configuration: Configuration) -> some View {
                VStack(alignment: .center, spacing: Self.iconTextSpacing) {
                    configuration.icon.imageScale(.large)
                    configuration.title.font(.system(.caption2))
                }
            }
            
            static let iconTextSpacing = 2.0
        }
        
    }
    
}

struct TransformView_Previews: PreviewProvider {
    static var previews: some View {
        TransformView()
    }
}
