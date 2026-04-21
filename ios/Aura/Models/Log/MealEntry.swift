import Foundation
import SwiftData

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case brunch
    case lunch
    case snack
    case dinner
}

@Model final class MealEntry {
    var date: Date
    var mealType: MealType

    @Relationship var foodItems: [FoodItem] = []

    init(date: Date, mealType: MealType) {
        self.date = date
        self.mealType = mealType
    }
}
