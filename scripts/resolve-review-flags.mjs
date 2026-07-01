#!/usr/bin/env node
import { listArg, optionArg, parseArgs } from "./hadith-pipeline/cli.mjs";
import { resolveReviewFlags } from "./hadith-pipeline/review.mjs";
import { pipelinePaths } from "./hadith-pipeline/paths.mjs";

const args = parseArgs();
const paths = pipelinePaths({ contentDir: optionArg(args, "content", "Content") });
const result = await resolveReviewFlags(paths, {
  ids: listArg(args, "ids"),
  thirdTranscribeModel: optionArg(args, "third_transcribe_model", process.env.THIRD_TRANSCRIBE_MODEL ?? "whisper-1"),
  reviewModel: optionArg(args, "review_model", process.env.REVIEW_MODEL ?? "gpt-4o"),
});

console.log(`Resolved ${result.resolvedCount} flagged item(s).`);
console.log("Run review-hadith-enrichment.mjs --apply to refresh manifests.");
