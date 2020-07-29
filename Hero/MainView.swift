//
//  MainView.swift
//  Hero0
//
//  Created by Vanush Grigoryan on 7/24/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

import SwiftUI
import Combine


struct MainView: View {
    
    @ObservedObject var world: World
    
    @State private var showingSelectLayerSourceView = false
    @State private var showingAssetSelector = false
    @State private var assetSelector = AssetSelector.none
    
    @State private var pickedImage: UIImage?
    @State private var pickedColor = UIColor.black
    
    enum AssetSelector {
        case image
        case color
        case none
        
        var name: String {
            switch self {
            case .image:
                return "Image"
            case .color:
                return "Color"
            case .none:
                return "None"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
//                if world.surfaces.isEmpty {
//                    Text("Add layer to start!")
//                } else {
//                    WorldView()
//                }
            }
            .navigationBarTitle("Project", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        showingSelectLayerSourceView.toggle()
                    }, label: {
                        Image(systemName: "plus")
                            .padding()
                    })
                    .actionSheet(isPresented: $showingSelectLayerSourceView, content: {
                        
                        let buttons : [ActionSheet.Button] = [
                            .default(Text(AssetSelector.image.name)) {
                                showingAssetSelector = true
                                assetSelector = .image
                            },
                            .default(Text(AssetSelector.color.name)) {
                                showingAssetSelector = true
                                assetSelector = .color
                            },
                            .cancel()]
                        
                        return ActionSheet(title: Text("Select layer source"), message: nil,
                                    buttons: buttons)
                    })
                }
            }
        }
        .sheet(isPresented: $showingAssetSelector, content: {
            if assetSelector == .image {
                ImageSelector() { image in
                    // create layer
                    // convert image to metal texture
                    // set to the layer
                }
            } else if assetSelector == .color {
                ColorSelector(color: $pickedColor)
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(world: World())
        }
    }
}
