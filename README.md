# Aura

**Aura** is a calming, elegant migraine journal for iPhone. Track potential triggers, episodes, sleep, medication, physical activity, food, and stress — all from a single tap.

---

## Features

| Category | What's tracked |
|---|---|
| **Stress** | Daily stress level (0 – 10) |
| **Sleep** | Duration, quality, type (night sleep / nap) |
| **Migraine** | Type, intensity, side, symptoms, triggers |
| **Medication** | Name, dosage, time taken, preventive flag |
| **Activity** | Type, intensity, duration |
| **Food** | Meal type, items, time eaten |
| **Notes** | Free-text journal entries |

### Reminders
Four configurable daily reminders:
- Preventive medication
- Morning log (sleep)
- Evening log (stress, food, activity)
- Bedtime

### Security
Optional Face ID / Touch ID / passcode lock. When enabled the app locks every time it moves to the background.

---

## Architecture

- **Platform**: iOS 17+ (iPhone & iPad)
- **Language**: Swift 5.9
- **UI**: SwiftUI
- **Persistence**: SwiftData (local, on-device)
- **Pattern**: MVVM — ViewModels injected at app level, consumed via `@EnvironmentObject`
- **Async**: `async/await` (LocalAuthentication, notifications) + Combine (settings reactive pipeline)

The codebase is designed for extension: an Android app (or any other platform) can be added in a sibling folder alongside `ios/`.

---

## Repository layout

```
aura/
├── ios/                        ← All iOS source code
│   ├── Aura.xcodeproj/
│   ├── Aura/
│   │   ├── AuraApp.swift
│   │   ├── ContentView.swift
│   │   ├── Models/             ← SwiftData @Model classes
│   │   ├── ViewModels/         ← ObservableObject view models
│   │   ├── Views/              ← SwiftUI views
│   │   │   └── Logging/        ← Per-category log entry sheets
│   │   └── Services/           ← NotificationService, SecurityService
│   ├── AuraTests/              ← XCTest unit tests
│   └── AuraUITests/            ← XCUITest UI tests
└── .github/workflows/
    ├── ios-build.yml           ← Build the app on every PR
    └── ios-test.yml            ← Run unit + UI tests on every PR
```

---

## Getting started

1. **Clone** the repository.
2. Open `ios/Aura.xcodeproj` in Xcode 15 or later.
3. Select the **Aura** scheme and an iPhone simulator.
4. Press **⌘R** to build and run.

No external dependencies — the project uses only Apple frameworks.

---

## Running tests

```bash
# Unit tests
xcodebuild test \
  -project ios/Aura.xcodeproj \
  -scheme AuraTests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'

# UI tests
xcodebuild test \
  -project ios/Aura.xcodeproj \
  -scheme AuraUITests \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'
```

---

## CI / CD

Every pull request that touches `ios/**` triggers two GitHub Actions workflows:

| Workflow | Trigger | What it does |
|---|---|---|
| **iOS Build** | push / PR to `ios/**` | Builds Debug + Release for the simulator |
| **iOS Tests** | push / PR to `ios/**` | Runs unit tests, then UI tests (sequential) |

Test results (`.xcresult` bundles + JUnit XML) are uploaded as workflow artifacts.

---

## Roadmap

_First version_: local journal only (this release).

_Future_:
- Health data integration from wearables
- Headache risk assessment
- Personalised prevention recommendations
- Android client (`android/` folder)
