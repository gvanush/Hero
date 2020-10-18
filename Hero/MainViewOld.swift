//
//  MainView.swift
//  Hero0
//
//  Created by Vanush Grigoryan on 7/24/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

import SwiftUI
import Combine
import MetalKit

struct MainViewOld: View {
    
    @State private var showingSelectLayerSourceView = false
    @State private var showingAssetSelector = false
    @State private var assetSelector = AssetSelector.none
    
    @State private var pickedImage: UIImage?
    @State private var pickedColor = UIColor.black
    
    @Environment(\.scene) var canvas
    @Environment(\.gpu) var gpu
    
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
            HeroSceneView()
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
                    
                    do {
                        let textureLoader = MTKTextureLoader(device: gpu)
                        let texture = try textureLoader.newTexture(cgImage: image.cgImage!, options: nil)
                        
                        let size = min(canvas.viewportSize.x, canvas.viewportSize.y) / 2.0
                        let texRatio = Float(texture.width) / Float(texture.height)
                        
                        let layer = Layer()
                        layer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                        layer.texture = texture
                        canvas.add(layer)
                    } catch {
                        // TODO
                        print("something wrong happened")
                    }
                    
                }
            } else if assetSelector == .color {
                ColorSelector() { color in
                    let layer = Layer()
                    layer.color = color.rgba
                    let size = min(canvas.viewportSize.x, canvas.viewportSize.y) / 2.0
                    layer.size = simd_float2(x: size, y: size)
                    canvas.add(layer)
                }
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainViewOld()
        }
    }
}
