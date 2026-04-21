import XCTest
import SwiftData
@testable import Aura

private func makeContainer() throws -> ModelContainer {
    let schema = Schema([
        FeelingType.self, TriggerType.self, SymptomType.self,
        Medicine.self, FoodItem.self, ActivityType.self,
        TellingSignType.self, ReliefMethodType.self,
        SleepEntry.self, FeelingEntry.self, MedicineLog.self,
        ActivityEntry.self, MealEntry.self, TriggerEntry.self,
        SymptomEntry.self, HeadacheEntry.self, HeadachePainLog.self,
        HeadacheSymptomLog.self, HeadacheMedicineLog.self,
        HeadacheReliefLog.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}

// MARK: - Cascade Deletes

final class HeadacheCascadeDeleteTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testDeletingHeadacheDeletesPainLogs() throws {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        let painLog = HeadachePainLog(timestamp: .now, intensity: 7, affectedAreas: [.forehead])
        context.insert(headache)
        context.insert(painLog)
        headache.painLogs.append(painLog)
        try context.save()

        context.delete(headache)
        try context.save()

        let painLogs = try context.fetch(FetchDescriptor<HeadachePainLog>())
        XCTAssertTrue(painLogs.isEmpty)
    }

    func testDeletingHeadacheDeletesSymptomLogs() throws {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        let symptomLog = HeadacheSymptomLog(timestamp: .now)
        context.insert(headache)
        context.insert(symptomLog)
        headache.symptoms.append(symptomLog)
        try context.save()

        context.delete(headache)
        try context.save()

        let symptomLogs = try context.fetch(FetchDescriptor<HeadacheSymptomLog>())
        XCTAssertTrue(symptomLogs.isEmpty)
    }

    func testDeletingHeadacheDeletesMedicineLogs() throws {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        let medicineLog = HeadacheMedicineLog(timestamp: .now)
        context.insert(headache)
        context.insert(medicineLog)
        headache.medications.append(medicineLog)
        try context.save()

        context.delete(headache)
        try context.save()

        let medicineLogs = try context.fetch(FetchDescriptor<HeadacheMedicineLog>())
        XCTAssertTrue(medicineLogs.isEmpty)
    }

    func testDeletingHeadacheDeletesReliefLogs() throws {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        let reliefLog = HeadacheReliefLog(timestamp: .now)
        context.insert(headache)
        context.insert(reliefLog)
        headache.reliefMethods.append(reliefLog)
        try context.save()

        context.delete(headache)
        try context.save()

        let reliefLogs = try context.fetch(FetchDescriptor<HeadacheReliefLog>())
        XCTAssertTrue(reliefLogs.isEmpty)
    }
}

// MARK: - Catalog Nullify

final class CatalogNullifyTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testDeletingFeelingTypeNullifiesFeelingEntry() throws {
        let feelingType = FeelingType(name: "Anxious", sfSymbol: "brain.head.profile")
        let entry = FeelingEntry(date: .now, feelingType: feelingType, intensity: 3)
        context.insert(feelingType)
        context.insert(entry)
        try context.save()

        context.delete(feelingType)
        try context.save()

        let entries = try context.fetch(FetchDescriptor<FeelingEntry>())
        XCTAssertEqual(entries.count, 1, "FeelingEntry should survive deletion of its type")
        XCTAssertNil(entries.first?.feelingType)
    }

    func testDeletingSymptomTypeNullifiesSymptomEntry() throws {
        let symptomType = SymptomType(name: "Nausea", sfSymbol: "waveform.path.ecg")
        let entry = SymptomEntry(date: .now, symptomType: symptomType)
        context.insert(symptomType)
        context.insert(entry)
        try context.save()

        context.delete(symptomType)
        try context.save()

        let entries = try context.fetch(FetchDescriptor<SymptomEntry>())
        XCTAssertEqual(entries.count, 1, "SymptomEntry should survive deletion of its type")
        XCTAssertNil(entries.first?.symptomType)
    }

    func testDeletingTriggerTypeNullifiesTriggerEntry() throws {
        let triggerType = TriggerType(name: "Stress", sfSymbol: "bolt.fill")
        let entry = TriggerEntry(date: .now, triggerType: triggerType)
        context.insert(triggerType)
        context.insert(entry)
        try context.save()

        context.delete(triggerType)
        try context.save()

        let entries = try context.fetch(FetchDescriptor<TriggerEntry>())
        XCTAssertEqual(entries.count, 1, "TriggerEntry should survive deletion of its type")
        XCTAssertNil(entries.first?.triggerType)
    }

    func testDeletingMedicineNullifiesMedicineLog() throws {
        let medicine = Medicine(name: "Ibuprofen", sfSymbol: "pills.fill", defaultDosage: "400mg")
        let log = MedicineLog(date: .now, timestamp: .now, medicine: medicine)
        context.insert(medicine)
        context.insert(log)
        try context.save()

        context.delete(medicine)
        try context.save()

        let logs = try context.fetch(FetchDescriptor<MedicineLog>())
        XCTAssertEqual(logs.count, 1, "MedicineLog should survive deletion of its medicine")
        XCTAssertNil(logs.first?.medicine)
    }
}

// MARK: - Many-to-Many Relationships

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

// MARK: - Default Values

final class CatalogDefaultValueTests: XCTestCase {
    func testCatalogItemDefaultValues() {
        let feeling = FeelingType(name: "Happy", sfSymbol: "face.smiling")
        XCTAssertFalse(feeling.isDefault)
        XCTAssertFalse(feeling.isArchived)
    }

    func testMedicineDefaultValues() {
        let medicine = Medicine(name: "Aspirin", sfSymbol: "pills")
        XCTAssertFalse(medicine.isDefault)
        XCTAssertFalse(medicine.isArchived)
        XCTAssertNil(medicine.defaultDosage)
    }

    func testHeadacheEntryDefaultValues() {
        let headache = HeadacheEntry(startTime: .now, headacheType: .migraine)
        XCTAssertNil(headache.endTime)
        XCTAssertTrue(headache.painLogs.isEmpty)
        XCTAssertTrue(headache.symptoms.isEmpty)
        XCTAssertTrue(headache.medications.isEmpty)
        XCTAssertTrue(headache.reliefMethods.isEmpty)
        XCTAssertTrue(headache.triggers.isEmpty)
        XCTAssertTrue(headache.tellingSigns.isEmpty)
    }
}
