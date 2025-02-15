//
//  BibleVerseServiceProtocol.swift
//  Hearth
//
//  Created by Aaron McKain on 2/13/25.
//

import Foundation
import Combine

protocol BibleVerseServiceProtocol {
    func fetchVerse(from url: URL) -> AnyPublisher<BibleVerseModel, Error>
}

class BibleVerseService: BibleVerseServiceProtocol {
    func fetchVerse(from url: URL) -> AnyPublisher<BibleVerseModel, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                
                return output.data
            }
            .decode(type: BibleVerseModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
