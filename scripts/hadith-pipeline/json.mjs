import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

export async function readJson(filePath) {
  return JSON.parse(await readFile(filePath, "utf8"));
}

export async function tryReadJson(filePath, fallback = null) {
  try {
    return await readJson(filePath);
  } catch {
    return fallback;
  }
}

export async function writeJson(filePath, value) {
  await mkdir(path.dirname(filePath), { recursive: true });
  await writeFile(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

export async function readTextIfPresent(filePath) {
  try {
    const text = await readFile(filePath, "utf8");
    return text.trim() ? text.trim() : null;
  } catch {
    return null;
  }
}

export async function writeText(filePath, text) {
  await mkdir(path.dirname(filePath), { recursive: true });
  await writeFile(filePath, `${text.trim()}\n`);
}
