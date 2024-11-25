//
//  NotificationManager.swift
//  Capsule
//
//  Created by Aleck David Holly on 2024-10-31.
//

import Foundation
import UserNotifications
import SwiftUI

@Observable
class NotificationManager {
    static let shared = NotificationManager()
    @ObservationIgnored @AppStorage("notis") var permissionGranted: Bool = false
    
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print(granted ? "Permission OK" : "Permission denied")
        } catch  {
            print("Error on request permission.")
        }
    }
    
    func scheduleNotification(for date: Date, capsuleID: String) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "open-capsule-string")
        content.body = String(localized: "open-capsule-text-string")
        content.sound = .default
        
        // Use all date components to schedule the notification at the specific date and time
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: capsuleID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error while scheduling notification: \(error)")
            } else {
                print("Notification added for \(date)")
            }
        }
    }
    
    func scheduleNotificationAfterAWhile(days: Int) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "create-capsule-string")
        content.body = String(localized: "create-capsule-text-string")
        content.sound = .default
        
        guard let targetDate = Calendar.current.date(byAdding: .day, value: days, to: Date()) else {
            return
        }
        
        // Use all date components to schedule the notification at the specific date and time
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: "inactivityNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error while scheduling notification: \(error)")
            } else {
                print("Weekly notification added for \(targetDate) at midnight")
            }
        }
    }
    
    func cancelNotification() {
        print("Noti deactivated")
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["inactivityNotification"])
    }
}
