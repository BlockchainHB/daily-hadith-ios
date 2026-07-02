export const enrichmentSchema = {
  name: "hadith_enrichment",
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      title: { type: "string" },
      summary: { type: "string" },
      translation: { type: "string" },
      uncertaintyNote: { type: "string" },
    },
    required: ["title", "summary", "translation", "uncertaintyNote"],
  },
};

export const reviewSchema = {
  name: "hadith_review",
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      reviewStatus: { type: "string", enum: ["pass", "corrected", "needs_manual_review"] },
      title: { type: "string" },
      summary: { type: "string" },
      translation: { type: "string" },
      reviewedUrduTranscript: { type: "string" },
      uncertaintyNote: { type: "string" },
      issues: { type: "array", items: { type: "string" } },
      titleChanged: { type: "boolean" },
      translationChanged: { type: "boolean" },
      transcriptChanged: { type: "boolean" },
      confidence: { type: "string", enum: ["high", "medium", "low"] },
    },
    required: [
      "reviewStatus",
      "title",
      "summary",
      "translation",
      "reviewedUrduTranscript",
      "uncertaintyNote",
      "issues",
      "titleChanged",
      "translationChanged",
      "transcriptChanged",
      "confidence",
    ],
  },
};

export const flagResolutionSchema = {
  name: "hadith_flag_resolution",
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      ...reviewSchema.schema.properties,
      resolutionNote: { type: "string" },
    },
    required: [...reviewSchema.schema.required, "resolutionNote"],
  },
};

export const themeClassificationSchema = {
  name: "hadith_theme_classification",
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      assignments: {
        type: "array",
        items: {
          type: "object",
          additionalProperties: false,
          properties: {
            id: { type: "string" },
            primaryThemeID: {
              type: "string",
              enum: [
                "faith-trust",
                "character",
                "worship",
                "quran-dhikr",
                "mercy-repentance",
                "family-community",
                "livelihood-charity",
                "ramadan-fasting",
              ],
            },
            secondaryThemeIDs: {
              type: "array",
              items: {
                type: "string",
                enum: [
                  "faith-trust",
                  "character",
                  "worship",
                  "quran-dhikr",
                  "mercy-repentance",
                  "family-community",
                  "livelihood-charity",
                  "ramadan-fasting",
                ],
              },
            },
            confidence: { type: "string", enum: ["high", "medium", "low"] },
            rationale: { type: "string" },
          },
          required: ["id", "primaryThemeID", "secondaryThemeIDs", "confidence", "rationale"],
        },
      },
    },
    required: ["assignments"],
  },
};
