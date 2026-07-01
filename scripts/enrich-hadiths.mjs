#!/usr/bin/env node
import { listArg, numberArg, optionArg, parseArgs } from "./hadith-pipeline/cli.mjs";
import { enrichHadiths } from "./hadith-pipeline/enrichment.mjs";
import { pipelinePaths } from "./hadith-pipeline/paths.mjs";

const args = parseArgs();
const paths = pipelinePaths({ contentDir: optionArg(args, "content", "Content") });
const result = await enrichHadiths(paths, {
  ids: listArg(args, "ids"),
  startAt: numberArg(args, "start_at", 1),
  limit: numberArg(args, "limit", 0),
  transcribeModel: optionArg(args, "transcribe_model", process.env.TRANSCRIBE_MODEL ?? "gpt-4o-transcribe"),
  textModel: optionArg(args, "text_model", process.env.TEXT_MODEL ?? "gpt-4o"),
});

console.log(`Updated ${paths.manifestPath}`);
console.log(`Enriched ${result.selectedCount}/${result.totalCount}`);
