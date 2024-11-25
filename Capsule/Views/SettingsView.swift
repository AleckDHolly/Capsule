//
//  Settings.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Bindable private var notificationManager = NotificationManager.shared
    private var authModel = AuthController.shared
    
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
                }
                
                Button {
                    authModel.signOut()
                } label: {
                    Text("Sign out")
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
