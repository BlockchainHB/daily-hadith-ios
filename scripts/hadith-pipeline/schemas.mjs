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
