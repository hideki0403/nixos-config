import { validate } from '@actions/languageservice'
import type { ActionMetadata, ActionReference } from '@actions/languageservice/action'
import { parse } from '@std/yaml'
import { TextDocument } from 'vscode-languageserver-textdocument'
import { DiagnosticSeverity } from 'vscode-languageserver-types'
import { basename, dirname, join, relative, resolve } from 'node:path'
import { pathToFileURL } from 'node:url'

function findRepository() {
	let current = resolve(Deno.cwd())

	while (true) {
		try {
			if (Deno.statSync(join(current, '.github', 'workflows')).isDirectory) return current
		} catch {
		  // Do nothing
		}

		const parent = dirname(current)
		if (parent === current) throw new Error('Cannot find the repository root (no .github/workflows directory found).')
		current = parent
	}
}

const repository = findRepository()
const workflowDirectory = join(repository, '.github', 'workflows')
const token = Deno.env.get('GITHUB_TOKEN')
const annotate = Deno.env.get('GITHUB_ACTIONS') === 'true'
const metadataCache = new Map<string, ActionMetadata | undefined>()

function actionIdentifier(action: ActionReference) {
	const path = action.path === undefined || action.path === '' ? '' : `/${action.path}`
	return `${action.owner}/${action.name}${path}@${action.ref}`
}

async function fetchActionMetadata(action: ActionReference) {
	const identifier = actionIdentifier(action)
	const cached = metadataCache.get(identifier)
	if (cached !== undefined || metadataCache.has(identifier)) return cached

	const path = action.path === undefined || action.path === '' ? '' : `${action.path}/`
	const headers = token === undefined ? undefined : { authorization: `Bearer ${token}` }

	for (const manifest of ['action.yml', 'action.yaml']) {
		const response = await fetch(`https://raw.githubusercontent.com/${action.owner}/${action.name}/${action.ref}/${path}${manifest}`, { headers })

		if (!response.ok) {
			await response.body?.cancel()
			continue
		}

		const metadata = parse(await response.text()) as ActionMetadata
		metadataCache.set(identifier, metadata)
		return metadata
	}

	metadataCache.set(identifier, undefined)
	return undefined
}

const fileProvider = {
	async getFileContent(reference: { path: string }) {
		const path = join(repository, reference.path)
		return { name: basename(path), content: await Deno.readTextFile(path) }
	},
}

async function findWorkflows() {
	const workflows: string[] = []

	for await (const entry of Deno.readDir(workflowDirectory)) {
		if (entry.isFile && /\.ya?ml$/.test(entry.name)) {
			workflows.push(join(workflowDirectory, entry.name))
		}
	}

	return workflows.sort((left, right) => left.localeCompare(right))
}

function report(path: string, line: number, column: number, severity: DiagnosticSeverity, message: string) {
	const level = severity === DiagnosticSeverity.Error ? 'error' : 'warning'

	if (annotate) {
		console.log(`::${level} file=${path},line=${line},col=${column}::${message.replaceAll('\n', '%0A')}`)
		return
	}

	console.log(`${path}:${line}:${column}: ${level}: ${message}`)
}

async function main() {
	const args = Deno.args.filter((arg) => arg !== '--strict')
	const strict = Deno.args.includes('--strict')
	const workflows = args.length > 0 ? args.map((arg) => resolve(arg)) : await findWorkflows()

	let errors = 0
	let warnings = 0

	for (const workflow of workflows) {
		const path = relative(repository, workflow)
		const document = TextDocument.create(pathToFileURL(workflow).toString(), 'yaml', 0, await Deno.readTextFile(workflow))
		const diagnostics = await validate(document, {
			actionsMetadataProvider: { fetchActionMetadata },
			fileProvider,
		})

		for (const diagnostic of diagnostics) {
			const severity = diagnostic.severity ?? DiagnosticSeverity.Error
			if (severity === DiagnosticSeverity.Error) {
				errors++
			} else if (severity === DiagnosticSeverity.Warning) {
				warnings++
			} else {
				continue
			}

			const message = typeof diagnostic.message === 'string' ? diagnostic.message : diagnostic.message.value
			report(path, diagnostic.range.start.line + 1, diagnostic.range.start.character + 1, severity, message)
		}
	}

	const summary = `checked ${workflows.length} workflow(s): ${errors} error(s), ${warnings} warning(s)`
	if (errors > 0 || (strict && warnings > 0)) {
		console.error(`\n${summary}`)
		Deno.exit(1)
	}

	console.log(`\n${summary}`)
}

await main()
