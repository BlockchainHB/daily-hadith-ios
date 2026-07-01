import { readFile, stat } from "node:fs/promises";

export async function audioFileForUpload(filePath, fileName) {
  const fileStats = await stat(filePath);
  const fileBytes = await readFile(filePath);
  const { File } = await import("node:buffer");
  return new File([fileBytes], fileName, {
    type: "audio/mp4",
    lastModified: fileStats.mtimeMs,
  });
}

export async function transcribeAudioFile({
  filePath,
  fileName,
  model,
  prompt,
  language,
}) {
  const form = new FormData();
  form.append("file", await audioFileForUpload(filePath, fileName));
  form.append("model", model);
  form.append("response_format", "text");
  if (prompt) form.append("prompt", prompt);
  if (language) form.append("language", language);

  const response = await fetch("https://api.openai.com/v1/audio/transcriptions", {
    method: "POST",
    headers: { Authorization: `Bearer ${process.env.OPENAI_API_KEY}` },
    body: form,
  });

  if (!response.ok) {
    throw new Error(`Transcription failed for ${fileName}: ${response.status} ${await response.text()}`);
  }

  return (await response.text()).trim();
}

export async function structuredResponse({ model, schema, system, input }) {
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      input: [
        {
          role: "system",
          content: [{ type: "input_text", text: system }],
        },
        {
          role: "user",
          content: [{ type: "input_text", text: JSON.stringify(input) }],
        },
      ],
      text: {
        format: {
          type: "json_schema",
          name: schema.name,
          strict: true,
          schema: schema.schema,
        },
      },
    }),
  });

  if (!response.ok) {
    throw new Error(`Structured response failed: ${response.status} ${await response.text()}`);
  }

  const payload = await response.json();
  const outputText = payload.output_text
    ?? payload.output?.flatMap((entry) => entry.content ?? [])
      .find((part) => part.type === "output_text")?.text;

  if (!outputText) {
    throw new Error("Structured response did not include output_text.");
  }

  return JSON.parse(outputText);
}
