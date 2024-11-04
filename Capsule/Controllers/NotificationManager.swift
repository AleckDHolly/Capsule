//
//  NotificationManager.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-31.
//

import Foundation
import UserNotifications

@Observable
class NotificationManager {
    static let shared = NotificationManager()
    var permissionGranted: Bool = false
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print(granted ? "Permission OK" : "Permission denied")
        } catch  {
            print("Error on request permission.")
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Ouvrez une capsule."
        content.body = "Voyez si vous avez une capsule a ouvrir."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: "inactivityNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("Error while scheduling notification.")
            } else {
                print("Notification added.")
            }
        }
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["inactivityNotification"])
    }
}
