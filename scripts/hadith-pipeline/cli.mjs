export function parseArgs(argv = process.argv.slice(2)) {
  const args = { _: [] };

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (!token.startsWith("--")) {
      args._.push(token);
      continue;
    }

    const [rawName, inlineValue] = token.slice(2).split("=", 2);
    const name = rawName.replaceAll("-", "_");
    if (inlineValue !== undefined) {
      args[name] = inlineValue;
      continue;
    }

    const next = argv[index + 1];
    if (!next || next.startsWith("--")) {
      args[name] = true;
      continue;
    }

    args[name] = next;
    index += 1;
  }

  return args;
}

export function numberArg(args, name, fallback) {
  const value = args[name];
  if (value === undefined || value === true || value === "") return fallback;
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    throw new Error(`--${name.replaceAll("_", "-")} must be a number.`);
  }
  return parsed;
}

export function listArg(args, name) {
  const value = args[name];
  if (!value || value === true) return [];
  return String(value)
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
}

export function optionArg(args, name, fallback) {
  const value = args[name];
  if (value === undefined || value === true || value === "") return fallback;
  return String(value);
}
