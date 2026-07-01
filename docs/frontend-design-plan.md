# Front-End Design Plan

## Design stance

Daily Hadith should feel like a quiet native playback app, closer to Apple Music than a dashboard. The first screen should be useful immediately: current hadith, playback, progress in the sequence, and a compact English translation. The interface should avoid decorative cards, repeated labels, marketing sections, streaks, and calendar pressure.

The app uses Apple-native structure first:

- `TabView` for the three top-level sections: Home, Library, Settings.
- `NavigationStack` inside each tab so titles, push behavior, and future details stay native.
- SF Symbols for tab icons and playback controls.
- Native `List` and `Form` styling for Library and Settings.
- Liquid Glass only as progressive enhancement on supported iOS versions.

## Apple guidance to honor

- Tab bars are for top-level app sections. Home, Library, and Settings are stable peers, so they belong in the tab bar.
- Lists are appropriate for long repeated content and should preserve row semantics, selection, accessibility, and native scrolling behavior.
- Toolbars should stay restrained. Avoid stuffing controls into the navigation bar; playback belongs in the player surface.
- SF Symbols should carry common actions like play, pause, back, forward, search, checkmark, and settings.
- The launch screen should resemble the first usable screen and should not become an artificial splash delay.

## App shell

Tabs:

- Home: `house.fill`
- Library: `music.note.list` or `list.bullet`
- Settings: `gearshape.fill`

Each tab gets its own `NavigationStack`. The tab bar remains the only global navigation control. There is no center floating action button and no duplicated top-level navigation inside the page body.

If audio is playing while the user is away from Home, show a compact mini player above the tab bar. Tapping it returns to Home. If nothing is playing, do not reserve empty space.

Placement:

- `RootAppView` owns the `TabView`, selected tab, repository, playback store, and per-tab navigation paths.
- Each tab content starts inside a `NavigationStack` with a native navigation title.
- The mini player is attached with `safeAreaInset(edge: .bottom)` inside the tab shell so it sits above the tab bar and does not cover list rows or form controls.
- The tab bar remains system-owned; do not recreate its background, height, icons, or selection behavior manually.

Code shape:

- `AppTab` defines tab identity, title, SF Symbol, and root view.
- `AppRoute` is reserved for future pushed detail screens; the first build should not need many routes.
- `AppTheme` exposes semantic color values and spacing constants as static design tokens unless a real user-facing theme setting exists later.
- `RootAppView` should not contain playback controls, row layouts, or settings rows directly.

## Visual system

Colors:

- Background: system background and grouped system background, not a custom full-screen gradient.
- Primary tint: deep emerald green.
- Secondary accent: muted gold used sparingly for completion or active state.
- Text: system primary, secondary, and tertiary text colors.
- Dividers: native separators or low-opacity system separator.

Keep the palette restrained. Green should identify the app, not flood every surface.

Typography:

- Native navigation large title for page titles.
- Title/headline for the current hadith title and important row titles.
- Body/callout for translation and row metadata.
- Caption for sequence progress, duration, and secondary notes.

Do not introduce many custom type sizes. Let Dynamic Type scale the interface.

Spacing:

- Standard page side padding: 16 points.
- Section spacing: 20 to 28 points.
- Touch targets: at least 44 points.
- Player controls use fixed frames so symbols and labels never shift layout.

Shape:

- Avoid nested cards.
- Use unframed sections by default.
- If a surface must be framed, keep radius modest and use it once at that level.
- Glass or material surfaces should be reserved for the player and mini player, not every row.

## Launch screen

Use a native launch screen that visually matches the Home shell: background color, approximate top spacing, and tab bar area if needed. Do not show a timed logo splash, instructions, dedication, or loading message. The app should move directly into Home.

## Home

Purpose:

Home is the daily listening surface. It answers: "What should I listen to next, and where am I in the sequence?"

Layout:

1. Native large title: `Home`.
2. Small progress line: `Hadith 12 of 118`.
3. Current hadith title, using the reviewed English title.
4. Player block:
   - Large circular play/pause button.
   - Back 15 seconds and forward 15 seconds icon buttons.
   - Previous and next controls, smaller than play/pause.
   - Scrubber with elapsed and remaining time.
   - Optional speed menu later, not required for first build.
5. Compact translation section:
   - No giant transcript page.
   - Fixed max height at first, scrollable when text is long.
   - Text is English only.
   - The section can have a quiet heading like `Translation`, but avoid repeating "Translation" in every nested element.
6. Bottom spacing respects the tab bar and mini player behavior.

Element placement:

- Use one vertical `ScrollView` for Home so long translations and smaller screens behave naturally.
- Keep the sequence progress close to the title area, above the hadith title, using caption style and secondary color.
- The hadith title gets the strongest text weight in the page body. It should not repeat inside the player block.
- The player block sits immediately under the title, horizontally centered, with a stable width and fixed-height control rows.
- The scrubber sits below the transport buttons, not above the title.
- Elapsed and remaining time sit at the leading and trailing ends under the scrubber.
- The translation section sits below the player block with a max height in compact phones and natural height on larger screens.
- The mark-listened action belongs in a toolbar menu or compact overflow row, not as a large primary button.

Components:

- `HomeView`: composes the screen and selects state-specific content.
- `CurrentHadithHeader`: sequence progress and title.
- `PlayerBlock`: progress slider, transport buttons, elapsed/remaining time.
- `TransportControls`: previous, rewind, play/pause, forward, next.
- `TranslationExcerpt`: compact scrollable English translation.
- `ManualCompletionMenu`: secondary action for marking listened.

Home states:

- Loading library: show a native `ProgressView` under the Home title with no fake skeleton dashboard.
- Ready and idle: show current hadith, play button, saved playback position if present.
- Playing: play button becomes pause; scrubber and elapsed time update.
- Paused: pause button becomes play; position remains visible.
- Buffering or seeking: keep layout stable, disable only the transport control being resolved if needed.
- Completed: briefly mark Listened, advance to next hadith, reset playback position for the next item.
- Manifest error: show a small native error section with retry if loading can be retried; do not show an empty player.
- Missing audio: show title and an unavailable state for that item, then allow next/previous navigation.

Behavior:

- Opening the app resumes the saved Listening Position and Playback Position.
- Completing playback marks the hadith Listened and advances to the next Audio Hadith.
- At the end of the Bundled Library, the Daily Sequence loops.
- Manual "mark listened" can live in an overflow menu, not as a primary button.

Liquid Glass:

- On iOS 26+, the player block can use a single glass treatment with interactive glass controls.
- On older iOS versions, use native material or a plain grouped background.
- Do not custom-build blur effects.
- `PlayerSurface` should be the only wrapper that decides between `.glassEffect(...)`, material fallback, or plain grouped background.
- Interactive glass belongs on tappable transport controls, not on static text or the translation area.

## Library

Purpose:

Library lets the user browse the Bundled Library without turning the app into a content management tool.

Layout:

1. Native large title: `Library`.
2. Optional native search field for titles and translation text.
3. Native `List` with plain or subtly grouped styling.
4. Rows:
   - Sequence number, such as `12`.
   - Title.
   - Duration.
   - Listened state with a checkmark or subtle progress indicator.
   - Current item highlighted with tint, not a separate card.

Avoid row labels like "Hadith title", "Duration", or "Status". The structure should make those roles obvious.

Element placement:

- Use a native `List`, not a custom `ScrollView`, for all 118 rows.
- Place search in the navigation area with `.searchable`, not as a custom search box inside the page.
- The sequence number sits in a narrow leading column with monospaced digits.
- Title sits in the main row column with one or two lines.
- Duration and completion/current state sit in secondary text below or trailing, depending on available width.
- The current item uses tint, a subtle leading indicator, or a filled play symbol. Do not wrap the row in a card.
- Listened rows use a checkmark or muted text treatment; they should remain readable.

Components:

- `LibraryView`: owns search query and composes list state.
- `HadithList`: filters and renders the native list.
- `HadithRow`: pure row layout for one Audio Hadith.
- `HadithRowStatus`: current/listened/unlistened symbol and accessibility label.
- `LibrarySearchEmptyState`: compact empty result view.

Library states:

- Loading: native progress row or centered `ProgressView`.
- Loaded with no query: all Audio Hadith rows in Daily Sequence order.
- Searching with matches: filtered rows preserve original sequence numbers.
- Searching with no matches: compact empty state below the search field.
- Current item playing elsewhere: row status shows active state and mini player appears.
- No library data: small error/empty state; this should only happen in previews or corrupted app builds.

Behavior:

- Tapping a row sets it as the current Audio Hadith and opens Home.
- The current row should be easy to spot when returning to Library.
- No streaks, calendar, or daily-lock mechanic.

Mini player:

- If audio is active, Library shows the app-wide mini player above the tab bar.
- The mini player contains title, small progress bar, and play/pause.

## Settings

Purpose:

Settings contains meaningful secondary information and controls, not promotional filler.

Layout:

Use a native `Form` with inset grouped sections:

- Dedication:
  - A short dedication to the user's mom.
  - Keep it warm but small; not a hero section.
- Charity:
  - One donation link row that opens the chosen charity externally.
- Playback:
  - Reset Listening Position.
  - Optional reset all Playback Positions.
- About:
  - Bundled Library count.
  - Translation Notice: English translations are generated from Urdu audio and should be verified before quoting.
  - App version.

Element placement:

- Use the native Settings navigation title with inline or large title according to platform default. Do not make a custom header.
- The dedication is a short text row inside the first section. It should not be a hero card.
- Donation is a single `Link` row with an external-link indicator if appropriate.
- Reset actions live in a Playback section and use destructive confirmation.
- Translation Notice lives in About, as secondary text. It can also be shown once on first launch as a small sheet, then stored as acknowledged.

Components:

- `SettingsView`: form shell and confirmation state.
- `DedicationSection`: dedication text only.
- `CharitySection`: donation link row.
- `PlaybackSettingsSection`: reset controls.
- `AboutSection`: library count, translation notice, version.
- `ResetProgressConfirmation`: item-driven confirmation state.

Settings states:

- Default: all sections visible.
- Reset confirmation active: native confirmation dialog; never a custom full-screen warning.
- Donation link unavailable: hide the row or show disabled secondary text; do not leave a broken link.
- Translation notice unacknowledged: show once in a small sheet or settings acknowledgement, then never interrupt playback again.

Behavior:

- Destructive resets require confirmation.
- The Translation Notice appears here and, if needed, once on first launch in a subtle sheet or inline settings acknowledgement. It should not appear on every screen.

## Accessibility and older phones

- Support Dynamic Type.
- Use native controls and labels for VoiceOver.
- Icon-only playback buttons need accessibility labels.
- Respect Reduce Motion.
- Keep playback usable without Liquid Glass.
- Avoid dense visual effects in scrolling lists.

Accessibility placement:

- Playback controls need explicit labels: `Play`, `Pause`, `Rewind 15 seconds`, `Forward 15 seconds`, `Previous Hadith`, `Next Hadith`.
- The scrubber needs a value label using elapsed and duration.
- Library rows should read as `Hadith 12 of 118, Title, duration, listened/current`.
- Settings reset controls must clearly announce destructive behavior before confirmation.
- Long translation text should remain selectable only if that does not complicate layout; readability matters more than custom interaction.

## Implementation notes

- Root state: `PlaybackStore` owns current hadith id, playback status, and audio engine commands.
- Progress state: `ListeningProgressStore` owns persisted current hadith id, listened ids, and playback positions.
- Content state: `HadithRepository` loads the bundled reviewed manifest and audio URLs once into an immutable `LibrarySnapshot`.
- Views should receive simple models and bindings; avoid giant view models for static screens.
- Use semantic theme tokens: `tint`, `background`, `secondaryBackground`, `completionAccent`. Do not introduce a mutable theme object until there is an actual settings feature for it.
- Add SwiftUI previews for Home, Library, Settings, empty/error manifest states, and long translation text.

State model:

- `LibraryLoadState`: `loading`, `loaded(LibrarySnapshot)`, `failed(LibraryLoadError)`. Avoid an `idle` case after app startup because the root task should immediately load bundled content.
- `LibrarySnapshot`: ordered Audio Hadiths plus lookup dictionaries derived once after decoding.
- `PlaybackState`: `stopped`, `loading`, `ready`, `playing`, `paused`, `seeking`, `failed(PlaybackError)`. The current Audio Hadith id stays on `PlaybackStore` instead of being repeated in every state case.
- `ListeningProgress`: current id, listened ids, playback positions by id. Persist atomically so a current-id update and playback-position update cannot diverge.
- `TranslationNoticeState`: acknowledged or unacknowledged.

State ownership:

- `RootAppView` owns repository and playback store as app-level `@State` observable objects.
- `HomeView` reads playback and repository state, but owns only transient UI such as showing the completion menu.
- `LibraryView` owns `searchText` locally and reads immutable hadith data plus playback status.
- `SettingsView` owns confirmation dialog state locally and calls store methods for reset actions.
- Row views and button views receive value models and closures; they do not read global stores directly unless there is a strong reason.
- `MiniPlayerView` is derived from `PlaybackStore` and `LibrarySnapshot`; it owns no playback truth of its own.

Rendering rules:

- Keep top-level view trees stable. Switch inside content sections instead of replacing the entire tab view for small state changes.
- Keep formatting helpers out of `body` when they are non-trivial; use small formatters for duration, progress, and accessibility text.
- Use stable `AudioHadith.ID` for `ForEach`.
- Debounce Library search only if filtering transcript text becomes slow; title-only search can stay local and synchronous.
- Avoid multiple booleans for mutually exclusive presentation. Use small enums for confirmation dialogs and sheets.
- Do not create a `HomeViewModel`, `LibraryViewModel`, and `SettingsViewModel` by default. Add a model only when the state outgrows local `@State` plus app-level stores.

## Maintainability preflight

Canonical owners:

- `Content`: `AudioHadith`, `LibrarySnapshot`, manifest decoding, and bundled audio URL resolution.
- `Playback`: AVPlayer integration, playback commands, elapsed time updates, completion handling, and current playback status.
- `Progress`: persisted Listening Position, Playback Positions, Listened ids, and Translation Notice acknowledgement.
- `DesignSystem`: static colors, spacing, typography helpers, and `PlayerSurface` glass/fallback wrapper.
- `Features/Home`: Home composition only; no manifest decoding, persistence, or AVPlayer access.
- `Features/Library`: list, search, and row presentation only; no playback engine logic beyond calling store commands.
- `Features/Settings`: form sections and reset confirmations only; no direct UserDefaults writes outside `Progress`.

Proposed file boundaries:

- Keep root app shell files under 250 lines where practical.
- Keep each feature root view under 300 lines by extracting focused subviews before the file becomes hard to scan.
- Keep stores under 400 lines. If `PlaybackStore` grows beyond transport plus AVPlayer coordination, split time observation or command handling into a helper owned by `Playback`.
- No target file should approach 1000 lines without an explicit decomposition plan.

Complexity avoided:

- One `LibrarySnapshot` prevents every screen from sorting, indexing, and validating the manifest independently.
- One `ListeningProgressStore` prevents progress updates from being scattered across Home, Library, and Settings.
- One `PlayerSurface` prevents Liquid Glass availability checks from spreading through unrelated views.
- One `PlaybackStore.currentHadithID` prevents repeated `AudioHadith.ID` associated values across every playback state case.
- Static `AppTheme` tokens avoid introducing a mutable theme system before the product has theme settings.
- Mini player state is derived, preventing a second player model.

Risks to watch:

- Do not let search evolve into a second repository. Search should remain a local derived view over `LibrarySnapshot` unless it becomes measurably slow.
- Do not let reset actions write directly to storage from Settings rows. They should call `ListeningProgressStore` methods.
- Do not let player button views know about AVPlayer. They should receive labels, state, and closures.
- Do not add one-off booleans like `isShowingResetProgress`, `isShowingResetPlayback`, and `isShowingTranslationNotice`; use enum-driven presentation.
- Do not add optional fields to `AudioHadith` for data that the app requires to render. Required manifest fields should fail validation during load.

Acceptance criteria for implementation:

- Build succeeds with Home, Library, and Settings split into focused feature files.
- The app has exactly one canonical path for loading the bundled manifest.
- The app has exactly one canonical path for persisting Listening Position and Playback Positions.
- Liquid Glass availability handling is centralized in design-system wrappers.
- Library rows are stable by `AudioHadith.ID`, not array index.
- SwiftUI previews cover the preview matrix without live services or global singletons.
- No new file crosses 1000 lines; any file above 400 lines must have a clear reason or be split before continuing.

Preview matrix:

- Home loaded, playing first hadith.
- Home paused midway through a long hadith.
- Home long translation on a small phone.
- Home missing audio/error state.
- Library default at top.
- Library with current item around the middle of the sequence.
- Library empty search.
- Settings default.
- Settings reset confirmation.
- Older iOS fallback surface for player and mini player.

## Design guardrails

- No nested cards.
- No dashboard hero.
- No fake splash delay.
- No repeated explanatory labels.
- No full-screen translation by default.
- No calendar, streaks, badges, or habit pressure.
- No custom tab bar.
- No action button inside the tab bar.
- No one-note green screen; use green as tint.
- No recurring translation warning banner.
