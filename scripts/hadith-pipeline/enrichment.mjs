import { mkdir } from "node:fs/promises";
import path from "node:path";
import { loadOpenAIKey } from "./env.mjs";
import { resolveAudioFilePath } from "./audio-library.mjs";
import { readJson, readTextIfPresent, tryReadJson, writeJson, writeText } from "./json.mjs";
import { mergeBySourceOrder, selectItems } from "./manifests.mjs";
import { transcribeAudioFile, structuredResponse } from "./openai.mjs";
import { enrichmentSchema } from "./schemas.mjs";

const defaultTranscribePrompt = "This is an Urdu Islamic hadith lesson or recitation. Preserve religious terminology carefully.";

export async function enrichHadiths(paths, options = {}) {
  await loadOpenAIKey(paths.envPath);
  await mkdir(paths.transcriptDir, { recursive: true });

  const sourceManifest = await readJson(paths.sourceManifestPath);
  const existingManifest = await tryReadJson(paths.manifestPath, sourceManifest.map((item) => ({ ...item })));
  const selected = selectItems(sourceManifest, options);
  const updates = [];

  for (const item of selected) {
    console.log(`Enriching ${item.id} (${item.sequence}/${sourceManifest.length})`);
    const urduTranscript = await transcribePrimary(paths, item, options);
    const english = await translateAndTitle(paths, item, urduTranscript, options);
    updates.push({
      ...item,
      title: english.title,
      summary: english.summary,
      translation: english.translation,
      uncertaintyNote: english.uncertaintyNote,
      transcriptFileName: `${item.id}.urdu.txt`,
    });
  }

  const completeManifest = mergeBySourceOrder(sourceManifest, existingManifest, updates);
  await writeJson(paths.manifestPath, completeManifest);
  return { selectedCount: selected.length, totalCount: sourceManifest.length };
}

async function transcribePrimary(paths, item, options) {
  const transcriptPath = path.join(paths.transcriptDir, `${item.id}.urdu.txt`);
  const cached = await readTextIfPresent(transcriptPath);
  if (cached) return cached;

  const text = await transcribeAudioFile({
    filePath: await resolveAudioFilePath(paths, item),
    fileName: item.audioFileName,
    model: options.transcribeModel ?? process.env.TRANSCRIBE_MODEL ?? "gpt-4o-transcribe",
    prompt: defaultTranscribePrompt,
  });
  await writeText(transcriptPath, text);
  return text;
}

async function translateAndTitle(paths, item, urduTranscript, options) {
  const translationPath = path.join(paths.transcriptDir, `${item.id}.english.json`);
  const cached = await tryReadJson(translationPath);
  if (cached?.translation?.trim()) return cached;

  const enrichment = await structuredResponse({
    model: options.textModel ?? process.env.TEXT_MODEL ?? "gpt-4o",
    schema: enrichmentSchema,
    system: [
      "You translate Urdu Islamic hadith audio transcripts into faithful English.",
      "Preserve the exact religious meaning; do not embellish.",
      "If wording is uncertain, include a concise uncertainty note instead of guessing.",
      "Return only valid JSON matching the requested shape.",
    ].join(" "),
    input: {
      id: item.id,
      sequence: item.sequence,
      urduTranscript,
      requiredJsonShape: {
        title: "Short specific English title, maximum 8 words",
        summary: "One sentence faithful summary",
        translation: "Faithful English translation preserving the spoken content",
        uncertaintyNote: "Empty string if none",
      },
    },
  });

  await writeJson(translationPath, enrichment);
  return enrichment;
}
