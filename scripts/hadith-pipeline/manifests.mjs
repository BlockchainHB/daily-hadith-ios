import path from "node:path";
import { writeText } from "./json.mjs";

export function selectItems(items, { ids = [], startAt = 1, limit = 0 } = {}) {
  const idSet = new Set(ids);
  const selected = idSet.size > 0
    ? items.filter((item) => idSet.has(item.id))
    : items.filter((item) => item.sequence >= startAt);

  return limit > 0 ? selected.slice(0, limit) : selected;
}

export function mergeBySourceOrder(sourceItems, existingItems, updates) {
  const byId = new Map(existingItems.map((item) => [item.id, item]));
  for (const item of updates) byId.set(item.id, item);
  return sourceItems.map((item) => byId.get(item.id) ?? item);
}

export function applyReviewToItem(item, review) {
  return {
    ...item,
    title: review.title,
    summary: review.summary,
    translation: review.translation,
    uncertaintyNote: review.uncertaintyNote,
    reviewStatus: review.reviewStatus,
    reviewConfidence: review.confidence,
    reviewIssues: review.issues,
    reviewedTranscriptFileName: `${item.id}.reviewed.urdu.txt`,
  };
}

export function reviewSummary(manifest, reviewItems) {
  const reviewById = new Map(reviewItems.map((item) => [item.id, item]));
  const completeReviewItems = manifest
    .map((item) => reviewById.get(item.id))
    .filter(Boolean);

  return {
    reviewedCount: completeReviewItems.length,
    totalCount: manifest.length,
    statusCounts: countBy(completeReviewItems, "reviewStatus"),
    confidenceCounts: countBy(completeReviewItems, "confidence"),
    needsManualReview: completeReviewItems
      .filter((item) => item.reviewStatus === "needs_manual_review" || item.confidence === "low")
      .map((item) => ({
        id: item.id,
        sequence: item.sequence,
        title: item.title,
        confidence: item.confidence,
        issues: item.issues,
        uncertaintyNote: item.uncertaintyNote,
      })),
    titleChangedCount: completeReviewItems.filter((item) => item.titleChanged).length,
    translationChangedCount: completeReviewItems.filter((item) => item.translationChanged).length,
    transcriptChangedCount: completeReviewItems.filter((item) => item.transcriptChanged).length,
  };
}

export async function writeReviewedTranscripts(reviewedTranscriptDir, reviewItems) {
  await Promise.all(reviewItems.map((item) => writeText(
    path.join(reviewedTranscriptDir, `${item.id}.reviewed.urdu.txt`),
    item.reviewedUrduTranscript,
  )));
}

function countBy(items, key) {
  return items.reduce((counts, item) => {
    counts[item[key]] = (counts[item[key]] ?? 0) + 1;
    return counts;
  }, {});
}
