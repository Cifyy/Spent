//
//  entryItem.swift
//  spent
//
//  Created by Jakub Majka on 13/10/24.
//

import SwiftUI
import Foundation
import SwiftData
import Observation

let DEFAULT_DATE = ISO8601DateFormatter().date(from:"2016-04-14T10:44:00+0000")!

@Model
class SpentItem{
    
    var id = UUID()
    var category: spentCategory = spentCategory.other
    var amount: Double = 0.0
    var precisedate: Date = DEFAULT_DATE
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var friendlyName: String = "No familiar name found"
    @Relationship(inverse: \DayHistory.spentItems) var dayCategory: DayHistory = DayHistory(date: DEFAULT_DATE)
    
    init( category: spentCategory, amount: Double, precisedate: Date, latitude: Double = 0, longitude: Double = 0, friendlyName: String, dayCategory: DayHistory) {
        self.category = category
        self.amount = amount
        self.precisedate = precisedate
        self.latitude = latitude
        self.longitude = longitude
        self.friendlyName = friendlyName
        self.dayCategory = dayCategory
    }
}

@Model
class DayHistory{
    
    var id = UUID()
    @Attribute(.unique) var date: Date = DEFAULT_DATE
    @Relationship(deleteRule: .cascade) var spentItems: [SpentItem] = [SpentItem]()
    
    var totalSpent: Double{
        var total = 0.0
        for item in spentItems{
            total += item.amount
        }
        return total
    }
    
    init(date: Date) {
        self.date = date
        spentItems = [SpentItem]()
    }
}

enum spentCategory: String, Identifiable, Codable, CaseIterable {
    
    case food
    case entertainment
    case tech
    case travel
    case shopping
    case other
    var id: Self { self }
}

enum spentFilters: String, Identifiable, Codable, CaseIterable {
    case All
    case food
    case entertainment
    case tech
    case travel
    case shopping
    case other
    var id: Self { self }
}
