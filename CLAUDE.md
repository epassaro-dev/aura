# CLAUDE.md

## Project Overview

Aura is a migraine journal app for iOS and Android. Users track triggers, episodes, symptoms, preventive medicine, sleep quality, and physical activity. The repo contains two independent native apps under `ios/` and `android/`.

## Android

**Important**
Ignore Android for now, focus only on iOS.

**Stack:** Kotlin, Jetpack Compose (Material3), Room (local DB), Hilt (DI), KSP

**Build & test** (run from `android/`):

```bash
cd android
./gradlew build          # compile + assemble
./gradlew test           # unit tests
./gradlew connectedAndroidTest  # instrumented tests (requires emulator/device)
```

Run a single test class:

```bash
./gradlew test --tests "com.aura.android.ExampleUnitTest"
```

**Key config:** `android/gradle/libs.versions.toml` is the version catalog — all dependency versions live there. Target SDK 36, min SDK 24, Java 17.

**Architecture pattern:** Hilt is wired at the `Application` level (`AuraApplication`) and `MainActivity` is annotated `@AndroidEntryPoint`. New screens should follow the same Compose + Hilt pattern.

## iOS

Main development platform.

**Stack:** SwiftUI, SwiftData

**Build & test** (requires Xcode):

```bash
xcodebuild \
  -project ios/Aura.xcodeproj \
  -scheme Aura \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4' \
  -configuration Debug \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  test | xcbeautify
```

**Key config:** `AuraApp.swift` creates the `ModelContainer` via `ModelContainer.makeAuraContainer()`. The schema is versioned: add new SwiftData model types to `AuraSchemaV1.models` in `Aura/AuraSchema.swift`; schema changes after release need a new `VersionedSchema` plus a stage in `AuraMigrationPlan`.

**Test plan:** `ios/Aura.xctestplan` is the explicit, version-controlled test plan referenced by the scheme. Add new test targets there — do not re-enable `shouldAutocreateTestPlan` in the scheme.

**Local test run** (omit `OS=` — the version in the CI workflow targets the CI machine's runtimes):

```bash
xcodebuild \
  -project ios/Aura.xcodeproj \
  -scheme Aura \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
  test | xcbeautify
```

**SwiftData model architecture:**

- `Models/Catalog/` — user-extensible reference types (`FeelingType`, `TriggerType`, `SymptomType`, `Medicine`, `FoodItem`, `ActivityType`, `TellingSignType`, `ReliefMethodType`). All carry `isDefault` (locks renaming, enables restore) and `isArchived` (soft delete).
- `Models/Log/` — independent daily log entries, each with a `date: Date` anchor (`SleepEntry`, `FeelingEntry`, `MedicineLog`, `ActivityEntry`, `MealEntry`, `TriggerEntry`, `SymptomEntry`).
- `Models/Headache/` — `HeadacheEntry` with cascading child logs: `HeadachePainLog` (intensity 1–10 + affected areas, tracks fluctuations over time), `HeadacheSymptomLog`, `HeadacheMedicineLog` (+ `efficacy`), `HeadacheReliefLog` (+ `efficacy`).

**SwiftData relationship rule:** Always declare an explicit `@Relationship(deleteRule:, inverse:)` back-reference on the "one" side of every one-to-many relationship. Without it SwiftData cannot find the related objects on deletion and nullify/cascade silently does nothing.

**Data flow pattern (no ViewModels):**

- Reads: views declare `@Query`. Dynamic predicates (e.g. today's entries) are built in `init` from parameters:

```swift
struct MySection: View {
    @Query private var entries: [SleepEntry]

    init(day: Date, nextDay: Date) {
        _entries = Query(filter: #Predicate<SleepEntry> { $0.date >= day && $0.date < nextDay })
    }
}
```

- `ContentView` owns the day anchor (`today`/`tomorrow`) and refreshes it on `NSCalendarDayChanged` and when the scene becomes active; child views re-init and their queries follow.
- Domain logic lives in pure types in `Aura/Domain/` (`SleepDay`, `MedicationProgress`, `TreatmentPlanner`) — no `ModelContext`, unit-tested directly. `Aura/Support/` is for app-wide utilities only (`Logger+Aura`).
- Writes: views own every context write (insert + `do/catch` save via `@Environment(\.modelContext)`). Domain types build or mutate models but never touch the context.
- Persistence errors: never `try?` — use `do/catch` and log via `Logger.persistence` / `Logger.seeding` (`Support/Logger+Aura.swift`).

**Previews for SwiftData views:** Attach a shared sample-data scenario from `Aura/Preview Content/PreviewSampleData.swift`; add new scenarios there as `SampleDataPreviewModifier` conformances (no `try!` — the preview system reports container failures in the canvas). `QueryPreview { (model: MyModel) in ... }` bridges scenarios to views that take a model instance.

```swift
#Preview("Empty state", traits: .modifier(EmptyPreviewData())) {
    MyView(day: .now, nextDay: .now)
}
```

**Adding/removing Swift files in the Xcode project:** Use the `/xcode-files` skill (requires Xcode running with the project open). Never create a new source directory on disk before registering it — the MCP tools can't adopt unregistered folders and will create a `"<Name> 2"` duplicate.

## CI

- **iOS:** runs on PRs (`ios-build.yml`) — uses `macos-26` + Xcode 26.4, requires `xcbeautify` installed.
- **Android:** manual trigger only (`android-build.yml`) — runs unit tests then full build.

## Development Environment

- **Android**: Android Studio (latest stable), JDK 17, Android SDK 24+.
- **iOS**: Xcode 26+, macOS 26+, minimum deployment target iOS 26.
- **General**: Git, and optionally tools like xcbeautify for iOS CI.

## General Rules

- Always verify that every file you create or edit imports the appropriate modules (e.g. `Foundation`, `SwiftUI`, `SwiftData`).

## Code Quality and Testing Strategy

- **iOS** use SwiftLint (`ios/.swiftlint.yml`), indent with 4 spaces and don't align colons nor equal signs.
- Lint runs in CI (strict) and via the pre-commit hook; enable the hook once per clone: `git config core.hooksPath .githooks`.
- Aim for 80% test coverage.

## Privacy

- User data stored locally and encrypted using standard platform-specific frameworks.