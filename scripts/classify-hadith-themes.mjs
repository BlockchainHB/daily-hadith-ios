#!/usr/bin/env node
import { optionArg, parseArgs } from "./hadith-pipeline/cli.mjs";
import { applyHadithThemes, classifyHadithThemes } from "./hadith-pipeline/themes.mjs";
import { pipelinePaths } from "./hadith-pipeline/paths.mjs";

const args = parseArgs();
const paths = pipelinePaths({ contentDir: optionArg(args, "content", "Content") });
const mode = optionArg(args, "mode", "classify");

if (mode === "apply") {
  const result = await applyHadithThemes(paths);
  console.log(`Applied ${result.selectedCount}/${result.totalCount} theme assignments`);
} else {
  const result = await classifyHadithThemes(paths, {
    textModel: optionArg(args, "text_model", process.env.TEXT_MODEL ?? "gpt-4o"),
    batchSize: Number(optionArg(args, "batch_size", "24")),
  });
  console.log(`Wrote ${paths.themeManifestPath}`);
  console.log(`Classified ${result.selectedCount}/${result.totalCount}`);
}
