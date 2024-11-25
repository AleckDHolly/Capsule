//
//  ContentView.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-30.
//

import SwiftUI

struct ContentView: View {
    private var authController = AuthController.shared
    private let notificationManager = NotificationManager.shared
    private var locationManger = LocationManager.shared
    
    var body: some View {
        Group {
            if authController.user != nil {
                PagePrincipale()
                    .task {
                        await notificationManager.requestPermission()
                    }
                    .onAppear {
                        print(authController.users)
                    }
            } else {
                SignUpView()
            }
        }
    }
}

#Preview {
    ContentView()
}
