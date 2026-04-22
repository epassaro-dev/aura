import XCTest
import SwiftData
@testable import Aura

final class ManyToManyRelationshipTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testMealEntryFoodItemInverse() throws {
        let meal = MealEntry(date: .now, mealType: .lunch)
        let food = FoodItem(name: "Pasta", sfSymbol: "fork.knife")
        context.insert(meal)
        context.insert(food)
        meal.foodItems.append(food)
        try context.save()

        XCTAssertEqual(food.mealEntries.count, 1)
        XCTAssertEqual(food.mealEntries.first?.mealType, .lunch)
    }

    func testFoodItemSharedAcrossMeals() throws {
        let food = FoodItem(name: "Bread", sfSymbol: "fork.knife")
        let breakfast = MealEntry(date: .now, mealType: .breakfast)
        let lunch = MealEntry(date: .now, mealType: .lunch)
        context.insert(food)
        context.insert(breakfast)
        context.insert(lunch)
        breakfast.foodItems.append(food)
        lunch.foodItems.append(food)
        try context.save()

        XCTAssertEqual(food.mealEntries.count, 2)
    }

    func testHeadacheTriggerInverse() throws {
        let trigger = TriggerType(name: "Dehydration", sfSymbol: "drop.fill")
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        context.insert(trigger)
        context.insert(headache)
        headache.triggers.append(trigger)
        try context.save()

        XCTAssertEqual(trigger.headacheEntries.count, 1)
    }

    func testHeadacheTellingSignInverse() throws {
        let sign = TellingSignType(name: "Visual aura", sfSymbol: "eye.fill")
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        context.insert(sign)
        context.insert(headache)
        headache.tellingSigns.append(sign)
        try context.save()

        XCTAssertEqual(sign.headacheEntries.count, 1)
    }

    func testDeletingTriggerTypeRemovesItFromHeadache() throws {
        let trigger = TriggerType(name: "Loud noise", sfSymbol: "speaker.wave.3.fill")
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        context.insert(trigger)
        context.insert(headache)
        headache.triggers.append(trigger)
        try context.save()

        context.delete(trigger)
        try context.save()

        let headaches = try context.fetch(FetchDescriptor<HeadacheEntry>())
        XCTAssertEqual(headaches.count, 1, "HeadacheEntry should survive deletion of a trigger type")
        XCTAssertTrue(headaches.first!.triggers.isEmpty)
    }
}
