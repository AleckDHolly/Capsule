//
//  ContentView.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    private var notificationManager = NotificationManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CreerCapsuleView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(0)
            
            MesCapsulesView()
                .tabItem {
                    Label("My capsules", systemImage: "clock.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .onAppear {
            notificationManager.cancelNotification()
        }
        .onDisappear {
            if notificationManager.permissionGranted {
                notificationManager.scheduleNotification()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Capsule.self)
}
