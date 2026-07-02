import { loadOpenAIKey } from "./env.mjs";
import { readJson, writeJson } from "./json.mjs";
import { structuredResponse } from "./openai.mjs";
import { themeClassificationSchema } from "./schemas.mjs";

export const themeDefinitions = [
  {
    id: "faith-trust",
    title: "Faith & Trust",
    description: "Belief, tawakkul, certainty, hereafter, hypocrisy, and standing firm.",
  },
  {
    id: "character",
    title: "Character",
    description: "Manners, patience, gentleness, honesty, avoiding sins, and personal conduct.",
  },
  {
    id: "worship",
    title: "Worship",
    description: "Prayer, purification, fasting outside Ramadan, religious duties, and worship habits.",
  },
  {
    id: "quran-dhikr",
    title: "Quran & Dhikr",
    description: "Quran recitation, remembrance of Allah, salawat, durood, and sacred knowledge.",
  },
  {
    id: "mercy-repentance",
    title: "Mercy & Repentance",
    description: "Allah's mercy, forgiveness, repentance, hope, prayer, and divine nearness.",
  },
  {
    id: "family-community",
    title: "Family & Community",
    description: "Parents, relatives, neighbors, orphans, elders, social duties, and community harm.",
  },
  {
    id: "livelihood-charity",
    title: "Livelihood & Charity",
    description: "Trade, halal earning, self-reliance, spending, generosity, and wealth ethics.",
  },
  {
    id: "ramadan-fasting",
    title: "Ramadan & Fasting",
    description: "Ramadan, Sha'ban, fasting, iftar, Taraweeh, and Ramadan-specific virtues.",
  },
];

export async function classifyHadithThemes(paths, options = {}) {
  await loadOpenAIKey(paths.envPath);

  const manifest = await readJson(paths.reviewedManifestPath);
  const payload = manifest.map((item) => ({
    id: item.id,
    title: item.title,
    summary: item.summary,
  }));
  const batchSize = options.batchSize ?? 24;
  const assignments = [];

  for (let index = 0; index < payload.length; index += batchSize) {
    const batch = payload.slice(index, index + batchSize);
    console.log(`Classifying ${index + 1}-${index + batch.length}/${payload.length}`);
    const result = await structuredResponse({
      model: options.textModel ?? process.env.TEXT_MODEL ?? "gpt-4o",
      schema: themeClassificationSchema,
      system: [
        "Classify each Islamic hadith lesson into stable app-library browse themes.",
        "Choose exactly one primaryThemeID that best represents how a user would browse for this hadith.",
        "Choose zero to two secondaryThemeIDs only when genuinely useful.",
        "Do not invent themes. Use only the provided theme IDs.",
        "Prefer balanced coverage across themes when content genuinely supports it, but never force a weak category.",
      ].join(" "),
      input: {
        themes: themeDefinitions,
        hadiths: batch,
      },
    });
    assignments.push(...result.assignments);
  }

  const assignmentsByID = new Map(assignments.map((assignment) => [assignment.id, assignment]));
  const missing = manifest.filter((item) => !assignmentsByID.has(item.id)).map((item) => item.id);
  if (missing.length) {
    throw new Error(`Theme classification missing IDs: ${missing.join(", ")}`);
  }

  await writeJson(paths.themeManifestPath, assignments);
  return { selectedCount: assignments.length, totalCount: manifest.length };
}

export async function applyHadithThemes(paths) {
  const manifest = await readJson(paths.reviewedManifestPath);
  const assignments = await readJson(paths.themeManifestPath);
  const assignmentsByID = new Map(assignments.map((assignment) => [assignment.id, assignment]));

  const updated = manifest.map((item) => {
    const assignment = assignmentsByID.get(item.id);
    if (!assignment) return item;
    return {
      ...item,
      primaryThemeID: assignment.primaryThemeID,
      secondaryThemeIDs: assignment.secondaryThemeIDs,
    };
  });

  await writeJson(paths.reviewedManifestPath, updated);
  await writeJson(paths.appReviewedManifestPath, updated);

  return { selectedCount: assignments.length, totalCount: manifest.length };
}
