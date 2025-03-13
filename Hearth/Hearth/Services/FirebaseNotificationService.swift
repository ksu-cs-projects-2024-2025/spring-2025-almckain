//
//  FirebaseNotificationService.swift
//  Hearth
//
//  Created by Aaron McKain on 3/12/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseMessaging

class FirebaseNotificationService {
    static let shared = FirebaseNotificationService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func updateLastActive() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let userRef = db.collection("users").document(userID)
        userRef.setData(["lastActive": Date().timeIntervalSince1970], merge: true) { error in
            if let error = error {
                print("Error updating last active time: \(error.localizedDescription)")
            }
        }
    }
    
    func registerFCMToken() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM token: \(error.localizedDescription)")
                return
            }
            
            if let token = token {
                self.db.collection("users").document(userID).setData(["fcmToken": token], merge: true) { error in
                    if let error = error {
                        print("Error saving FCM token: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
