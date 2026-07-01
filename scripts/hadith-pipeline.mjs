#!/usr/bin/env node
import { prepareAudioLibrary, syncAppResources } from "./hadith-pipeline/audio-library.mjs";
import { listArg, numberArg, optionArg, parseArgs } from "./hadith-pipeline/cli.mjs";
import { enrichHadiths } from "./hadith-pipeline/enrichment.mjs";
import { pipelinePaths } from "./hadith-pipeline/paths.mjs";
import { resolveReviewFlags, reviewHadiths } from "./hadith-pipeline/review.mjs";

const args = parseArgs();
const command = args._[0];
const paths = pipelinePaths({
  sourceDir: optionArg(args, "source", "imports/raw/Hadith"),
  contentDir: optionArg(args, "content", "Content"),
});

switch (command) {
  case "prepare": {
    const manifest = await prepareAudioLibrary(paths);
    console.log(`Prepared ${manifest.length} audio files in ${paths.audioDir}`);
    break;
  }
  case "enrich": {
    const result = await enrichHadiths(paths, commonSelection(args));
    console.log(`Enriched ${result.selectedCount}/${result.totalCount}`);
    break;
  }
  case "review": {
    const summary = await reviewHadiths(paths, {
      ...commonSelection(args),
      apply: Boolean(args.apply),
    });
    console.log(`Reviewed ${summary.reviewedCount}/${summary.totalCount}`);
    break;
  }
  case "resolve-flags": {
    const result = await resolveReviewFlags(paths, {
      ids: listArg(args, "ids"),
      thirdTranscribeModel: optionArg(args, "third_transcribe_model", process.env.THIRD_TRANSCRIBE_MODEL ?? "whisper-1"),
      reviewModel: optionArg(args, "review_model", process.env.REVIEW_MODEL ?? "gpt-4o"),
    });
    console.log(`Resolved ${result.resolvedCount} flagged item(s).`);
    break;
  }
  case "sync-app": {
    const result = await syncAppResources(paths);
    console.log(`Synced ${result.audioCount} audio files and manifest to app resources.`);
    break;
  }
  default:
    console.log([
      "Usage:",
      "  node scripts/hadith-pipeline.mjs prepare [--source imports/raw/Hadith] [--content Content]",
      "  node scripts/hadith-pipeline.mjs enrich [--ids hadith-001,hadith-002 | --start-at 1 --limit 10]",
      "  node scripts/hadith-pipeline.mjs review [--apply] [--ids hadith-001 | --start-at 1 --limit 10]",
      "  node scripts/hadith-pipeline.mjs resolve-flags [--ids hadith-023,hadith-111]",
      "  node scripts/hadith-pipeline.mjs sync-app",
    ].join("\n"));
    process.exitCode = 1;
}

function commonSelection(args) {
  return {
    ids: listArg(args, "ids"),
    startAt: numberArg(args, "start_at", 1),
    limit: numberArg(args, "limit", 0),
    transcribeModel: optionArg(args, "transcribe_model", process.env.TRANSCRIBE_MODEL ?? "gpt-4o-transcribe"),
    textModel: optionArg(args, "text_model", process.env.TEXT_MODEL ?? "gpt-4o"),
    alternateTranscribeModel: optionArg(args, "alternate_transcribe_model", process.env.ALTERNATE_TRANSCRIBE_MODEL ?? "gpt-4o-mini-transcribe"),
    reviewModel: optionArg(args, "review_model", process.env.REVIEW_MODEL ?? "gpt-4o"),
  };
}
