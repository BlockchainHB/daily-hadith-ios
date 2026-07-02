# Scripts

Reusable tooling for preparing and reviewing the bundled hadith library.

## Main Entry Point

```sh
node scripts/hadith-pipeline.mjs <command>
```

Commands:

- `prepare` normalizes source audio into ordered `hadith-###.m4a` files.
- `enrich` transcribes Urdu audio and generates English metadata.
- `review` compares generated content against a second transcript.
- `resolve-flags` runs targeted follow-up review for uncertain items.
- `sync-app` copies reviewed content and normalized audio into the app bundle.

See [../docs/hadith-pipeline.md](../docs/hadith-pipeline.md) for the complete workflow, target flags, and model overrides.

## Legacy Wrappers

These wrappers remain for muscle memory and delegate to the structured pipeline modules:

- `prepare-audio-library.mjs`
- `enrich-hadiths.mjs`
- `review-hadith-enrichment.mjs`
- `resolve-review-flags.mjs`
- `classify-hadith-themes.mjs`

## Environment

Use `.env.local` for local secrets. The repo includes `.env.example` with safe placeholders.
