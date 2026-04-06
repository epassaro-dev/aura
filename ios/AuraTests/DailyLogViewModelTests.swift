import XCTest
import SwiftData
@testable import Aura

@MainActor
final class DailyLogViewModelTests: AuraTestCase {

    private var viewModel: DailyLogViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = DailyLogViewModel(modelContext: modelContext)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    // MARK: - Log creation

    func testFetchOrCreateCreatesTodaysLog() {
        let today = Calendar.current.startOfDay(for: .now)
        XCTAssertNotNil(viewModel.currentLog)
        XCTAssertEqual(viewModel.currentLog?.date, today)
    }

    func testFetchOrCreateDoesNotDuplicateLog() {
        viewModel.fetchOrCreateTodaysLog()
        viewModel.fetchOrCreateTodaysLog()

        let descriptor = FetchDescriptor<DailyLog>()
        let all = try? modelContext.fetch(descriptor)
        XCTAssertEqual(all?.count, 1)
    }

    // MARK: - Stress

    func testSetStressLevel() {
        viewModel.setStressLevel(7)
        XCTAssertEqual(viewModel.currentLog?.stressLevel, 7)
    }

    func testUpdateStressLevel() {
        viewModel.setStressLevel(3)
        viewModel.setStressLevel(8)
        XCTAssertEqual(viewModel.currentLog?.stressLevel, 8)
    }

    // MARK: - Sleep

    func testAddSleepEntryAppendsToLog() {
        let entry = SleepEntry(
            startTime: Date().addingTimeInterval(-28800), // 8 h ago
            endTime:   .now,
            quality:   .good,
            type:      .night
        )
        viewModel.addSleepEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.sleepEntries.count, 1)
        XCTAssertEqual(viewModel.currentLog?.sleepEntries.first?.quality, .good)
    }

    func testAddMultipleSleepEntries() {
        viewModel.addSleepEntry(SleepEntry(
            startTime: Date().addingTimeInterval(-28800), endTime: .now, type: .night))
        viewModel.addSleepEntry(SleepEntry(
            startTime: Date().addingTimeInterval(-3600), endTime: .now, type: .nap))
        XCTAssertEqual(viewModel.currentLog?.sleepEntries.count, 2)
    }

    func testDeleteSleepEntry() {
        let entry = SleepEntry(
            startTime: Date().addingTimeInterval(-28800), endTime: .now)
        viewModel.addSleepEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.sleepEntries.count, 1)

        viewModel.deleteSleepEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.sleepEntries.count, 0)
    }

    // MARK: - Medication

    func testAddMedicationEntry() {
        let entry = MedicationEntry(name: "Ibuprofen", dosage: "400 mg")
        viewModel.addMedicationEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.medicationEntries.count, 1)
        XCTAssertEqual(viewModel.currentLog?.medicationEntries.first?.name, "Ibuprofen")
    }

    // MARK: - Activity

    func testAddActivityEntry() {
        let entry = ActivityEntry(type: .running, intensity: .vigorous, durationMinutes: 45)
        viewModel.addActivityEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.activityEntries.count, 1)
        XCTAssertEqual(viewModel.currentLog?.activityEntries.first?.durationMinutes, 45)
    }

    // MARK: - Food

    func testAddFoodEntry() {
        let entry = FoodEntry(mealType: .lunch, items: ["Salad", "Water"])
        viewModel.addFoodEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.foodEntries.count, 1)
        XCTAssertEqual(viewModel.currentLog?.foodEntries.first?.items, ["Salad", "Water"])
    }

    // MARK: - Notes

    func testAddNote() {
        let note = Note(content: "Feeling tired today.")
        viewModel.addNote(note)
        XCTAssertEqual(viewModel.currentLog?.notes.count, 1)
        XCTAssertEqual(viewModel.currentLog?.notes.first?.content, "Feeling tired today.")
    }

    func testDeleteNote() {
        let note = Note(content: "Temporary note")
        viewModel.addNote(note)
        XCTAssertEqual(viewModel.currentLog?.notes.count, 1)

        viewModel.deleteNote(note)
        XCTAssertEqual(viewModel.currentLog?.notes.count, 0)
    }

    // MARK: - Migraine episode

    func testAddMigraineEpisode() {
        let episode = MigraineEpisode(
            startTime: .now,
            intensity: 8,
            area: .right,
            symptoms: [MigraineSymptom.nausea.rawValue, MigraineSymptom.aura.rawValue],
            triggers: ["Stress", "Bright light"]
        )
        viewModel.addMigraineEpisode(episode)
        XCTAssertEqual(viewModel.currentLog?.migraineEpisodes.count, 1)
        XCTAssertEqual(viewModel.currentLog?.migraineEpisodes.first?.intensity, 8)
        XCTAssertEqual(viewModel.currentLog?.migraineEpisodes.first?.symptoms.count, 2)
    }

    func testDeleteMigraineEpisode() {
        let episode = MigraineEpisode(startTime: .now, intensity: 5, area: .left)
        viewModel.addMigraineEpisode(episode)
        XCTAssertEqual(viewModel.currentLog?.migraineEpisodes.count, 1)

        viewModel.deleteMigraineEpisode(episode)
        XCTAssertEqual(viewModel.currentLog?.migraineEpisodes.count, 0)
    }

    // MARK: - Headache episode

    func testAddHeadacheEpisode() {
        let episode = HeadacheEpisode(
            type: .tensionHeadache,
            area: .bilateral,
            intensity: 4,
            startTime: .now,
            symptoms: [],
            triggers: ["Poor posture"]
        )
        viewModel.addHeadacheEpisode(episode)
        XCTAssertEqual(viewModel.currentLog?.headacheEpisodes.count, 1)
        XCTAssertEqual(viewModel.currentLog?.headacheEpisodes.first?.type, .tensionHeadache)
    }

    func testDeleteHeadacheEpisode() {
        let episode = HeadacheEpisode(type: .cluster, area: .left, intensity: 7)
        viewModel.addHeadacheEpisode(episode)
        XCTAssertEqual(viewModel.currentLog?.headacheEpisodes.count, 1)

        viewModel.deleteHeadacheEpisode(episode)
        XCTAssertEqual(viewModel.currentLog?.headacheEpisodes.count, 0)
    }

    // MARK: - Headache symptom entry

    func testAddHeadacheSymptomEntry() {
        let entry = HeadacheSymptomEntry(
            phase: .prodrome,
            symptoms: [MigraineSymptom.aura.rawValue, MigraineSymptom.fatigue.rawValue],
            notes: "Felt very tired before the migraine"
        )
        viewModel.addHeadacheSymptomEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.headacheSymptomEntries.count, 1)
        XCTAssertEqual(viewModel.currentLog?.headacheSymptomEntries.first?.phase, .prodrome)
        XCTAssertEqual(viewModel.currentLog?.headacheSymptomEntries.first?.symptoms.count, 2)
    }

    func testDeleteHeadacheSymptomEntry() {
        let entry = HeadacheSymptomEntry(phase: .postdrome, symptoms: [MigraineSymptom.fatigue.rawValue])
        viewModel.addHeadacheSymptomEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.headacheSymptomEntries.count, 1)

        viewModel.deleteHeadacheSymptomEntry(entry)
        XCTAssertEqual(viewModel.currentLog?.headacheSymptomEntries.count, 0)
    }

    // MARK: - Custom symptoms

    func testAddCustomSymptom() {
        let symptom = CustomSymptom(name: "Visual Snow")
        viewModel.addCustomSymptom(symptom)

        let descriptor = FetchDescriptor<CustomSymptom>()
        let all = try? modelContext.fetch(descriptor)
        XCTAssertEqual(all?.count, 1)
        XCTAssertEqual(all?.first?.name, "Visual Snow")
    }

    func testDeleteCustomSymptom() {
        let symptom = CustomSymptom(name: "Tingling")
        viewModel.addCustomSymptom(symptom)

        viewModel.deleteCustomSymptom(symptom)
        let descriptor = FetchDescriptor<CustomSymptom>()
        let all = try? modelContext.fetch(descriptor)
        XCTAssertEqual(all?.count, 0)
    }

    // MARK: - No error on save

    func testNoErrorMessageAfterValidOperations() {
        viewModel.setStressLevel(5)
        viewModel.addNote(Note(content: "Test"))
        XCTAssertNil(viewModel.errorMessage)
    }
}
