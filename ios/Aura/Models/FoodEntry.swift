import Foundation
import SwiftData

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var systemImage: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
}

@Model
final class FoodEntry {
    var mealType: MealType
    /// Individual food items for this meal.
    var items: [String]
    var eatenAt: Date
    var notes: String

    var dailyLog: DailyLog?

    init(
        mealType: MealType = .breakfast,
        items: [String] = [],
        eatenAt: Date = .now,
        notes: String = ""
    ) {
        self.mealType = mealType
        self.items = items
        self.eatenAt = eatenAt
        self.notes = notes
    }
}

