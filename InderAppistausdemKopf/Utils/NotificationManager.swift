import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Fordert Berechtigung für Benachrichtigungen an
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Benachrichtigungsberechtigung erteilt")
            } else if let error = error {
                print("Fehler bei Benachrichtigungsberechtigung: \(error)")
            }
        }
    }
    
    /// Plant eine Erinnerung für einen ListItem
    func scheduleReminder(for item: ListItem) {
        guard let dueDate = item.dueDate else { return }
        
        // Entferne vorherige Benachrichtigungen für dieses Item
        cancelReminder(for: item)
        
        let content = UNMutableNotificationContent()
        content.title = "📅 Fälligkeit erreicht"
        content.body = "\(item.title) ist jetzt fällig"
        content.sound = .default
        content.badge = 1
        
        // Erstelle Identifier basierend auf Item-UUID
        let identifier = "reminder_\(item.uuid.uuidString)"
        
        // Erstelle Trigger für den Fälligkeitstermin
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Fehler beim Planen der Erinnerung: \(error)")
            } else {
                print("Erinnerung geplant für \(dueDate)")
            }
        }
    }
    
    /// Entfernt eine geplante Erinnerung
    func cancelReminder(for item: ListItem) {
        let identifier = "reminder_\(item.uuid.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Erinnerung entfernt für \(item.title)")
    }
    
    /// Entfernt alle geplanten Erinnerungen
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print(" Alle Erinnerungen entfernt")
    }
    
    /// Entfernt alle ausgelieferten Benachrichtigungen (Badge-Zähler)
    func clearDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("Alle ausgelieferten Benachrichtigungen entfernt")
    }
    
    /// Setzt den Badge-Zähler zurück
    func clearBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Fehler beim Zurücksetzen des Badge-Zählers: \(error)")
            } else {
                print("Badge-Zähler zurückgesetzt")
            }
        }
    }
    
    /// Überprüft den Benachrichtigungsstatus
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    /// Zeigt eine lokale Benachrichtigung für Tests
    func showTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test-Benachrichtigung"
        content.body = "Die Benachrichtigungen funktionieren!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Fehler bei Test-Benachrichtigung: \(error)")
            } else {
                print("Test-Benachrichtigung geplant")
            }
        }
    }
}
