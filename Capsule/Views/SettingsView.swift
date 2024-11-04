//
//  Settings.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var notificationManager = NotificationManager.shared
    
    var body: some View {
        VStack {
            List {
                Section("Apparence") {
                    Toggle(isOn: $isDarkMode) {
                        Text("Theme Sombre")
                    }
                }
                
                Section("Notifications") {
                    Toggle(isOn: $notificationManager.permissionGranted) {
                        Text("Activer les notifications")
                    }
                    .onChange(of: notificationManager.permissionGranted) { oldValue, newValue in
                        if newValue {
                            notificationManager.scheduleNotification()
                        } else {
                            notificationManager.cancelNotification()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
