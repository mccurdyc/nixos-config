/**
 * Content of the launcher script written to `~/agt/pi/tmux-workers/.bin/launcher.mjs`
 * on every delegate call. See that on-disk file at runtime, and this module
 * at edit/review time.
 */

// biome-ignore lint/suspicious/noTemplateCurlyInString: <multiple regex backslashes must survive template parsing>
export const LAUNCHER_CONTENT = `#!/usr/bin/env node
import { spawn } from "node:child_process";
import { readFileSync, existsSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";

const taskFile = process.argv[2];
const cwd = process.argv[3];
const model = process.argv[4] || "";
const thinking = process.argv[5] || "";

if (!taskFile || !cwd) {
  console.error("Usage: launcher.mjs <taskFile> <cwd> [model] [thinking]");
  process.exit(1);
}

const task = readFileSync(taskFile, "utf8");
process.chdir(cwd);

const workerDir = dirname(taskFile);
const resultFile = join(workerDir, "result.md");
const statusFile = join(workerDir, "status.json");
const heartbeatFile = join(workerDir, "heartbeat");
const paneLog = join(workerDir, "pane.log");
const errorLog = join(workerDir, "error.log");
const doneFile = join(workerDir, "done");

const startedAt = new Date().toISOString();

function writeStatus(status) {
  try {
    writeFileSync(statusFile, JSON.stringify(status, null, 2), "utf-8");
  } catch {}
}

function touch(p) {
  try { writeFileSync(p, ""); } catch {}
}

// Strip CSI / OSC / simple escape sequences so error.log is readable.
function stripAnsi(s) {
  return s
    .replace(/\\x1B\\[[0-?]*[ -\\/]*[@-~]/g, "")
    .replace(/\\x1B\\][^\\x07]*(\\x07|\\x1B\\\\)/g, "")
    .replace(/\\x1B[@-Z\\\\-_]/g, "");
}

function tailLines(text, n) {
  const lines = text.split("\\n");
  return lines.slice(Math.max(0, lines.length - n)).join("\\n");
}

const args = [];
if (model) args.push("--model", model);
if (thinking) args.push("--thinking", thinking);
args.push(task);
const child = spawn("pi", args, { stdio: "inherit", env: { ...process.env, PI_TMUX_WORKER: "1" } });
const childPid = child.pid;

writeStatus({ state: "running", pid: process.pid, childPid, startedAt });
touch(heartbeatFile);
const heartbeat = setInterval(() => touch(heartbeatFile), 2000);

// Poll every 250ms for result.md. Once the worker writes it, pi has
// finished its work — send SIGTERM so the process exits cleanly.
const poller = setInterval(() => {
  if (existsSync(resultFile)) {
    clearInterval(poller);
    // Small delay to let the write tool finish flushing content
    // before we SIGTERM the process.
    setTimeout(() => {
      child.kill("SIGTERM");
    }, 500);
  }
}, 250);

child.on("exit", (code) => {
  clearInterval(poller);
  clearInterval(heartbeat);

  const exitedAt = new Date().toISOString();
  const resultWritten = existsSync(resultFile);

  writeStatus({
    state: "exited",
    pid: process.pid,
    childPid,
    startedAt,
    exitedAt,
    exitCode: code ?? 0,
    resultWritten,
  });

  // On failure, distill the pane log into a human-readable error.log.
  if (!resultWritten) {
    try {
      const raw = existsSync(paneLog) ? readFileSync(paneLog, "utf-8") : "";
      const stripped = stripAnsi(raw);
      const tail = tailLines(stripped, 200);
      writeFileSync(errorLog, tail, "utf-8");
    } catch {}
  }

  // Write the done sentinel last so readers see status.json + error.log first.
  writeFileSync(doneFile, "");
  process.exit(code ?? 0);
});
`;
