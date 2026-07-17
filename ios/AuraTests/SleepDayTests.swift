import XCTest
@testable import Aura

final class SleepDayTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Rome")!
    }

    private func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 7, day: day, hour: hour, minute: minute))!
    }

    private func makeEntry(type: SleepType, start: Date, end: Date) -> SleepEntry {
        SleepEntry(date: calendar.startOfDay(for: end), type: type, startTime: start, endTime: end, quality: 3)
    }

    // MARK: - Night / nap split

    func testEmptyEntries() {
        let day = SleepDay(entries: [])
        XCTAssertNil(day.nightSleep)
        XCTAssertTrue(day.naps.isEmpty)
    }

    func testNightEntryAppearsAsNightSleep() {
        let night = makeEntry(type: .night, start: date(day: 7, hour: 23), end: date(day: 8, hour: 7))
        let day = SleepDay(entries: [night])
        XCTAssertNotNil(day.nightSleep)
        XCTAssertTrue(day.naps.isEmpty)
    }

    func testNapEntryAppearsInNaps() {
        let nap = makeEntry(type: .nap, start: date(day: 8, hour: 14), end: date(day: 8, hour: 15))
        let day = SleepDay(entries: [nap])
        XCTAssertNil(day.nightSleep)
        XCTAssertEqual(day.naps.count, 1)
    }

    func testNightAndMultipleNapsCoexist() {
        let night = makeEntry(type: .night, start: date(day: 7, hour: 23), end: date(day: 8, hour: 7))
        let nap1 = makeEntry(type: .nap, start: date(day: 8, hour: 13), end: date(day: 8, hour: 14))
        let nap2 = makeEntry(type: .nap, start: date(day: 8, hour: 17), end: date(day: 8, hour: 17, minute: 30))
        let day = SleepDay(entries: [night, nap1, nap2])
        XCTAssertNotNil(day.nightSleep)
        XCTAssertEqual(day.naps.count, 2)
    }

    // MARK: - Day anchor

    func testDayAnchorIsStartOfEndDay() {
        let end = date(day: 8, hour: 7)
        XCTAssertEqual(SleepDay.dayAnchor(forSleepEnding: end, calendar: calendar), date(day: 8, hour: 0))
    }

    func testMidnightCrossingSleepAnchorsToWakeDay() {
        // Nap from 23:30 to 00:30 belongs to the day the user woke up on.
        let end = date(day: 9, hour: 0, minute: 30)
        XCTAssertEqual(SleepDay.dayAnchor(forSleepEnding: end, calendar: calendar), date(day: 9, hour: 0))
    }

    // MARK: - Duration formatting

    func testDurationTextWithHoursAndMinutes() {
        XCTAssertEqual(SleepDay.durationText(from: 8 * 3600 + 30 * 60), "8h 30m")
    }

    func testDurationTextWithWholeHours() {
        XCTAssertEqual(SleepDay.durationText(from: 8 * 3600), "8h 0m")
    }

    func testDurationTextWithMinutesOnly() {
        XCTAssertEqual(SleepDay.durationText(from: 45 * 60), "45m")
    }
}
