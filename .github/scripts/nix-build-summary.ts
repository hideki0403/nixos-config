import { bytes, duration, name, table, write } from './shared/format.ts'
import type { Report } from './shared/report.ts'

const LARGEST_PATHS = Number(Deno.env.get('LARGEST_PATHS') ?? 15)

async function read(directory: string) {
	const entries = await Array.fromAsync(Deno.readDir(directory)).catch(() => [])
	const reports: Report[] = []

	for (const entry of entries) {
		if (!entry.isFile || !entry.name.endsWith('.json')) continue

		try {
			reports.push(JSON.parse(await Deno.readTextFile(`${directory}/${entry.name}`)))
		} catch {
			console.warn(`ignoring unreadable report: ${entry.name}`)
		}
	}

	return reports.toSorted((a, b) => a.host.localeCompare(b.host))
}

function details(title: string, body: string) {
	return [`<details><summary>${title}</summary>`, '', body, '', '</details>', ''].join('\n')
}

const directory = Deno.args[0] ?? '.'
const reports = await read(directory)

if (reports.length === 0) {
	await write('## Build\n\n_No build reports were produced._')
	Deno.exit(0)
}

const slow = reports
	.flatMap((report) => report.slow.map((build) => ({ ...build, host: report.host })))
	.toSorted((a, b) => b.duration - a.duration)

const paths = new Map<string, { narSize: number; hosts: string[] }>()

for (const report of reports) {
	for (const entry of report.largest) {
		const existing = paths.get(entry.path)

		if (existing) existing.hosts.push(report.host)
		else paths.set(entry.path, { narSize: entry.narSize, hosts: [report.host] })
	}
}

const largest = [...paths.entries()].toSorted(([, a], [, b]) => b.narSize - a.narSize).slice(0, LARGEST_PATHS)

await write([
	'## Build',
	'',
	table(
		['Host', 'Closure size', 'Store paths', 'Built', 'Substituted', 'Duration'],
		reports.map((report) => [
			report.host,
			bytes(report.closureSize),
			report.storePaths === null ? 'n/a' : String(report.storePaths),
			String(report.built),
			String(report.substituted),
			duration(report.wallClock),
		]),
	),
	'',
	details(
		`Slowest builds (${slow.length})`,
		slow.length > 0 ? table(['Derivation', 'Host', 'Duration'], slow.map((build) => [`\`${build.name}\``, build.host, duration(build.duration)]), [0, 1]) : '_None._',
	),
	details(
		'Largest store paths',
		largest.length > 0 ? table(['Path', 'Size', 'Hosts'], largest.map(([path, entry]) => [`\`${name(path)}\``, bytes(entry.narSize), entry.hosts.join(', ')]), [0, 2]) : '_Unavailable._',
	),
].join('\n'))
