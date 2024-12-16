//
//  Kei3MapAppApp.swift
//  Kei3MapApp
//
//  Created by Kei on 2024/12/08.
//

import Feature
import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Kei3MapAppApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
//       MapView().padding()
//      SigninView().padding()
      RootView()
    }
  }
}
