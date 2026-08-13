import { join } from 'node:path'
import { fileURLToPath } from 'node:url'

const entrypoint = fileURLToPath(new URL('./validate-workflows.ts', import.meta.url))
const config = fileURLToPath(new URL('./deno.json', import.meta.url))
const directory = await Deno.makeTempDir({ prefix: 'nixos-config-validate-workflows-' })
const bundle = join(directory, 'validate-workflows.js')

async function run(args: string[]) {
	const result = await new Deno.Command(Deno.execPath(), {
		args,
		stdout: 'inherit',
		stderr: 'inherit',
	}).output()

	return result.code
}

let code = await run(['bundle', '--quiet', '--config', config, '--platform=deno', '--output', bundle, entrypoint])

if (code === 0) {
	code = await run([
		'run',
		'--quiet',
		'--allow-read',
		'--allow-env',
		'--allow-net=raw.githubusercontent.com',
		bundle,
		...Deno.args,
	])
}

await Deno.remove(directory, { recursive: true }).catch(() => null)
Deno.exit(code)
