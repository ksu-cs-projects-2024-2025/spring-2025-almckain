//
//  VerseReflectionViewModel.swift
//  Hearth
//
//  Created by Aaron McKain on 2/27/25.
//

import Foundation
import FirebaseAuth

class VerseReflectionViewModel: ObservableObject {
    @Published var isSaving = false
    @Published var error: Error?
    private let reflectionService: VerseReflectionService
    private let auth = Auth.auth()
    
    init(reflectionService: VerseReflectionService = VerseReflectionService()) {
        self.reflectionService = reflectionService
    }
    
    func saveReflection(reference: String, verseText: String, reflectionText: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isSaving else { return }
        isSaving = true
        error = nil
        
        guard let userID = auth.currentUser?.uid else {
            let authError = NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            error = authError
            isSaving = false
            completion(.failure(authError))
            return
        }
        
        let reflection = VerseReflectionModel(
            id: nil,
            userID: userID,
            title: reference,
            bibleVerseText: verseText,
            reflection: reflectionText,
            timeStamp: Date(),
            entryType: .bibleVerseReflection
        )
        
        reflectionService.saveReflection(reflection) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSaving = false
                switch result {
                case .success:
                    self?.error = nil
                    completion(.success(()))
                case .failure(let error):
                    self?.error = error
                    completion(.failure(error))
                }
            }
        }
    }
}
