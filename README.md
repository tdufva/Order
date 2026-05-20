# Order

A Swift/SwiftUI Apple ecosystem app for showing one deterministic Swedish humanities research term per local calendar day, with Finnish translation, explanations, widgets, and a macOS menu bar extra.

## Open This Project

Open this workspace directly in Xcode:

```text
Order.xcworkspace
```

You can also open the project file:

```text
Order.xcodeproj
```

Use these schemes:

- `Order iOS`
- `Order macOS`
- `Order iOS Widget`
- `Order macOS Widget`

If Xcode asks what to open, choose `Order.xcworkspace` or `Order.xcodeproj`. Do not use “Open Folder” for this app.

## What Is Included

- `Order.xcodeproj`: the real Xcode project with iOS app, macOS app, iOS widget, and macOS widget targets.
- `Sources/SwedishWordCore`: shared Swift source code used by apps and widgets.
- `Sources/SwedishWordCore/Resources/vocabulary.csv`: bundled vocabulary resource copied from the provided CSV.
- `iOSApp`: iOS SwiftUI app source.
- `MacApp`: macOS SwiftUI app source, including `MenuBarExtra`.
- `Widgets`: WidgetKit source reusable in both iOS and macOS widget extension targets.
- `Tests/SwedishWordCoreTests`: parser and word-of-day tests kept with the project sources.

## Shared Logic

The `SwedishWordCore` package provides:

- `VocabularyEntry`
- `CSVParser`
- `VocabularyStore`
- `WordOfDayProvider`
- `EntryFormatter`
- `VocabularySearch`

The word-of-day algorithm uses local start-of-day dates, an epoch of `2026-01-01`, and modulo indexing through the loaded vocabulary. Apps and widgets call the same provider, so the same local day selects the same term.

## Verify Builds

From this folder:

```sh
./script/build_and_run.sh --verify
```

The Codex Run action builds and opens the macOS app.

## Xcode Targets

The included project contains:

1. iOS App
   - Target: `Order iOS`
   - Sources: `iOSApp` + shared vocabulary core
   - App Icons Source: `AppIcon`
   - Minimum deployment: iOS 26

2. macOS App
   - Target: `Order macOS`
   - Sources: `MacApp` + shared vocabulary core
   - App Icons Source: `AppIcon`
   - Minimum deployment: macOS 14
   - Embeds the macOS widget extension

3. iOS Widget Extension
   - Target: `Order iOS Widget`
   - Sources: `Widgets` + shared vocabulary core
   - Supported families are small, medium, accessory inline, and accessory rectangular.

4. macOS Widget Extension
   - Target: `Order macOS Widget`
   - Sources: `Widgets` + shared vocabulary core
   - Supported families are small, medium, and large.

The CSV is included in every app and widget target as a bundled resource.

## App Icon

The generated royal blue/yellow `Order` logo is stored at:

```text
Resources/AppIconSource.png
```

Ready-to-use app icon asset catalogs are included for both app targets:

```text
iOSApp/Assets.xcassets/AppIcon.appiconset
MacApp/Assets.xcassets/AppIcon.appiconset
```

The wordmark uses a heavier `Ord` and a thinner `er`, with a cleaned-up royal book/crown mark and no stray yellow fragments.

## Website

The marketing site for GitHub Pages lives in:

```text
docs/
```

It includes static screenshot artwork in `docs/assets/` and a GitHub Pages workflow at:

```text
.github/workflows/pages.yml
```

## Replace Or Update The CSV

Use the same columns:

- `svenska`
- `ordklass`
- `förklaring_sv`
- `kort_förklaring_sv`
- `suomeksi`
- `område`
- `källa_url`

An optional `id` column is supported. Replace:

```text
Sources/SwedishWordCore/Resources/vocabulary.csv
```

Keep the filename as `vocabulary.csv`. The parser supports UTF-8, quoted fields, commas or semicolons inside quoted fields, escaped quotes, and quoted line breaks.

## Copy Format

The macOS copy-full-entry action uses:

```text
[svenska] ([ordklass])
Suomeksi: [suomeksi]
Område: [område]

Kort förklaring:
[kort_förklaring_sv]

Förklaring:
[förklaring_sv]

Källa:
[källa_url]
```

## Offline Behavior

The app and widgets read the bundled CSV and do not require network access. If loading fails, `VocabularyStore` serves graceful fallback entries and exposes the load error so the UI can show a quiet warning.
