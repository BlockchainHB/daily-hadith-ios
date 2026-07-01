import { readFile } from "node:fs/promises";

function loadEnvContent(content) {
  for (const line of content.split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#") || !trimmed.includes("=")) continue;
    const [name, ...valueParts] = trimmed.split("=");
    if (!process.env[name]) {
      process.env[name] = valueParts.join("=").replace(/^["']|["']$/g, "");
    }
  }
}

export async function loadOpenAIKey(envPath) {
  try {
    loadEnvContent(await readFile(envPath, "utf8"));
  } catch {
    // Environment-only usage is fine.
  }

  if (!process.env.OPENAI_API_KEY) {
    throw new Error("OPENAI_API_KEY is not set.");
  }
}
