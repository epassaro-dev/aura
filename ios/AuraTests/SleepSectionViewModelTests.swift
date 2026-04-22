import XCTest
import SwiftData
@testable import Aura

final class SleepSectionViewModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        container = try makeContainer()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    // MARK: - Initial state

    func testInitialStateIsEmpty() throws {
        let vm = SleepSectionViewModel(context: context)
        XCTAssertNil(vm.nightSleep)
        XCTAssertTrue(vm.naps.isEmpty)
    }

    // MARK: - nightSleep / naps split

    func testNightEntryAppearsAsNightSleep() throws {
        let entry = makeSleepEntry(type: .night, hoursAgo: 8)
        context.insert(entry)
        try context.save()

        let vm = SleepSectionViewModel(context: context)
        XCTAssertNotNil(vm.nightSleep)
        XCTAssertTrue(vm.naps.isEmpty)
    }

    func testNapEntryAppearsInNaps() throws {
        let entry = makeSleepEntry(type: .nap, hoursAgo: 1)
        context.insert(entry)
        try context.save()

        let vm = SleepSectionViewModel(context: context)
        XCTAssertNil(vm.nightSleep)
        XCTAssertEqual(vm.naps.count, 1)
    }

    func testMultipleNapsAllAppear() throws {
        context.insert(makeSleepEntry(type: .nap, hoursAgo: 4))
        context.insert(makeSleepEntry(type: .nap, hoursAgo: 1))
        try context.save()

        let vm = SleepSectionViewModel(context: context)
        XCTAssertEqual(vm.naps.count, 2)
    }

    func testNightAndNapsCoexist() throws {
        context.insert(makeSleepEntry(type: .night, hoursAgo: 9))
        context.insert(makeSleepEntry(type: .nap, hoursAgo: 2))
        try context.save()

        let vm = SleepSectionViewModel(context: context)
        XCTAssertNotNil(vm.nightSleep)
        XCTAssertEqual(vm.naps.count, 1)
    }

    // MARK: - Date filter

    func testEntriesFromOtherDaysAreIgnored() throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: .now))!
        let old = SleepEntry(date: yesterday, type: .night, startTime: yesterday, endTime: yesterday, quality: 3)
        context.insert(old)
        try context.save()

        let vm = SleepSectionViewModel(context: context)
        XCTAssertNil(vm.nightSleep)
        XCTAssertTrue(vm.naps.isEmpty)
    }

    // MARK: - Delete

    func testDeleteRemovesEntry() throws {
        let entry = makeSleepEntry(type: .nap, hoursAgo: 1)
        context.insert(entry)
        try context.save()

        let vm = SleepSectionViewModel(context: context)
        XCTAssertEqual(vm.naps.count, 1)

        vm.delete(vm.naps[0])
        XCTAssertTrue(vm.naps.isEmpty)
    }

    func testDeleteNightSleepLeavesNapsIntact() throws {
        context.insert(makeSleepEntry(type: .night, hoursAgo: 8))
        context.insert(makeSleepEntry(type: .nap, hoursAgo: 1))
        try context.save()

        let vm = SleepSectionViewModel(context: context)
        vm.delete(vm.nightSleep!)

        XCTAssertNil(vm.nightSleep)
        XCTAssertEqual(vm.naps.count, 1)
    }

    // MARK: - Helpers

    private func makeSleepEntry(type: SleepType, hoursAgo: Int) -> SleepEntry {
        let today = Calendar.current.startOfDay(for: .now)
        let end = Date.now
        let start = Calendar.current.date(byAdding: .hour, value: -hoursAgo, to: end)!
        return SleepEntry(date: today, type: type, startTime: start, endTime: end, quality: 3)
    }
}
