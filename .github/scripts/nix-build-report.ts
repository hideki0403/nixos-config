import { name } from './shared/format.ts'
import type { Report } from './shared/report.ts'

// Activity and result types, from src/libutil/logging.hh in nix
const ACT_BUILD = 105
const ACT_SUBSTITUTE = 108
const RES_BUILD_LOG_LINE = 101
const RES_POST_BUILD_LOG_LINE = 107

const SLOW_BUILD_THRESHOLD = Number(Deno.env.get('SLOW_BUILD_THRESHOLD') ?? 30) * 1000
const LARGEST_PATHS = Number(Deno.env.get('LARGEST_PATHS') ?? 15)

type Event = {
	action: 'start' | 'stop' | 'result' | 'msg'
	id?: number
	type?: number
	level?: number
	text?: string
	msg?: string
	fields?: (string | number)[]
}

type Build = {
	name: string
	startedAt: number
	duration?: number
}

async function readEvents(onEvent: (event: Event) => void) {
	const decoder = new TextDecoder()
	let buffer = ''

	for await (const chunk of Deno.stdin.readable) {
		buffer += decoder.decode(chunk, { stream: true })

		const lines = buffer.split('\n')
		buffer = lines.pop() ?? ''

		for (const line of lines) onEvent(parse(line))
	}

	onEvent(parse(buffer))

	function parse(line: string): Event {
		if (!line.startsWith('@nix ')) {
			if (line.length > 0) console.log(line)
			return { action: 'msg' }
		}

		try {
			return JSON.parse(line.slice('@nix '.length))
		} catch {
			return { action: 'msg' }
		}
	}
}

async function closure(outLink: string) {
	const target = await Deno.realPath(outLink).catch(() => null)
	if (!target) return null

	const result = await new Deno.Command('nix', {
		args: ['path-info', '--json', '--recursive', '--closure-size', target],
		stdout: 'piped',
		stderr: 'inherit',
	}).output()

	if (!result.success) return null

	const paths: Record<string, { narSize: number; closureSize: number }> = JSON.parse(new TextDecoder().decode(result.stdout))
	const entries = Object.entries(paths).map(([path, info]) => ({ path, ...info }))

	return {
		total: entries.find((entry) => entry.path === target)?.closureSize ?? entries.reduce((sum, entry) => sum + entry.narSize, 0),
		count: entries.length,
		largest: entries.toSorted((a, b) => b.narSize - a.narSize).slice(0, LARGEST_PATHS).map(({ path, narSize }) => ({ path, narSize })),
	}
}

const [outLink = 'result', host = outLink, destination = 'nix-build-report.json'] = Deno.args

const builds = new Map<number, Build>()
const names = new Map<number, string>()
const startedAt = Date.now()
let substituted = 0

await readEvents((event) => {
	switch (event.action) {
		case 'start': {
			if (event.type === ACT_SUBSTITUTE) substituted++
			if (event.type !== ACT_BUILD || event.id === undefined) return

			const derivation = name(String(event.fields?.[0] ?? ''))
			builds.set(event.id, { name: derivation, startedAt: Date.now() })
			names.set(event.id, derivation)
			return
		}

		case 'stop': {
			const build = event.id === undefined ? undefined : builds.get(event.id)
			if (build) build.duration = Date.now() - build.startedAt
			return
		}

		case 'result': {
			if (event.type !== RES_BUILD_LOG_LINE && event.type !== RES_POST_BUILD_LOG_LINE) return

			const derivation = event.id === undefined ? undefined : names.get(event.id)
			if (derivation) console.log(`${derivation}> ${event.fields?.[0]}`)
			return
		}

		case 'msg': {
			if (event.level !== undefined && event.level <= 3 && event.msg) console.log(event.msg)
			return
		}
	}
})

const finished = [...builds.values()].filter((build): build is Required<Build> => build.duration !== undefined)
const size = await closure(outLink)

const report: Report = {
	host,
	closureSize: size?.total ?? null,
	storePaths: size?.count ?? null,
	built: finished.length,
	substituted,
	wallClock: Date.now() - startedAt,
	slow: finished
		.filter((build) => build.duration >= SLOW_BUILD_THRESHOLD)
		.toSorted((a, b) => b.duration - a.duration)
		.map(({ name, duration }) => ({ name, duration })),
	largest: size?.largest ?? [],
}

await Deno.writeTextFile(destination, JSON.stringify(report))
