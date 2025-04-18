//
//  GratitudeService.swift
//  Hearth
//
//  Created by Aaron McKain on 4/17/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class GratitudeService {
    private let db = Firestore.firestore()
    private let collection = "gratitudeEntries"
    
    private var userID: String? {
        Auth.auth().currentUser?.uid
    }
    
    func fetchGratitudeEntries(forMonth date: Date, completion: @escaping ([GratitudeModel]) -> Void) {
        guard let userID else {
            completion([])
            return
        }
        
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            completion([])
            return
        }
        
        db.collection(collection)
            .whereField("userID", isEqualTo: userID)
            .whereField("timeStamp", isGreaterThanOrEqualTo: Timestamp(date: startOfMonth))
            .whereField("timeStamp", isLessThan: Timestamp(date: startOfNextMonth))
            .order(by: "timeStamp", descending: true)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    let entries = documents.compactMap {
                        try? $0.data(as: GratitudeModel.self)
                    }
                    completion(entries)
                } else {
                    completion([])
                }
            }
    }
    
    func saveGratitudeEntry(_ entry: GratitudeModel, completion: @escaping (Bool) -> Void) {
            guard let userID else {
                completion(false)
                return
            }
            
            var entryToSave = entry
            entryToSave.userID = userID
            
            do {
                try db.collection(collection).document(entry.id).setData(from: entryToSave) { error in
                    completion(error == nil)
                }
            } catch {
                print("Error saving GratitudeEntry: \(error)")
                completion(false)
            }
        }
}
