//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 22.04.2023.
//

import Foundation

internal final class FeedCachePolicy {
    static let calendar = Calendar(identifier: .gregorian)
    static let maxCacheAgeInDays: Int = 7
    
    private init() {}
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}
