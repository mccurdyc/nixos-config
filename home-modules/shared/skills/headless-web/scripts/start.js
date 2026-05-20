#!/usr/bin/env node

import { spawn, execSync } from "node:child_process";
import { dirname, join } from "node:path";
import { existsSync } from "node:fs";
import { fileURLToPath, pathToFileURL } from "node:url";
import { platform } from "node:os";

const scriptDir = dirname(fileURLToPath(import.meta.url));

// ── Argument parsing ────────────────────────────────────────────────
const args = process.argv.slice(2);
const wantsHelp = args.includes("--help") || args.includes("-h");
const useProfile = args.includes("--profile");
const forceHeadless = args.includes("--headless");

if (wantsHelp) {
  console.log("Usage: start.js [--profile] [--headless]");
  console.log("");
  console.log("Options:");
  console.log("  --profile   Copy your default Chrome profile (cookies, logins)");
  console.log("  --headless  Force headless mode (auto-detected on Linux without display)");
  console.log("");
  console.log("Environment:");
  console.log("  CHROME_PATH  Override Chrome/Chromium binary path");
  process.exit(0);
}

// ── Auto-install dependencies ───────────────────────────────────────
const wsPath = join(scriptDir, "node_modules", "ws");
if (!existsSync(wsPath)) {
  console.log("○ Installing dependencies …");
  try {
    execSync("npm install --no-audit --no-fund", {
      cwd: scriptDir,
      stdio: "pipe",
    });
    console.log("✓ Dependencies installed");
  } catch (e) {
    console.error("✗ Failed to install dependencies:", e.stderr?.toString().trim() || e.message);
    process.exit(1);
  }
}

// ── Reuse existing instance ─────────────────────────────────────────
async function isDebugEndpointUp() {
  try {
    const response = await fetch("http://localhost:9222/json/version");
    return response.ok;
  } catch {
    return false;
  }
}

if (await isDebugEndpointUp()) {
  console.log("✓ Chrome already running on :9222 (reusing existing instance)");
  process.exit(0);
}

// ── Chrome binary discovery ─────────────────────────────────────────
function findChrome() {
  // Env override first
  if (process.env.CHROME_PATH) {
    return process.env.CHROME_PATH;
  }

  const os = platform();

  if (os === "darwin") {
    const candidates = [
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
      "/Applications/Chromium.app/Contents/MacOS/Chromium",
      "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary",
    ];
    for (const c of candidates) {
      if (existsSync(c)) return c;
    }
    // Fallback: use `open -na` approach (returns null to signal macOS launcher)
    return null;
  }

  // Linux (and others) — prefer native chromium over Rosetta-emulated google-chrome
  const candidates = [
    "chromium",
    "chromium-browser",
    "google-chrome-stable",
    "google-chrome",
  ];
  for (const c of candidates) {
    try {
      const resolved = execSync(`which ${c}`, { stdio: "pipe" }).toString().trim();
      if (resolved) return resolved;
    } catch {
      // not found, try next
    }
  }

  return null;
}

const chromeBinary = findChrome();
const os = platform();

// On macOS, null means we fall back to `open -na "Google Chrome"`
if (chromeBinary === null && os !== "darwin") {
  console.error("✗ Chrome/Chromium not found. Install Chrome or set CHROME_PATH.");
  process.exit(1);
}

// ── Headless detection ──────────────────────────────────────────────
function shouldUseHeadless() {
  if (forceHeadless) return true;
  // On Linux, if there's no display server, headless is the only option
  if (os === "linux" && !process.env.DISPLAY && !process.env.WAYLAND_DISPLAY) {
    return true;
  }
  return false;
}

const headless = shouldUseHeadless();

// ── Profile sync ────────────────────────────────────────────────────
const userDataDir = `${process.env.HOME}/.cache/scraping`;
execSync("mkdir -p " + userDataDir, { stdio: "ignore" });

if (useProfile) {
  let profileSource;
  if (os === "darwin") {
    profileSource = `${process.env.HOME}/Library/Application Support/Google/Chrome/`;
  } else {
    // Linux: try google-chrome first, then chromium
    const linuxCandidates = [
      `${process.env.HOME}/.config/google-chrome/`,
      `${process.env.HOME}/.config/chromium/`,
    ];
    profileSource = linuxCandidates.find((p) => existsSync(p));
  }

  if (profileSource) {
    console.log("○ Syncing Chrome profile …");
    try {
      execSync(`rsync -a --delete "${profileSource}" "${userDataDir}/"`, {
        stdio: "pipe",
      });
    } catch (e) {
      console.error("⚠ Profile sync failed (continuing with fresh profile):", e.message);
    }
  } else {
    console.error("⚠ No Chrome profile found to copy (continuing with fresh profile)");
  }
}

// ── Launch Chrome ───────────────────────────────────────────────────
const commonArgs = [
  "--remote-debugging-port=9222",
  `--user-data-dir=${userDataDir}`,
  "--profile-directory=Default",
  "--disable-search-engine-choice-screen",
  "--no-first-run",
  "--disable-features=ProfilePicker",
  "--no-sandbox",
];

if (headless) {
  commonArgs.push("--headless=new");
  commonArgs.push("--window-size=1280,720");
}

if (os === "darwin" && chromeBinary === null) {
  // macOS fallback: use `open -na` to avoid interfering with personal Chrome
  spawn("/usr/bin/open", ["-na", "Google Chrome", "--args", ...commonArgs], {
    detached: true,
    stdio: "ignore",
  }).unref();
} else if (os === "darwin") {
  // macOS with known binary path — use open -na with the full app bundle
  // Extract the .app path from the binary path
  const appMatch = chromeBinary.match(/^(\/Applications\/[^/]+\.app)\//);
  if (appMatch) {
    spawn("/usr/bin/open", ["-na", appMatch[1], "--args", ...commonArgs], {
      detached: true,
      stdio: "ignore",
    }).unref();
  } else {
    spawn(chromeBinary, commonArgs, {
      detached: true,
      stdio: "ignore",
    }).unref();
  }
} else {
  // Linux / other: spawn the binary directly
  spawn(chromeBinary, commonArgs, {
    detached: true,
    stdio: ["ignore", "ignore", "ignore"],
  }).unref();
}

// ── Wait for Chrome to be ready ─────────────────────────────────────
let connected = false;
for (let i = 0; i < 30; i++) {
  if (await isDebugEndpointUp()) {
    connected = true;
    break;
  }
  await new Promise((r) => setTimeout(r, 500));
}

if (!connected) {
  console.error("✗ Chrome failed to start (timed out after 15s)");
  if (headless) {
    console.error("  Hint: check that the Chrome binary supports --headless=new");
  }
  process.exit(1);
}

// ── Start background watcher ────────────────────────────────────────
const watcherPath = join(scriptDir, "watch.js");
spawn(process.execPath, [watcherPath], {
  detached: true,
  stdio: "ignore",
}).unref();

const modeLabel = [
  useProfile ? "with profile" : null,
  headless ? "headless" : null,
].filter(Boolean).join(", ");

console.log(`✓ Chrome started on :9222${modeLabel ? ` (${modeLabel})` : ""}`);
