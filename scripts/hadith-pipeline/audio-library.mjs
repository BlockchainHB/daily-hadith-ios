import { execFileSync } from "node:child_process";
import { access, copyFile, mkdir, readdir, rm, stat } from "node:fs/promises";
import path from "node:path";
import { readJson, writeJson } from "./json.mjs";

const audioExtensions = new Set([".aac", ".m4a", ".mp3", ".opus"]);

export async function prepareAudioLibrary(paths) {
  const sourceFiles = await collectAudioFiles(paths.sourceDir);
  const orderedFiles = await orderByModifiedDate(sourceFiles);

  await rm(paths.audioDir, { recursive: true, force: true });
  await mkdir(paths.audioDir, { recursive: true });

  const manifest = [];
  const expectedFileNames = new Set();
  for (const [index, item] of orderedFiles.entries()) {
    const sequence = index + 1;
    const id = `hadith-${String(sequence).padStart(3, "0")}`;
    const extension = path.extname(item.filePath).toLowerCase();
    const audioFileName = `${id}.m4a`;
    const outputPath = path.join(paths.audioDir, audioFileName);
    expectedFileNames.add(audioFileName);

    if (extension === ".m4a") {
      await copyFile(item.filePath, outputPath);
    } else {
      remuxToM4a(item.filePath, outputPath);
    }

    manifest.push({
      id,
      sequence,
      audioFileName,
      sourceExtension: extension,
      durationSeconds: durationSeconds(outputPath),
      sourceFileName: path.basename(item.filePath),
      sourceModifiedAt: item.fileStats.mtime.toISOString(),
      sourceFileSize: item.fileStats.size,
    });
  }

  await pruneUnexpectedAudioFiles(paths.audioDir, expectedFileNames);
  await writeJson(paths.sourceManifestPath, manifest);
  return manifest;
}

export async function resolveAudioFilePath(paths, item) {
  for (const dir of [paths.audioDir, paths.appAudioDir]) {
    const filePath = path.join(dir, item.audioFileName);
    try {
      await access(filePath);
      return filePath;
    } catch {
      // Try the next canonical audio location.
    }
  }

  throw new Error(`Audio file is missing: ${item.audioFileName}`);
}

export async function syncAppResources(paths) {
  const manifest = await readJson(paths.reviewedManifestPath);
  await writeJson(paths.appReviewedManifestPath, manifest);

  await mkdir(paths.appAudioDir, { recursive: true });
  const expectedFileNames = new Set(manifest.map((item) => item.audioFileName));

  for (const fileName of expectedFileNames) {
    const sourcePath = await resolveAudioFilePath(paths, { audioFileName: fileName });
    await copyFile(sourcePath, path.join(paths.appAudioDir, fileName));
  }

  await pruneUnexpectedAudioFiles(paths.appAudioDir, expectedFileNames);
  return { audioCount: expectedFileNames.size, manifestPath: paths.appReviewedManifestPath };
}

async function collectAudioFiles(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...await collectAudioFiles(fullPath));
    } else if (audioExtensions.has(path.extname(entry.name).toLowerCase())) {
      files.push(fullPath);
    }
  }

  return files;
}

async function orderByModifiedDate(files) {
  const withStats = await Promise.all(files.map(async (filePath) => ({
    filePath,
    fileStats: await stat(filePath),
  })));

  return withStats.sort((left, right) => {
    const mtimeDelta = left.fileStats.mtimeMs - right.fileStats.mtimeMs;
    if (mtimeDelta !== 0) return mtimeDelta;
    return path.basename(left.filePath).localeCompare(path.basename(right.filePath));
  });
}

async function pruneUnexpectedAudioFiles(dir, expectedFileNames) {
  const entries = await readdir(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      await rm(fullPath, { recursive: true, force: true });
    } else if (!expectedFileNames.has(entry.name)) {
      await rm(fullPath, { force: true });
    }
  }
}

function remuxToM4a(inputPath, outputPath) {
  execFileSync("ffmpeg", [
    "-v", "error",
    "-y",
    "-i", inputPath,
    "-c:a", "copy",
    outputPath,
  ]);
}

function durationSeconds(filePath) {
  const output = execFileSync("ffprobe", [
    "-v", "error",
    "-show_entries", "format=duration",
    "-of", "default=noprint_wrappers=1:nokey=1",
    filePath,
  ], { encoding: "utf8" }).trim();

  return Number(Number(output).toFixed(3));
}
