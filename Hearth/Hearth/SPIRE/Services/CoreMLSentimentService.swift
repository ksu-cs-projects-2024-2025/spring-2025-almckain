//
//  CoreMLSentimentService.swift
//  Hearth
//
//  Created by Aaron McKain on 3/18/25.
//

import SwiftUI
import NaturalLanguage
import CoreML

class CoreMLSentimentService {
    static let shared = CoreMLSentimentService()
    private let sentimentModel: SentimentAnalyzer
    
    private init() {
        let config = MLModelConfiguration()
        sentimentModel = try! SentimentAnalyzer(configuration: config)
    }
    
    func scoreForText(_ text: String) -> Double {
        guard let prediction = try? sentimentModel.prediction(text: text) else {
            return 0.0
        }
        
        switch prediction.label.lowercased() {
        case "negative":
            return -1.0
        case "positive":
            return 1.0
        default:
            return 0.0
        }
    }
}
