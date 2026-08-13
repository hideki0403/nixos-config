// `/nix/store/<hash>-hello-2.12.3.drv` -> `hello-2.12.3`
export function name(path: string) {
	return path.replace(/^.*?\/nix\/store\/[a-z0-9]{32}-/, '').replace(/\.drv$/, '')
}

export function bytes(value: number | null) {
	if (value === null) return 'N/A'

	const units = ['B', 'KiB', 'MiB', 'GiB', 'TiB']
	let scaled = value
	let unit = 0

	while (scaled >= 1024 && unit < units.length - 1) {
		scaled /= 1024
		unit++
	}

	return `${scaled.toFixed(unit === 0 ? 0 : 2)} ${units[unit]}`
}

export function duration(milliseconds: number) {
	const seconds = Math.round(milliseconds / 1000)
	const minutes = Math.floor(seconds / 60)

	return minutes > 0 ? `${minutes}m ${String(seconds % 60).padStart(2, '0')}s` : `${seconds}s`
}

export function table(headers: string[], rows: string[][], left: number[] = [0]) {
	return [
		`| ${headers.join(' | ')} |`,
		`| ${headers.map((_, index) => (left.includes(index) ? '---' : '---:')).join(' | ')} |`,
		...rows.map((row) => `| ${row.join(' | ')} |`),
	].join('\n')
}

export async function write(summary: string) {
	const target = Deno.env.get('GITHUB_STEP_SUMMARY')

	if (target) await Deno.writeTextFile(target, `${summary}\n`, { append: true })
	else console.log(summary)
}
