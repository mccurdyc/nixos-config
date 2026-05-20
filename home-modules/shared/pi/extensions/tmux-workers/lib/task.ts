/**
 * Worker task construction — builds the full text sent to a worker pi session.
 *
 * The "worker contract" is a non-negotiable preamble that constrains the
 * worker's behavior: it must write only to its dedicated directory, must not
 * load skills, and must signal completion via the result file.
 */

/**
 * Build the full task text that a worker receives as its first message.
 *
 * The returned string has a worker contract preamble (rules the worker must
 * follow) followed by the coordinator's original task description.
 */
export function buildWorkerTask(task: string, resultFile: string, workerDir: string): string {
	return [
		"[WORKER CONTRACT — non-negotiable]",
		"You are a sub-worker spawned by a coordinator. Your role is to",
		"complete the task below and write your output to the result file.",
		"",
		"Rules:",
		`- Your result file: ${resultFile}`,
		`- Your worker directory: ${workerDir}`,
		"- Writing the result file signals the coordinator that you are done",
		"- Do NOT load any skills (e.g., /skill:review, /skill:plan)",
		"- Do NOT write to shared output paths like ~/agt/reviews/ or ~/agt/plans/",
		"- You MAY create additional files in your worker directory if needed",
		"- Do NOT write files anywhere else \u2014 only your worker directory",
		"- The coordinator will assemble your output into the final deliverable",
		"- Follow the format and structure described in the task, not a skill",
		"[END CONTRACT]",
		"",
		task,
	].join("\n");
}
