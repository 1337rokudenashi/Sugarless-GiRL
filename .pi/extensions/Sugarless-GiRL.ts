import { readFileSync, existsSync } from "node:fs";
import { dirname, join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

function findInstructions(startDirectory: string): string | undefined {
	let directory = startDirectory;
	while (true) {
		const instructions = join(directory, "Sugarless-GiRL.md");
		if (existsSync(instructions)) {
			return instructions;
		}
		const parent = dirname(directory);
		if (parent === directory) {
			return undefined;
		}
		directory = parent;
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerMcpServer("burp", {
		url: "http://127.0.0.1:9876/mcp",
		exposure: "codemode",
		enabled: true,
	});

	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode === "tui") {
			ctx.ui.setWidget("sugarless-girl", (_tui, theme) => new Text(theme.fg("dim", [
				" Pi · Sugarless-GiRL",
				"",
				" Sugarless-GiRL is a security researcher · security engineer AI agent -",
				" 11 security tools, Burp MCP, YAML-configured targets and scopes,",
				" vulnerability taxonomy, bounty research priorities, and PoC writeups.",
			].join("\n")), 0, 0));
		}

		if (!findInstructions(ctx.cwd)) {
			const warning = "Warning: Sugarless-GiRL.md was not found.";
			if (ctx.hasUI) {
				ctx.ui.notify(warning, "warning");
			} else {
				console.warn(warning);
			}
		}
	});

	pi.on("before_agent_start", async (event, ctx) => {
		const instructionsPath = findInstructions(ctx.cwd);
		if (!instructionsPath) {
			const warning = "Warning: Sugarless-GiRL.md was not found.";
			if (ctx.hasUI) {
				ctx.ui.notify(warning, "warning");
			} else {
				console.warn(warning);
			}
			return;
		}

		const instructions = readFileSync(instructionsPath, "utf8");
		return {
			systemPrompt: `${event.systemPrompt}\n\n${instructions}`,
		};
	});
}
