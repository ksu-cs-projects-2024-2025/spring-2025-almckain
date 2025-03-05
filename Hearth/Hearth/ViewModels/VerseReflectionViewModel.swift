//
//  VerseReflectionViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/27/25.
//

import Foundation
import FirebaseAuth

class VerseReflectionViewModel: ObservableObject {
    @Published var reflection: VerseReflectionModel?
    @Published var reflectionText: String = ""
    @Published var isSaving = false
    @Published var error: Error?
    
    private let reflectionService: VerseReflectionService
    private let auth = Auth.auth()
    private let reflectionDateKey = "LastReflectionDate"
    private let reflectionTextKey = "SavedReflectionText"
    private let reflectionCacheKey = "CachedVerseReflection"
    
    init(reflectionService: VerseReflectionService = VerseReflectionService()) {
        self.reflectionService = reflectionService
        loadReflectionIfExists()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clearReflectionCache),
                                               name: .dailyBibleVerseUpdated,
                                               object: nil)
    }
    
    @objc private func clearReflectionCache() {
        self.reflection = nil
        self.reflectionText = ""
        UserDefaults.standard.removeObject(forKey: self.reflectionCacheKey)
    }
    
    private func loadReflectionIfExists() {
        guard let data = UserDefaults.standard.data(forKey: reflectionCacheKey) else {
            self.reflection = nil
            self.reflectionText = ""
            return
        }

        do {
            let cachedReflection = try JSONDecoder().decode(VerseReflectionModel.self, from: data)

            if Calendar.current.isDate(cachedReflection.timeStamp, inSameDayAs: Date()) {
                self.reflection = cachedReflection
                self.reflectionText = cachedReflection.reflection
            } else {
                self.reflection = nil
                self.reflectionText = ""
                UserDefaults.standard.removeObject(forKey: reflectionCacheKey)
            }
        } catch {
            UserDefaults.standard.removeObject(forKey: reflectionCacheKey)
        }
    }
    
    func saveReflection(reference: String, verseText: String, reflectionText: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isSaving else {
            return
        }
        
        isSaving = true
        error = nil
        
        guard let userID = auth.currentUser?.uid else {
            let authError = NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            self.error = authError
            self.isSaving = false
            completion(.failure(authError))
            return
        }

        var newReflection = VerseReflectionModel(
            id: nil,
            userID: userID,
            title: reference,
            bibleVerseText: verseText,
            reflection: reflectionText,
            timeStamp: Date(),
            entryType: .bibleVerseReflection
        )
        
        reflectionService.saveReflection(newReflection) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSaving = false
                switch result {
                case .success(let documentID):
                    newReflection.id = documentID
                    self?.reflection = newReflection
                    self?.reflectionText = newReflection.reflection
                    do {
                        let data = try JSONEncoder().encode(newReflection)
                        UserDefaults.standard.set(data, forKey: self?.reflectionCacheKey ?? "CachedVerseReflection")
                    } catch {
                        print("Failed to encode newReflection: \(error)")
                    }
                    completion(.success(()))
                case .failure(let error):
                    self?.error = error
                    completion(.failure(error))
                }
            }
        }
    }

    
    func updateReflection(_ updatedReflection: VerseReflectionModel, completion: @escaping (Result<Void, Error>) -> Void) {
        reflectionService.updateReflection(updatedReflection) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.reflection = updatedReflection
                    self?.reflectionText = updatedReflection.reflection
                    if let data = try? JSONEncoder().encode(updatedReflection) {
                        UserDefaults.standard.set(data, forKey: self?.reflectionCacheKey ?? "CachedVerseReflection")
                    }
                    completion(.success(()))
                case .failure(let error):
                    self?.error = error
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteReflection(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let reflectionToDelete = reflection else {
            completion(.failure(NSError(domain: "Reflection", code: 0, userInfo: [NSLocalizedDescriptionKey: "No reflection to delete"])))
            return
        }
        reflectionService.deleteReflection(reflectionToDelete) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.reflection = nil
                    self?.reflectionText = ""
                    UserDefaults.standard.removeObject(forKey: self?.reflectionCacheKey ?? "CachedVerseReflection")
                    completion(.success(()))
                case .failure(let error):
                    self?.error = error
                    completion(.failure(error))
                }
            }
        }
    }
    
    func manuallyClearReflectionCache() {
        // Clear in-memory state
        self.reflection = nil
        self.reflectionText = ""
        
        // Remove cached data from UserDefaults
        UserDefaults.standard.removeObject(forKey: reflectionCacheKey)
        print("Cache cleared")
    }
}
