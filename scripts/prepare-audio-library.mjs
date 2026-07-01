#!/usr/bin/env node
import { parseArgs, optionArg } from "./hadith-pipeline/cli.mjs";
import { prepareAudioLibrary } from "./hadith-pipeline/audio-library.mjs";
import { pipelinePaths } from "./hadith-pipeline/paths.mjs";

const args = parseArgs();
const paths = pipelinePaths({
  sourceDir: optionArg(args, "source", "imports/raw/Hadith"),
  contentDir: optionArg(args, "content", "Content"),
});

const manifest = await prepareAudioLibrary(paths);
console.log(`Prepared ${manifest.length} audio files in ${paths.audioDir}`);
console.log(`Wrote source manifest to ${paths.sourceManifestPath}`);
