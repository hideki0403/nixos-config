export function assertInteractive() {
	if (!Deno.stdin.isTerminal() || !Deno.stdout.isTerminal()) {
		throw new Error('Please run in a terminal, or pass every required option with --non-interactive.')
	}
}

export function requireOption<T>(value: T | undefined, flag: string): T {
	if (value === undefined) {
		throw new Error(`"${flag}" is required in non-interactive mode.`)
	}
	return value
}

export function parseList(value: string | undefined) {
	if (value === undefined) return undefined
	return value.split(/[\s,]+/).filter((entry) => entry !== '')
}
