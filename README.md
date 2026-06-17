# Aura

> A local-first migraine tracking and reminders app, built natively for iOS and Android.

Aura is a personal project to track migraines and everything that might influence them: sleep, food, physical activity, medication, and more, and to actually remind me of the things I tend to forget, like taking my preventative medication on schedule.

It's also a hands-on way for me to stay current with modern iOS and Android development, and to experiment with AI-assisted development workflows, while building something I'll actually use every day.

**Status:** active development, pre-release. Core tracking features are partially implemented; this README will evolve alongside the app.

---

## Why this project exists

I get migraines, and I've used apps like Migraine Buddy to track them. It's a capable app, but two things about it never fit what I wanted: all the data is automatically uploaded to their servers with no option to keep it local, and the overall usability just didn't match how I actually wanted to track and be reminded about things.

I wanted something different, an app where I decide what gets tracked, how it's analyzed, and where it's stored, whether that's only on my device, a folder I control, or a cloud provider I choose. Local-first, not local-only: sync and backup should be something the user opts into and directs, not a default the app quietly relies on.

I also wanted an app that actually reminds me to take my preventative medication on schedule, without having to bring in a separate, unrelated reminders app just for that.

This is also a portfolio project, with a few different skills I want to build alongside it: sustained, hands-on practice with the current state of native mobile development (SwiftUI and Swift concurrency on one side, Kotlin and Jetpack Compose on the other), getting comfortable with the native health data APIs on both platforms (HealthKit, Health Connect), and developing my own AI-assisted development workflows along the way (more on that below). I wanted something real, evolving, and end-to-end to show for all of that, beyond isolated exercises or tutorials.

Since it's first and foremost a tool I'm building for myself, feature decisions are guided by what's actually useful for managing my own migraines. That said, the broader goal, giving people control over their own health data while still getting genuinely useful tracking, is one I think is worth building well, and worth sharing.

## What it does (and will do)

The project is being built in phases. The native phase and the later Flutter phase (see roadmap below) share the same feature scope: tracking and reminders. In plain terms, a well-built, local-first diary for migraines and the things that affect them, with no analysis or predictions yet; that's a deliberately later, lower-priority goal (see roadmap).

Planned tracking and functionality for these phases includes:

- Migraine episodes, including duration, intensity, and symptoms
- Potential triggers (food, drinks, weather, stress, screen time, etc.)
- Sleep, duration and quality
- Physical activity, including basic data pulled from the platform's native health APIs (e.g. step count, heart points) as a way to get hands-on with HealthKit and Health Connect, starting simple
- Preventative and acute medication, including intake, effect, and reminders
- Food and drink intake
- Other reminders, such as hydration or screen time, still being figured out as I use the app myself
- Charts and summaries of logged data, without any predictive logic yet

None of the above is fully built yet; this is the target shape for these phases, not a changelog. Both native platforms are being developed in parallel and may not be at the exact same feature parity at any given point.

## Roadmap (high level)

Beyond the current phase, the plan (loosely, since priorities may shift as the project evolves) looks roughly like this:

1. **Native iOS & Android (current phase):** tracking, reminders, and basic wearable health data, no cloud dependency by default.
2. **Cross-platform exploration:** once the feature set and UI stabilize on native, a Flutter version with the same scope (tracking and reminders), to compare the cross-platform experience against the native ones.
3. **Pattern matching, someday:** a low-priority, nice-to-have idea I'd like to experiment with eventually, a simple model trained on my own data, tested only on myself, to see whether basic pattern matching says anything useful. Not a near-term goal, and not something the rest of the app depends on.
4. **Optional backend:** moving some functionality to a .NET server, scope to be decided based on what, if anything, ends up needing it.

Whether Aura ever reaches the app stores, and which version(s) end up maintained long-term, is an open question I'll answer based on how each approach feels to build and use. Native vs. cross-platform is deliberately being kept as a live decision rather than settled upfront; part of the point of this project is finding that out firsthand rather than assuming the answer.

## Design principles

- **Local-first.** Data lives on the device by default. Backup and sync to a location of the user's choosing, local storage or a cloud drive, are opt-in, not required.
- **User-controlled data.** The user decides what gets tracked, when, and where it's stored or analyzed. No data collection beyond what the user explicitly enables.
- **No paywalls on core functionality.** This is a personal tool first; there's no monetization model driving feature decisions.
- **Native where it matters.** The native iOS and Android phase deliberately uses platform-native tooling (SwiftUI, Jetpack Compose) to get the best possible UX and to keep the platform-specific skills sharp, before any cross-platform tradeoffs are introduced later.

## AI-assisted development

Alongside the mobile development skills, one of the explicit goals of this project is getting genuinely comfortable with AI-assisted development, specifically, building my own workflows around Claude Code rather than using it as an autocomplete engine.

To be upfront about it: I'm not using AI to build this app for me. I use it to cut down on the parts of development that don't need to be fully manual, while staying directly involved in design decisions, review, and anything visual or graphical, where I've found AI tools are still noticeably weaker.

Roughly how it's split, at the time of writing:

- **Claude Code** is the primary agentic tool, used for scaffolding new features, reviewing code, and planning out changes before any code gets written.
- **Claude (chat)** stays open alongside it, for questions or discussions that go beyond the scope of the current task or project.
- The project keeps a `CLAUDE.md` with conventions and constraints. At the end of a session, Code reviews both that file and the session itself, updates it, and flags anything worth turning into a reusable skill.
- For UI and anything graphical, I plan and draft structure with Code, but do the actual implementation myself.
- A typical loop: Code writes an initial pass, I review and adjust it myself, then Code reviews my changes and reconsiders anything that should change as a result. Back and forth, rather than one-shot generation.

This part of the project will likely evolve the most visibly over time, including, much further down the line, experimenting with running a custom agent on local models.

## Tech stack

| | iOS | Android |
|---|---|---|
| Language | Swift | Kotlin |
| UI | SwiftUI | Jetpack Compose |
| Min. target | iOS 26 | Android 16 (API 36) |

CI/CD is handled via GitHub Actions (see `.github/workflows`).

Cross-platform (Flutter) and backend (.NET) components will be added to this table once and if work on them begins.

## Repository structure

```
.
├── ios/                  # Native iOS app (Swift, SwiftUI)
├── android/              # Native Android app (Kotlin, Jetpack Compose)
└── .github/workflows/    # CI/CD pipelines
```

Each platform folder will get its own README with platform-specific setup instructions once the build process stabilizes; for now, this top-level document covers both.

## Getting started

> Setup instructions are coming as the build process stabilizes on both platforms. In the meantime, each platform folder contains a standard Xcode / Android Studio project that can be opened directly.

## Screenshots

_Coming soon, once the UI is in a presentable state._

## License

This project is licensed under the [MIT License](LICENSE), feel free to explore the code, learn from it, or fork it.

## A note on scope

Aura is being built primarily for my own use, which means feature priorities, UX decisions, and even the pace of development are shaped by what's useful to me day to day. It's public mainly as an evolving portfolio piece and in case any part of it (the local-first approach, the native implementation details, or just the general idea) is useful to someone else. Contributions aren't the focus right now, but feedback and issues are welcome.