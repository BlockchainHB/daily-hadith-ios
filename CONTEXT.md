# Daily Hadith App

A native iOS audio app for listening to a curated sequence of Urdu hadith recordings without relying on WhatsApp chat history.

## Language

**Audio Hadith**:
One Urdu audio recording containing a single hadith lesson or recitation.
_Avoid_: message, voice note, track

**Daily Sequence**:
The ordered path through the Audio Hadith library, advancing one item at a time and looping after the final item.
_Avoid_: feed, playlist, queue

**Listening Position**:
The listener's current place in the Daily Sequence.
_Avoid_: streak, calendar day, daily unlock

**Playback Position**:
The saved timestamp inside an Audio Hadith where playback can resume.
_Avoid_: progress, place

**Listened**:
The completion state of an Audio Hadith after playback reaches the end or the listener manually marks it complete.
_Avoid_: consumed, watched, read

**Bundled Library**:
The fixed offline collection of Audio Hadiths packaged with the app.
_Avoid_: sync, backend library, live feed

**Source Package**:
The exported Hadith zip that contains the original Audio Hadith files for the Bundled Library.
_Avoid_: feed, inbox, channel, source chat

**Transcript**:
Optional written text that faithfully preserves the spoken content of an Audio Hadith.
_Avoid_: caption, subtitle

**Translation**:
Optional English rendering that preserves the meaning of an Audio Hadith without needing to be word-for-word literal.
_Avoid_: summary, paraphrase

**AI Enrichment**:
Generated metadata derived from an Audio Hadith, such as an English title, short summary, Translation, or Transcript.
_Avoid_: source text, canonical content

**Translation Notice**:
A one-time or tucked-away reminder that English translations are generated from Urdu audio and should be verified before quoting.
_Avoid_: warning banner, recurring disclaimer

**Library Progress**:
A simple count of the listener's place within the Daily Sequence.
_Avoid_: streak, calendar progress, habit score

**Home**:
The primary listening surface for the current Audio Hadith and its English Translation.
_Avoid_: dashboard, today feed

**Library**:
The browsable collection of Audio Hadiths in the Daily Sequence.
_Avoid_: archive, catalog

**Settings**:
The secondary surface for dedication, donation, app notices, and listener controls that do not belong in playback.
_Avoid_: profile, admin

**Glass Treatment**:
Native Liquid Glass styling used where available, with non-glass fallbacks on older iPhones.
_Avoid_: iOS 26-only design, custom blur theme

**Mini Player**:
A compact playback control shown above the tab bar when audio is active outside Home.
_Avoid_: second player page, floating dashboard widget

**Player Block**:
The main Home playback control area for the current Audio Hadith.
_Avoid_: player card stack, media dashboard

**Design Guardrail**:
A front-end constraint that prevents the app from drifting away from native, quiet, Apple Music-inspired interaction.
_Avoid_: theme idea, decoration rule

## Relationships

- A **Bundled Library** contains one or more **Audio Hadiths**
- A **Bundled Library** is initially created from one **Source Package**
- A **Daily Sequence** contains one or more **Audio Hadiths**
- A **Listening Position** points to exactly one Audio Hadith in the Daily Sequence
- **Library Progress** is derived from the **Listening Position** and the size of the **Daily Sequence**
- An **Audio Hadith** may have one saved **Playback Position**
- An **Audio Hadith** is either **Listened** or not Listened for the listener
- An **Audio Hadith** may have zero or one **Transcript**
- An **Audio Hadith** may have zero or one **Translation**
- An **Audio Hadith** may have **AI Enrichment**
- **Home**, **Library**, and **Settings** are the app's three primary sections
- **Glass Treatment** enhances the interface but must not be required to use the app
- A **Mini Player** appears only when playback is active and the listener is outside **Home**
- A **Player Block** belongs on **Home** and controls the current **Audio Hadith**
- A **Design Guardrail** constrains implementation details across **Home**, **Library**, and **Settings**

## Example dialogue

> **Dev:** "Does the app need a **Transcript** before an **Audio Hadith** can appear in the **Daily Sequence**?"
> **Domain expert:** "No — the audio is the source of truth, and transcripts are optional enrichment."

> **Dev:** "Can the **Bundled Library** update itself from WhatsApp?"
> **Domain expert:** "No — new audio is added through app updates for now."

> **Dev:** "If the listener misses three calendar days, does the **Listening Position** skip ahead?"
> **Domain expert:** "No — the app continues from the next unplayed Audio Hadith."

> **Dev:** "How is the **Daily Sequence** ordered?"
> **Domain expert:** "Oldest exported audio first, using the Source Package file modified dates to preserve the original order."

> **Dev:** "Can the initial import combine audio from multiple exports?"
> **Domain expert:** "No — the first **Bundled Library** comes from one **Source Package**."

> **Dev:** "When does an **Audio Hadith** become **Listened**?"
> **Domain expert:** "When playback reaches the end, or when the listener manually marks it complete."

> **Dev:** "If the listener stops midway through an **Audio Hadith**, does the app start over next time?"
> **Domain expert:** "No — it resumes from the saved **Playback Position**."

> **Dev:** "Should generated English titles replace the Urdu audio as the source of truth?"
> **Domain expert:** "No — **AI Enrichment** helps browsing, but the **Audio Hadith** remains the source of truth."

> **Dev:** "Can the English text be a loose inspirational paraphrase?"
> **Domain expert:** "No — the **Translation** should preserve the exact meaning because the content is religiously important."

> **Dev:** "Should the app display both Urdu and English text?"
> **Domain expert:** "No — display the English **Translation** only; the Urdu **Audio Hadith** remains canonical."

> **Dev:** "Should every player screen show a translation warning?"
> **Domain expert:** "No — use a discreet **Translation Notice** in a sensible one-time or settings/about location."

> **Dev:** "Should the **Home** translation take over the whole screen?"
> **Domain expert:** "No — show the English **Translation** under the player in a compact scrollable section."

> **Dev:** "Should progress create streak or calendar pressure?"
> **Domain expert:** "No — **Library Progress** should only show the listener's place in the sequence."

> **Dev:** "Where does the donation link belong?"
> **Domain expert:** "In **Settings**, alongside the dedication and Translation Notice."

> **Dev:** "Can older iPhones lose core functionality because they do not support Liquid Glass?"
> **Domain expert:** "No — **Glass Treatment** is progressive enhancement only."

> **Dev:** "Should Library rows repeat labels like title, duration, and status?"
> **Domain expert:** "No — use native row structure and visual hierarchy so the labels are obvious."

> **Dev:** "Should Settings look like a custom dedication page?"
> **Domain expert:** "No — keep it as a native grouped settings surface with dedication, donation, notices, and reset controls."

> **Dev:** "Should the launch screen act like a branded splash screen?"
> **Domain expert:** "No — it should resemble the first Home shell and move directly into the app."

## Flagged ambiguities

- "captioning" was used loosely for written support text — resolved: use **Transcript** when referring to optional full text derived from the audio.
