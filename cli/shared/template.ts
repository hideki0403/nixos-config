import { dirname } from 'node:path'
import { default as templates, type Templates } from '../templates/files.ts'

export async function renderTemplate(template: keyof Templates, values: Record<string, string> = {}) {
	const source = await Deno.readTextFile(templates[template])
	const rendered = source.replace(/#?{{([A-Z_]+)}}/g, (_, key: string) => {
		const value = values[key]
		if (value === undefined) throw new Error(`missing value: ${key} (in ${template})`)
		return value
	})

	return rendered.replace(/[ \t]+$/gm, '').replace(/\n{3,}/g, '\n\n')
}

export async function writeTemplate(path: string, template: keyof Templates, values: Record<string, string> = {}) {
	await Deno.mkdir(dirname(path), { recursive: true })
	await Deno.writeTextFile(path, await renderTemplate(template, values))
}
