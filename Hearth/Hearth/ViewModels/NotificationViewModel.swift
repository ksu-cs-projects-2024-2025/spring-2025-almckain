//
//  NotificationViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 3/12/25.
//

import SwiftUI
import UserNotifications

class NotificationViewModel: ObservableObject {
    @Published var notificationsEnabled = false
    @Published var dailyJournalTime = Date()
    @Published var bibleVerseTime = Date()
    @Published var showNotificationAlert = false
    @Published var weeklyReflectionTime = Date()
    
    @Published var shouldShowReflectionCard = true
    
    @AppStorage("didAnimateInThisSunday") var didAnimateInThisSunday = false
    @AppStorage("didAnimateOutThisMonday") var didAnimateOutThisMonday = false
    
    private var hasRequestedBefore: Bool {
        get { UserDefaults.standard.bool(forKey: "HasRequestedNotificationsBefore") }
        set { UserDefaults.standard.set(newValue, forKey: "HasRequestedNotificationsBefore") }
    }

    
    init() {
        //checkNotificationStatus()
        loadSavedReminderTimes()
        FirebaseNotificationService.shared.registerFCMToken()
    }
    
    // MARK: - Checking & Requesting for notification permissions
    
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
    
    // MARK: - Weekly Reflection Logic
    
    func updateReflectionCardVisibility() {
        let isSundayAfter9 = Date().isSunday && Date().isAfter9AM
        let isMonday = Date().isMonday
        
        // Reset Sunday didAnimateIn if its sunday BEFORE 9am
        //                              or if its a new Sunday
        if Date().isSunday && !Date().isAfter9AM {
            didAnimateInThisSunday = false
            shouldShowReflectionCard = false
        }
        
        // Reset Monday "didAnimateOut" if its a new Monday
        if isMonday {
            didAnimateOutThisMonday = false
        }
        
        // Sunday logic - If its after 9am and not yet animated in then set it to show
        if isSundayAfter9 && !didAnimateInThisSunday {
            shouldShowReflectionCard = true
            didAnimateInThisSunday = true
        }
        // If its sunday after 9 and its already animated in then keep it visible with no animation
        else if isSundayAfter9 && didAnimateInThisSunday {
            shouldShowReflectionCard = true
        }
        // Monday logic - if its Monday and the card is currently visible and we havent animated out set the card to hidden
        else if isMonday && shouldShowReflectionCard && !didAnimateOutThisMonday {
            shouldShowReflectionCard = false
            didAnimateOutThisMonday = true
        }
    }
    
    // MARK: - Shedule notification times
    
    private func scheduleWeeklyReflectionNotification(date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Reflection"
        content.body = "It's Sunday! Check out your highest impact journal entry from this week."
        content.sound = .default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        dateComponents.weekday = 1
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weeklyReflectionReminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekly reflection reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleReminders() {
        scheduleNotification(title: "Daily Journal Reminder", body: "Don't forget to add to your journal today!", date: dailyJournalTime, identifier: "dailyJournalReminder")
        scheduleNotification(title: "New Bible Verse", body: "A new Bible verse is ready for you.", date: bibleVerseTime, identifier: "bibleVerseReminder")
        
        scheduleWeeklyReflectionNotification(date: weeklyReflectionTime)
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
        UserDefaults.standard.set(weeklyReflectionTime, forKey: "WeeklyReflectionReminderTime")
    }
    
    private func loadSavedReminderTimes() {
        if let journalTime = UserDefaults.standard.object(forKey: "DailyJournalReminderTime") as? Date {
            dailyJournalTime = journalTime
        }
        
        if let verseTime = UserDefaults.standard.object(forKey: "BibleVerseReminderTime") as? Date {
            bibleVerseTime = verseTime
        }
        
        // FOR THE ALGORITHM
        if let reflectionTime = UserDefaults.standard.object(forKey: "WeeklyReflectionReminderTime") as? Date {
            weeklyReflectionTime = reflectionTime
        } else {
            // Default reflection time should (finger crossed) be 9am
            weeklyReflectionTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
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
