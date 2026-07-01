import { mkdir, readFile } from "node:fs/promises";
import path from "node:path";
import { resolveAudioFilePath } from "./audio-library.mjs";
import { loadOpenAIKey } from "./env.mjs";
import { readJson, readTextIfPresent, tryReadJson, writeJson, writeText } from "./json.mjs";
import {
  applyReviewToItem,
  reviewSummary,
  selectItems,
  writeReviewedTranscripts,
} from "./manifests.mjs";
import { structuredResponse, transcribeAudioFile } from "./openai.mjs";
import { flagResolutionSchema, reviewSchema } from "./schemas.mjs";

const alternatePrompt = "This is an Urdu Islamic hadith lesson. Preserve Arabic and Islamic terms carefully.";
const thirdPrompt = "Urdu Islamic hadith lesson. Preserve Quranic verses, Arabic phrases, and narrator/source wording carefully.";

export async function reviewHadiths(paths, options = {}) {
  await loadOpenAIKey(paths.envPath);
  await mkdir(paths.alternateTranscriptDir, { recursive: true });
  await mkdir(paths.itemReviewDir, { recursive: true });
  await mkdir(paths.reviewedTranscriptDir, { recursive: true });

  const manifest = await readJson(paths.manifestPath);
  const selected = selectItems(manifest, options);

  for (const item of selected) {
    console.log(`Reviewing ${item.id} (${item.sequence}/${manifest.length})`);
    const primary = await readFile(path.join(paths.transcriptDir, `${item.id}.urdu.txt`), "utf8");
    const alternate = await alternateTranscript(paths, item, options);
    await reviewItem(paths, item, primary.trim(), alternate, options);
  }

  const reviewItems = await loadReviewItems(paths, manifest);
  const reviewedManifest = manifest.map((item) => {
    const review = reviewItems.find((entry) => entry.id === item.id);
    return review ? applyReviewToItem(item, review) : item;
  });
  const summary = reviewSummary(manifest, reviewItems);

  await writeReviewedTranscripts(paths.reviewedTranscriptDir, reviewItems);
  await writeJson(paths.reviewSummaryPath, summary);
  await writeJson(paths.reviewedManifestPath, reviewedManifest);

  if (options.apply) {
    if (reviewItems.length !== manifest.length) {
      console.log(`Skipped apply: reviewed ${reviewItems.length}/${manifest.length}`);
    } else {
      await writeJson(paths.manifestPath, reviewedManifest);
      console.log(`Applied reviewed manifest to ${paths.manifestPath}`);
    }
  }

  return summary;
}

export async function resolveReviewFlags(paths, options = {}) {
  await loadOpenAIKey(paths.envPath);
  await mkdir(paths.thirdTranscriptDir, { recursive: true });

  const manifest = await readJson(paths.manifestPath);
  const summary = await readJson(paths.reviewSummaryPath);
  const flaggedIds = new Set(options.ids?.length
    ? options.ids
    : (summary.needsManualReview ?? []).map((item) => item.id));

  for (const item of manifest.filter((entry) => flaggedIds.has(entry.id))) {
    console.log(`Resolving ${item.id}`);
    const previousReview = await readJson(path.join(paths.itemReviewDir, `${item.id}.review.json`));
    const resolved = await resolveItem(paths, item, previousReview, options);
    await writeJson(path.join(paths.itemReviewDir, `${item.id}.review.json`), resolved);
  }

  return { resolvedCount: flaggedIds.size };
}

async function alternateTranscript(paths, item, options) {
  const outputPath = path.join(paths.alternateTranscriptDir, `${item.id}.urdu.txt`);
  const cached = await readTextIfPresent(outputPath);
  if (cached) return cached;

  const text = await transcribeAudioFile({
    filePath: await resolveAudioFilePath(paths, item),
    fileName: item.audioFileName,
    model: options.alternateTranscribeModel ?? process.env.ALTERNATE_TRANSCRIBE_MODEL ?? "gpt-4o-mini-transcribe",
    prompt: alternatePrompt,
  });
  await writeText(outputPath, text);
  return text;
}

async function thirdTranscript(paths, item, options) {
  const outputPath = path.join(paths.thirdTranscriptDir, `${item.id}.urdu.txt`);
  const cached = await readTextIfPresent(outputPath);
  if (cached) return cached;

  const text = await transcribeAudioFile({
    filePath: await resolveAudioFilePath(paths, item),
    fileName: item.audioFileName,
    model: options.thirdTranscribeModel ?? process.env.THIRD_TRANSCRIBE_MODEL ?? "whisper-1",
    prompt: thirdPrompt,
    language: "ur",
  });
  await writeText(outputPath, text);
  return text;
}

async function reviewItem(paths, item, primaryTranscript, alternateTranscriptText, options) {
  const reviewPath = path.join(paths.itemReviewDir, `${item.id}.review.json`);
  const cached = await tryReadJson(reviewPath);
  if (cached?.reviewStatus && cached?.title && cached?.translation) return cached;

  const review = await structuredResponse({
    model: options.reviewModel ?? process.env.REVIEW_MODEL ?? "gpt-4o",
    schema: reviewSchema,
    system: [
      "You are a careful Urdu-to-English hadith content reviewer.",
      "Review religious content conservatively.",
      "Use the two Urdu transcripts as cross-checks for likely speech-to-text errors.",
      "Do not invent missing religious claims.",
      "Produce a user-friendly English title, a faithful summary, and a faithful English translation.",
      "If the two Urdu transcripts materially disagree, flag it instead of guessing.",
      "Return only valid JSON matching the schema.",
    ].join(" "),
    input: reviewInput(item, primaryTranscript, alternateTranscriptText),
  });
  await writeJson(reviewPath, review);
  return review;
}

async function resolveItem(paths, item, previousReview, options) {
  const primary = (await readFile(path.join(paths.transcriptDir, `${item.id}.urdu.txt`), "utf8")).trim();
  const alternate = (await readFile(path.join(paths.alternateTranscriptDir, `${item.id}.urdu.txt`), "utf8")).trim();
  const third = await thirdTranscript(paths, item, options);

  return structuredResponse({
    model: options.reviewModel ?? process.env.REVIEW_MODEL ?? "gpt-4o",
    schema: flagResolutionSchema,
    system: [
      "You are resolving a flagged Urdu hadith transcription review.",
      "Use three independent transcripts plus the previous review.",
      "Be conservative with Quranic quotes and attribution.",
      "If the audio-derived transcripts still materially disagree, keep needs_manual_review.",
      "Otherwise produce a corrected final title, summary, translation, and reviewed Urdu transcript.",
      "Return only valid JSON matching the schema.",
    ].join(" "),
    input: {
      item: reviewItemSummary(item),
      primaryUrduTranscript: primary,
      alternateUrduTranscript: alternate,
      thirdUrduTranscript: third,
      previousReview,
    },
  });
}

async function loadReviewItems(paths, manifest) {
  const reviewItems = [];
  for (const item of manifest) {
    const review = await tryReadJson(path.join(paths.itemReviewDir, `${item.id}.review.json`));
    if (review) reviewItems.push({ id: item.id, sequence: item.sequence, ...review });
  }
  return reviewItems;
}

function reviewInput(item, primaryTranscript, alternateTranscriptText) {
  return {
    item: reviewItemSummary(item),
    primaryUrduTranscript: primaryTranscript,
    alternateUrduTranscript: alternateTranscriptText,
    titleGuidelines: [
      "Use plain, friendly English.",
      "Maximum 8 words.",
      "Avoid vague titles like Daily Hadith or Islamic Reminder.",
      "Prefer the practical theme, e.g. Charity to Relatives, Avoid Suspicion, Fasting and Quran.",
    ],
    reviewInstructions: [
      "Correct the English translation if it drifts from the Urdu transcripts.",
      "Keep hadith/source attributions if spoken.",
      "Preserve religious meaning over smooth paraphrase.",
      "Set reviewStatus to pass, needs_manual_review, or corrected.",
    ],
  };
}

function reviewItemSummary(item) {
  return {
    id: item.id,
    sequence: item.sequence,
    durationSeconds: item.durationSeconds,
    currentTitle: item.title,
    currentSummary: item.summary,
    currentTranslation: item.translation,
    currentUncertaintyNote: item.uncertaintyNote,
  };
}
