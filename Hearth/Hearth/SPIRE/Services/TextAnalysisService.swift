//
//  TextAnalysisService.swift
//  Hearth
//
//  Created by Aaron McKain on 3/18/25.
//

import SwiftUI
import NaturalLanguage

class TextAnalysisService {
    static func analyzeAllEntriesConcurrently(_ entries: [JournalEntryModel]) async -> [JournalReflectionModel] {
        let rawData = await withTaskGroup(of: (String, SPIRERawMetrics).self) { group -> [(String, SPIRERawMetrics)] in
            for entry in entries {
                group.addTask {
                    let singlePassRaw = abs(self.analyzeSentiment(entry.content))
                    let sentenceLevelRaw = self.averageAbsoluteSentenceSentiment(entry.content)
                    let combinedRawSentiment = 0.7 * singlePassRaw + 0.3 * sentenceLevelRaw
                    
                    let rawPronoun = self.calculatePronounDensity(entry.content)
                    let rawInsight = self.analyzeInsightfulKeywords(entry.content)
                    
                    let (temporalMatches, punctuationCount, paragraphCount) = self.analyzeRelevanceRhythm(entry.content)
                    let rawRelevance = temporalMatches + punctuationCount + paragraphCount
                    
                    let rawEngagement = Double(entry.content.split(separator: " ").count)
                    
                    let metrics = SPIRERawMetrics(
                        sentiment: combinedRawSentiment,
                        pronounDensity: rawPronoun,
                        insight: rawInsight,
                        relevance: rawRelevance,
                        engagement: rawEngagement
                    )
                    
                    return (entry.id, metrics)
                }
            }
            
            var collected: [(String, SPIRERawMetrics)] = []
            for await result in group {
                collected.append(result)
            }
            return collected
        }
        
        return self.normalizeAndCreateReflections(rawData, entries: entries)
    }
    
    private static func analyzeSentiment(_ text: String) -> Double {
        let rawScore = CoreMLSentimentService.shared.scoreForText(text)
        return rawScore
    }
    
    private static func averageAbsoluteSentenceSentiment(_ text: String) -> Double {
        let sentences = getSentences(from: text)
        guard !sentences.isEmpty else { return 0.0 }
        
        var scores: [Double] = []
        
        for sentence in sentences {
            let sentenceScore = analyzeSingleSentenceSentiment(sentence)
            scores.append(abs(sentenceScore))
        }
        return scores.reduce(0.0, +) / Double(scores.count)
    }
    
    private static func getSentences(from text: String) -> [String] {
        var sentences = [String]()
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .sentence,
                             scheme: .lexicalClass) { _, range in
            let sentence = text[range].trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
            return true
        }
        return sentences
    }
    
    private static func analyzeSingleSentenceSentiment(_ text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        if let sentimentTag = tagger.tag(at: text.startIndex,
                                         unit: .paragraph,
                                         scheme: .sentimentScore).0 {
            return Double(sentimentTag.rawValue) ?? 0.0
        }
        return 0.0
    }
    
    private static func calculatePronounDensity(_ text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        let firstPersonPronouns: Set<String> = [
            "i", "me", "my", "mine", "myself",
            "i'm", "i've", "i'd", "i'll",
            "im", "ive", "id", "ill"
        ]
        
        var pronounCount = 0
        var wordCount = 0
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: .lexicalClass,
                             options: [.omitWhitespace, .omitPunctuation]) { tag, range in
            let word = text[range].lowercased()
            if let tag = tag, tag == .pronoun, firstPersonPronouns.contains(word) {
                pronounCount += 1
            }
            wordCount += 1
            return true
        }
        
        return wordCount > 0 ? (Double(pronounCount) / Double(wordCount)) * 100 : 0.0
    }
    
    private static func analyzeInsightfulKeywords(_ text: String) -> Double {
        let impactfulWords: [String: Double] = [
            "crisis": 3.0, "trauma": 3.0, "grief": 3.0, "suicide": 3.0,
            "diagnosis": 3.0, "assault": 3.0, "victory": 3.0, "miracle": 3.0,
            "revelation": 3.0, "awakening": 3.0, "transformation": 3.0,
            "tragedy": 3.0, "catastrophe": 3.0, "meltdown": 3.0, "breakdown": 3.0,
            
            "panic": 3.0, "despair": 2.5, "obsession": 2.5, "addiction": 3.0,
            "euphoria": 2.5, "fervor": 2.5, "rage": 2.5, "terror": 2.5,
            "heartbreak": 2.5, "hysteria": 2.5, "devastation": 2.5, "paranoia": 2.5,
            
            "betrayal": 3.0, "abandonment": 3.0, "divorce": 2.5, "rejection": 2.5,
            "infatuation": 2.0, "intimacy": 2.0, "proposal": 2.5, "wedding": 2.0,
            "heartache": 2.5, "loneliness": 2.5, "separation": 2.5, "infidelity": 3.0,
            
            "layoff": 2.5, "promotion": 2.0, "degree": 2.0, "bankruptcy": 3.0,
            "award": 2.0, "deadline": 1.5, "interview": 1.5, "presentation": 1.5,
            "resignation": 2.5, "unemployment": 2.5, "entrepreneur": 2.0, "mentorship": 2.0,
            
            "relapse": 3.0, "recovery": 2.5, "surgery": 2.5, "pregnancy": 2.5,
            "fracture": 2.0, "migraine": 2.0, "allergy": 1.5, "exercise": 1.0,
            "insomnia": 2.5, "therapy": 2.0, "rehabilitation": 2.5, "disorder": 3.0,
            
            "breakthrough": 3.0, "renaissance": 2.5, "healing": 2.0, "forgiveness": 2.0,
            "meditation": 1.5, "mindfulness": 1.5, "resilience": 2.0, "purpose": 2.0,
            "wisdom": 2.0, "enlightenment": 2.5, "self-discovery": 2.0, "transcendence": 2.5,
            
            "failure": 2.0, "guilt": 2.5, "shame": 2.5, "humiliation": 2.5,
            "worthlessness": 2.5, "emptiness": 2.0, "numbness": 2.0,
            "desolation": 2.5, "self-doubt": 2.0, "hopelessness": 2.5,
            
            "bliss": 2.5, "serenity": 2.0, "compassion": 2.0, "generosity": 1.5,
            "altruism": 2.0, "contentment": 1.5, "pride": 2.0, "confidence": 2.0,
            "gratefulness": 2.0, "tranquility": 2.0, "satisfaction": 1.5, "harmony": 2.0,
            
            "overcome": 2.5, "persevere": 2.0, "surrender": 2.0, "resist": 2.0,
            "achieve": 2.0, "sacrifice": 2.5, "abandon": 2.5, "persist": 2.0,
            "conquer": 2.5, "struggle": 2.5, "embrace": 2.0, "adapt": 2.0,
            
            "realization": 2.0, "insight": 2.0, "dilemma": 2.0, "paradox": 2.0,
            "bias": 2.0, "assumption": 1.5, "perspective": 1.5, "analysis": 1.0,
            "epiphany": 2.5, "reflection": 2.0, "comprehension": 1.5, "rationalization": 2.0,
            
            "anxiety": 2.5, "dread": 2.5, "fear": 2.5, "phobia": 3.0,
            "worry": 2.0, "doubt": 2.0, "insecurity": 2.5, "nightmare": 2.5,
            
            "aspiration": 2.0, "dream": 2.0, "motivation": 2.5, "inspiration": 2.5,
            "goal": 2.0, "vision": 2.0, "ambition": 2.5, "drive": 2.0,
            
            "activism": 2.0, "protest": 2.5, "revolution": 2.5, "justice": 2.5,
            "discrimination": 3.0, "prejudice": 2.5, "advocacy": 2.0, "charity": 2.0,
            
            "romance": 2.0, "affection": 2.0, "passion": 2.5, "devotion": 2.5,
            "loyalty": 2.0, "kindness": 1.5, "bond": 2.0, "trust": 2.5,
            
            "mourning": 3.0, "bereavement": 3.0, "loss": 2.5, "farewell": 2.5,
            "regret": 2.5, "parting": 2.5, "sorrow": 2.5, "lament": 2.5
        ]
        
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        
        var totalScore = 0.0
        var totalWords = 0
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .word,
                             scheme: .lemma,
                             options: [.omitWhitespace, .omitPunctuation]) { tag, range in
            let lemma = tag?.rawValue ?? text[range].lowercased()
            if let weight = impactfulWords[lemma] {
                totalScore += weight
            }
            totalWords += 1
            return true
        }
        
        return totalWords > 0 ? min(1.0, totalScore / Double(totalWords)) : 0.0
    }
    
    private static func analyzeRelevanceRhythm(_ text: String) -> (Double, Double, Double) {
        let temporalWords = [
            "today", "now", "currently", "presently", "at this moment", "right now", "at the moment",
            "this morning", "this afternoon", "this evening", "tonight", "earlier today",
            "yesterday", "last night", "earlier", "just now", "a moment ago", "recently",
            "this week", "this month", "this semester", "this quarter", "this year",
            "tomorrow", "soon", "later today", "in a bit", "shortly",
            "always", "never", "often", "sometimes", "occasionally", "rarely",
            "meanwhile", "in the meantime", "afterwards", "eventually",
            "lately", "these days", "for now", "still", "yet"
        ]
        let punctuationCharacters = "!?"
        let lowercasedText = text.lowercased()
        
        let relevanceMatches = temporalWords.filter { lowercasedText.contains($0) }.count
        let punctuationCount = text.filter { punctuationCharacters.contains($0) }.count
        let paragraphCount = self.paragraphCount(text)
        
        return (Double(relevanceMatches), Double(punctuationCount), Double(paragraphCount))
    }
    
    private static func paragraphCount(_ text: String) -> Int {
        var count = 0
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        tagger.enumerateTags(in: text.startIndex..<text.endIndex,
                             unit: .paragraph,
                             scheme: .lexicalClass) { _, _ in
            count += 1
            return true
        }
        return count
    }
    
    private static func minMaxNormalize(_ value: Double, min: Double, max: Double) -> Double {
        guard max > min else { return 0.0 }
        return (value - min) / (max - min)
    }
    
    private static func normalizeAndCreateReflections(_ rawData: [(String, SPIRERawMetrics)],
                                                      entries: [JournalEntryModel]) -> [JournalReflectionModel] {
        
        let minSentiment = rawData.map { $0.1.sentiment }.min() ?? 0
        let maxSentiment = rawData.map { $0.1.sentiment }.max() ?? 1
        
        let minPronoun = rawData.map { $0.1.pronounDensity }.min() ?? 0
        let maxPronoun = rawData.map { $0.1.pronounDensity }.max() ?? 1
        
        let minInsight = rawData.map { $0.1.insight }.min() ?? 0
        let maxInsight = rawData.map { $0.1.insight }.max() ?? 1
        
        let minRelevance = rawData.map { $0.1.relevance }.min() ?? 0
        let maxRelevance = rawData.map { $0.1.relevance }.max() ?? 1
        
        let minEngagement = rawData.map { $0.1.engagement }.min() ?? 0
        let maxEngagement = rawData.map { $0.1.engagement }.max() ?? 1
        
        var reflections: [JournalReflectionModel] = []
        
        for entry in entries {
            guard let raw = rawData.first(where: { $0.0 == entry.id })?.1 else { continue }
            
            let normSentiment  = minMaxNormalize(raw.sentiment,      min: minSentiment,   max: maxSentiment)
            let normPronoun    = minMaxNormalize(raw.pronounDensity, min: minPronoun,     max: maxPronoun)
            let normInsight    = minMaxNormalize(raw.insight,        min: minInsight,     max: maxInsight)
            let normRelevance  = minMaxNormalize(raw.relevance,      min: minRelevance,   max: maxRelevance)
            
            let logEngagement = log(raw.engagement + 1) / log(Double(maxEngagement) + 1)
            let normEngagement = max(0, min(1.0, logEngagement))
            
            let spireScore = (normSentiment * 0.4)
            + (normPronoun   * 0.1)
            + (normInsight   * 0.3)
            + (normRelevance * 0.1)
            + (normEngagement * 0.2)
            
            let sentenceSentiment = averageAbsoluteSentenceSentiment(entry.content)
            
            let reflection = JournalReflectionModel(
                entryID: entry.id,
                title: entry.title,
                content: entry.content,
                reflectionContent: "",
                timestamp: entry.timeStamp,
                spireScore: spireScore
            )
            
            reflections.append(reflection)
            
            print("----- Analysis for Entry: \(entry.title) (ID: \(entry.id)) -----")
            print("    Pronoun Score: \(String(format: "%.2f", normPronoun))")
            print("    Insight Score: \(String(format: "%.2f", normInsight))")
            print("    Relevance Score: \(String(format: "%.2f", normRelevance))")
            print("    Engagement Score: \(String(format: "%.2f", normEngagement))")
            print("    Single Pass Sentiment: \(String(format: "%.2f", normSentiment))")
            print("    Sentence-Level Sentiment: \(String(format: "%.2f", sentenceSentiment))")
            print("    SPIRE Score: \(String(format: "%.2f", spireScore))\n")
        }
        
        return reflections
    }
}
