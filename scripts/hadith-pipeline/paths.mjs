import path from "node:path";
import { fileURLToPath } from "node:url";

export const workspaceRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../..",
);

export function pipelinePaths(overrides = {}) {
  const contentDir = path.resolve(workspaceRoot, overrides.contentDir ?? "Content");
  const reviewDir = path.join(contentDir, "Review");

  return {
    workspaceRoot,
    envPath: path.resolve(workspaceRoot, overrides.envPath ?? ".env.local"),
    sourceDir: path.resolve(workspaceRoot, overrides.sourceDir ?? "imports/raw/Hadith"),
    contentDir,
    audioDir: path.join(contentDir, "Audio"),
    appAudioDir: path.join(workspaceRoot, "DailyHadithApp/Resources/Audio"),
    transcriptDir: path.join(contentDir, "Transcripts"),
    sourceManifestPath: path.join(contentDir, "hadiths.source.json"),
    manifestPath: path.join(contentDir, "hadiths.json"),
    reviewedManifestPath: path.join(contentDir, "hadiths.reviewed.json"),
    themeManifestPath: path.join(contentDir, "hadith-themes.reviewed.json"),
    appReviewedManifestPath: path.join(workspaceRoot, "DailyHadithApp/Resources/hadiths.reviewed.json"),
    reviewDir,
    alternateTranscriptDir: path.join(reviewDir, "AlternateTranscripts"),
    thirdTranscriptDir: path.join(reviewDir, "ThirdTranscripts"),
    itemReviewDir: path.join(reviewDir, "Items"),
    reviewedTranscriptDir: path.join(reviewDir, "ReviewedTranscripts"),
    reviewSummaryPath: path.join(reviewDir, "review-summary.json"),
  };
}
