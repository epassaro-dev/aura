# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Aura is a migraine journal app for iOS and Android. Users track triggers, episodes, symptoms, preventive medicine, sleep quality, and physical activity. The repo contains two independent native apps under `ios/` and `android/`.

**Key Features**
- Daily logging of sleep, medications, food, activity, feelings, symptoms, and triggers.
- Headache/migraine tracking, with symptoms and pain intensity fluctuations, attempted remedies and their efficacy.
- Optional encryption + biometric authentication.

**Daily Data Entries**
- Length and quality of night sleep and naps.
- Stress levels and feelings (depression, anxiety, happiness, etc.).
- Preventive medicines and supplements taken.
- Physical activity length and intensity.
- Meals and food eaten.
- Potential triggers experienced (dehydration, storms, loud music, flashing lights, contact lenses, etc.).
- Symptoms experienced (nausea, neck pain, cold, fever, etc.).

**Headache tracking**
- Start time and end time (or if still in progress).
- Type of headache (migraine, rebound headache, tension headache, etc.).
- Pain intensity.
- Affected area of the head.
- Symptoms experienced.
- Medication taken, dosage, at what time, efficacy.
- Other relief methods attempted, at what time, efficacy.
- Telling signs experienced (aura, dizziness, etc.).
- Potential triggers experienced.

**Customizable Data**
Users can extend the tracked data beyond the default options by adding custom items for feelings, triggers, symptoms, medicines, food, types of physical activities. Items, both default and custom, are shown by name and a customizable icon.

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

**Key config:** `AuraApp.swift` sets up the `ModelContainer` for SwiftData. Add new SwiftData model types to the `Schema([...])` array there.

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

## CI

- **iOS:** runs on PRs (`ios-build.yml`) — uses `macos-26` + Xcode 26.4, requires `xcbeautify` installed.
- **Android:** manual trigger only (`android-build.yml`) — runs unit tests then full build.

## Development Environment
- **Android**: Android Studio (latest stable), JDK 17, Android SDK 24+.
- **iOS**: Xcode 26+, macOS 26+.
- **General**: Git, and optionally tools like xcbeautify for iOS CI.

## General Rules
- Always verify that every file you create or edit imports the appropriate modules (e.g. `Foundation`, `SwiftUI`, `SwiftData`).

## Code Quality and Testing Strategy
- **iOS** use SwiftLint, indent with 4 spaces and don't align colons nor equal signs.
- Aim for 80% test coverage.

## Privacy
- User data stored locally and encrypted using standard platform-specific frameworks.