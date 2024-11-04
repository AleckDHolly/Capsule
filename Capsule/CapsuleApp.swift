//
//  CapsuleApp.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI
import SwiftData
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CapsuleApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var notificationManager = NotificationManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Capsule.self)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(notificationManager)
                .task {
                    await notificationManager.requestPermission()
                }
        }
    }
}
