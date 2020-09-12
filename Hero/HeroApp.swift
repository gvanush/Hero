//
//  HeroApp.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI

struct CanvasKey: EnvironmentKey {
    typealias Value = Canvas
    
    static var defaultValue = Canvas()
}

extension EnvironmentValues {
    var canvas: Canvas {
        get { self[CanvasKey.self] }
        set { self[CanvasKey.self] = newValue }
    }
}

struct GpuKey: EnvironmentKey {
    typealias Value = MTLDevice
    
    static var defaultValue = RenderingContext.device()
}

extension EnvironmentValues {
    var gpu: MTLDevice {
        get { self[GpuKey.self] }
        set { self[GpuKey.self] = newValue }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // MARK: This is a workaround to be able to change SwiftUI action sheet button colors
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.systemIndigo
        
        try! ProjectDAO.shared.setup()
        
        return true
    }
}

@main
struct HeroApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.canvas, Canvas())
                .environment(\.gpu, RenderingContext.device())
            
        }
    }
}
