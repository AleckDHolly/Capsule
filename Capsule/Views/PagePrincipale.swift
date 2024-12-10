//
//  PagePrincipale.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-11-03.
//

import SwiftUI

struct PagePrincipale: View {
    @State private var selectedTab: Int = 0
    private let notificationManager = NotificationManager.shared
    private let dbController = DbController.shared
    private let authController = AuthController.shared
    @Environment(\.scenePhase) var scenePhase
    
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
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "mappin.and.ellipse")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .onChange(of: scenePhase) {
            /*if we dont fecth items, when u create a new capsule,
            it will only schedule notification on the non updated
             capsule array see line 49.*/
            dbController.fetchItems()
            notificationActivation()
        }
    }
    
    func showNotification() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM. d yyyy 'at' h:mm a"
        
        for capsule in dbController.capsules {
            if !dbController.isDatePassed(capsule.dateOuverture) {
                if let openingDate = dateFormatter.date(from: capsule.dateOuverture) {
                    notificationManager.scheduleNotification(for: openingDate, capsuleID: capsule.id)
                }
            }
        }
    }
    
    func notificationActivation() {
        switch scenePhase {
        case .active:
            notificationManager.cancelNotification()
            return
        case .inactive:
            if notificationManager.permissionGranted {
                showNotification()
                notificationManager.scheduleNotificationAfterAWhile(days: 5)
            }
            return
        default:
            return
        }
    }
}

#Preview {
    PagePrincipale()
}
