# Hadith Content Pipeline

The Hadith pipeline turns an exported audio package into reusable app content:

1. Normalize audio into ordered `hadith-###.m4a` files.
2. Generate Urdu transcripts plus English titles, summaries, and translations.
3. Review translations against a second transcript.
4. Resolve flagged reviews with a third transcript when needed.

The Urdu audio remains the source of truth. Generated text is app metadata and should stay reviewable.

## Layout

- `Content/Audio/` — local normalized audio cache produced by `prepare` (ignored by git).
- `DailyHadithApp/Resources/Audio/` — committed bundled app audio.
- `Content/hadiths.source.json` — source-order manifest from the audio package.
- `Content/hadiths.json` — app manifest consumed by the iOS app.
- `Content/Transcripts/` — primary Urdu transcripts and English enrichment JSON.
- `Content/Review/AlternateTranscripts/` — second transcription pass for review.
- `Content/Review/ThirdTranscripts/` — targeted third transcription pass for flagged items.
- `Content/Review/Items/` — per-hadith review JSON.
- `Content/Review/review-summary.json` — aggregate review status.

## Commands

Run the umbrella CLI:

```sh
node scripts/hadith-pipeline.mjs prepare
node scripts/hadith-pipeline.mjs enrich
node scripts/hadith-pipeline.mjs review --apply
node scripts/hadith-pipeline.mjs sync-app
node scripts/hadith-pipeline.mjs resolve-flags
node scripts/hadith-pipeline.mjs review --apply
```

The old command names still work as wrappers:

```sh
node scripts/prepare-audio-library.mjs
node scripts/enrich-hadiths.mjs
node scripts/review-hadith-enrichment.mjs --apply
node scripts/resolve-review-flags.mjs
```

Run `sync-app` after changing reviewed metadata or audio. It copies the reviewed manifest and normalized audio into the app resource bundle. Review/enrich commands can read from either `Content/Audio/` or the committed app audio bundle, so a fresh checkout can still rerun text review for one hadith without rebuilding the whole local audio cache.

## Running One Or Many Hadiths

Target specific hadiths:

```sh
node scripts/hadith-pipeline.mjs enrich --ids hadith-023,hadith-111
node scripts/hadith-pipeline.mjs review --ids hadith-023,hadith-111 --apply
node scripts/hadith-pipeline.mjs resolve-flags --ids hadith-023
```

Target a range:

```sh
node scripts/hadith-pipeline.mjs enrich --start-at 40 --limit 10
node scripts/hadith-pipeline.mjs review --start-at 40 --limit 10
```

Review commands always rebuild the aggregate review summary from all cached item reviews, so the final count may show `118/118` even when only one item was newly processed.

## Model Overrides

The defaults are:

- Primary transcription: `gpt-4o-transcribe`
- Enrichment/review text model: `gpt-4o`
- Review transcript: `gpt-4o-mini-transcribe`
- Third transcript for flags: `whisper-1`

Override from environment variables or CLI flags:

```sh
TRANSCRIBE_MODEL=gpt-4o-transcribe node scripts/hadith-pipeline.mjs enrich --ids hadith-001
node scripts/hadith-pipeline.mjs review --review-model gpt-4o --ids hadith-001
```

## Quality Gates

Before app work, verify:

```sh
for file in scripts/*.mjs scripts/hadith-pipeline/*.mjs; do node --check "$file"; done
node scripts/hadith-pipeline.mjs enrich --ids hadith-001
node scripts/hadith-pipeline.mjs review --ids hadith-001
```

Then inspect `Content/Review/review-summary.json`. Items marked `needs_manual_review` should keep their uncertainty notes until a human verifies the source content.
