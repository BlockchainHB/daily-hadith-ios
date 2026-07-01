#!/usr/bin/env node
import { listArg, numberArg, optionArg, parseArgs } from "./hadith-pipeline/cli.mjs";
import { reviewHadiths } from "./hadith-pipeline/review.mjs";
import { pipelinePaths } from "./hadith-pipeline/paths.mjs";

const args = parseArgs();
const paths = pipelinePaths({ contentDir: optionArg(args, "content", "Content") });
const summary = await reviewHadiths(paths, {
  apply: Boolean(args.apply),
  ids: listArg(args, "ids"),
  startAt: numberArg(args, "start_at", 1),
  limit: numberArg(args, "limit", 0),
  alternateTranscribeModel: optionArg(args, "alternate_transcribe_model", process.env.ALTERNATE_TRANSCRIBE_MODEL ?? "gpt-4o-mini-transcribe"),
  reviewModel: optionArg(args, "review_model", process.env.REVIEW_MODEL ?? "gpt-4o"),
});

console.log(`Reviewed ${summary.reviewedCount}/${summary.totalCount}`);
console.log(`Wrote ${paths.reviewedManifestPath}`);
console.log(`Wrote ${paths.reviewSummaryPath}`);
