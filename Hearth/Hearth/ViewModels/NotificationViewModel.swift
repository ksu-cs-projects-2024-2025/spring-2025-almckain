//
//  NotificationViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 3/12/25.
//

import Foundation
import UserNotifications

class NotificationViewModel: ObservableObject {
    @Published var notificationsEnabled = false
    @Published var dailyJournalTime = Date()
    @Published var bibleVerseTime = Date()
    @Published var showNotificationAlert = false
    
    private var hasRequestedBefore: Bool {
        get { UserDefaults.standard.bool(forKey: "HasRequestedNotificationsBefore") }
        set { UserDefaults.standard.set(newValue, forKey: "HasRequestedNotificationsBefore") }
    }

    
    init() {
        //checkNotificationStatus()
        loadSavedReminderTimes()
        FirebaseNotificationService.shared.registerFCMToken()
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    if !self.hasRequestedBefore {
                        self.hasRequestedBefore = true
                        self.requestNotificationPermission()
                    }
                case .denied:
                    self.notificationsEnabled = false
                    self.showNotificationAlert = true
                case .authorized, .provisional, .ephemeral:
                    self.notificationsEnabled = true
                @unknown default:
                    self.notificationsEnabled = false
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
                if granted {
                    self.scheduleReminders()
                }
            }
        }
    }
    
    func scheduleReminders() {
        scheduleNotification(title: "Daily Journal Reminder", body: "Don't forget to add to your journal today!", date: dailyJournalTime, identifier: "dailyJournalReminder")
        scheduleNotification(title: "New Bible Verse", body: "A new Bible verse is ready for you.", date: bibleVerseTime, identifier: "bibleVerseReminder")
        saveReminderTimes()
    }
    
    private func scheduleNotification(title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        let triggerDate = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveReminderTimes() {
        UserDefaults.standard.set(dailyJournalTime, forKey: "DailyJournalReminderTime")
        UserDefaults.standard.set(bibleVerseTime, forKey: "BibleVerseReminderTime")
    }
    
    private func loadSavedReminderTimes() {
        if let journalTime = UserDefaults.standard.object(forKey: "DailyJournalReminderTime") as? Date {
            dailyJournalTime = journalTime
        }
        
        if let verseTime = UserDefaults.standard.object(forKey: "BibleVerseReminderTime") as? Date {
            bibleVerseTime = verseTime
        }
    }
    
    func syncUserActivity() {
        FirebaseNotificationService.shared.updateLastActive()
    }
    
    func resetNotificationState() {
        UserDefaults.standard.removeObject(forKey: "DailyJournalReminderTime")
        UserDefaults.standard.removeObject(forKey: "BibleVerseReminderTime")
        notificationsEnabled = false
        dailyJournalTime = Date()
        bibleVerseTime = Date()
    }

}
