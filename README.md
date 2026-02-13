# SDKQAAppleTV

QA test suite for **MediastreamPlatformSDKAppleTV** on tvOS. It validates SDK flows using the same content IDs as SDKQAiOS/Android, with simple exercises only (no Cast, Reels, or “with Service”).

## Requirements

- Xcode with tvOS 15.6+ support
- CocoaPods
- Dependency: `MediastreamPlatformSDKAppleTV` (via Podfile, e.g. `~> 1.0.0-alpha.01`)

## How to run

1. Clone or open the project and from the repo root run:
   ```bash
   pod install
   ```
2. Open the generated workspace:
   ```bash
   open SDKQAAppleTV.xcworkspace
   ```
3. Select the **SDKQAAppleTV** target and an **Apple TV** destination (simulator or device).
4. Run (⌘R).

## How the app works

### Two-level navigation

1. **Home screen (SDK QA)**  
   Two focusable options: **Audio** and **Video**. Selecting one opens the list of test cases for that category.

2. **Case list**  
   Table with card-style cells: each row is a test case (e.g. “VOD Simple”, “Next Episode Default”). Selecting a case navigates to the detail screen.

3. **Detail screen**  
   - If config is valid: the player (`MediastreamPlatformSDK`) is embedded and `setup(config)` + `play()` are called.  
   - If a resource is missing (e.g. local file): a message is shown indicating what to add (e.g. `sample_audio.mp3` / `sample_video.mp4` in the target).

The player is shown **full screen** in almost all cases so that native `AVPlayerViewController` controls display correctly on tvOS. The exception is **Small Container**, where the player is in a reduced area (known limitation: on small containers controls may not appear).

### Test cases

Content IDs and types match those used in SDKQAiOS.

#### Audio

| Case           | Description                                                |
|----------------|------------------------------------------------------------|
| AOD Simple     | Audio VOD (MP3).                                          |
| Episode        | Audio episode with next from API.                         |
| Local Audio    | Local file `sample_audio.mp3` (must be added to the target). |
| Live Audio     | Audio live.                                               |
| Live Audio DVR | Live with DVR.                                            |
| Mixed Audio    | Same content as AOD Simple (no mode selector).            |

#### Video

| Case                 | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| VOD Simple           | Video VOD.                                                                 |
| Small Container      | Same VOD in a reduced container (top) and content area below. On tvOS controls may not show due to platform limitation. |
| Next Episode Default | Episode whose “next” comes from the API; player full screen.               |
| Next Episode Custom  | VOD with a chain of IDs; on `nextEpisodeIncoming` it calls `updateNextEpisode` with the next ID. Full screen. |
| Local Video          | Local file `sample_video.mp4` (must be added to the target).                 |
| Episode              | Video episode with next from API.                                           |
| Live Video           | Video live.                                                                |
| Live Video DVR       | Live with DVR.                                                             |
| Mixed Video          | VOD (same as VOD Simple, no selector).                                    |
| UI Localization      | VOD for UI localization testing.                                           |

### Cases that require local resources

- **Local Audio**: add `sample_audio.mp3` to the target’s **Copy Bundle Resources**.  
- **Local Video**: add `sample_video.mp4` to the target’s **Copy Bundle Resources**.

If the file is missing, the detail screen shows a message indicating what to add.

### Project structure

```
SDKQAAppleTV/
├── AppDelegate.swift           # Launch: UINavigationController with ViewController as root.
├── ViewController.swift        # Home: "SDK QA" title, Audio / Video buttons.
├── CaseListViewController.swift   # List of cases per category (table with card cells).
├── CaseDetailViewController.swift  # Detail: embeds SDK, builds config and plays (or message if resource missing).
├── TestCase.swift             # Model: categories, case types, and case list per category.
├── PlayerConfigBuilder.swift  # Builds MediastreamPlayerConfig per case type (same IDs as iOS).
└── README.md                  # This file.
```

- **PlayerConfigBuilder**: centralizes IDs and options (type, environment, DVR, next episode, etc.) and returns `MediastreamPlayerConfig?` for each `TestCase`.  
- **CaseDetailViewController**: gets config with `PlayerConfigBuilder.config(for: testCase)`, instantiates the SDK, adds it as a child, calls `setup` + `play`, and for **Next Episode Custom** only subscribes to `nextEpisodeIncoming` and calls `updateNextEpisode` with the next ID in the chain.

## Notes

- Native player controls display correctly when the player is **full screen**. In **Small Container** (player in a small area) tvOS may not show the controls bar due to a platform limitation.
- Next Episode is split into two separate cases (**Next Episode Default** and **Next Episode Custom**), both using full screen to avoid the small-container issue.
