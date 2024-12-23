//
//  NotificationService.swift
//  MoneyCheck
//
//  Created by Максим Билык on 12.12.2024.
//
import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard granted else { return }
            self.notificationCenter.getNotificationSettings { settings in
                print(settings)
            }
        }
    }
    
    func sendNotification(title: String, body: String, delay: TimeInterval = 1) {
        let notificationsEnabled = UserDefaults.standard.bool(forKey: "enableNotifications")
        guard notificationsEnabled else {
            print("Notifications are disabled")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
