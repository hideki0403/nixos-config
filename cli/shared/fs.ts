import { join } from 'node:path'

export async function exists(path: string) {
	try {
		await Deno.stat(path)
		return true
	} catch (error) {
		if (error instanceof Deno.errors.NotFound) return false
		throw error
	}
}

export async function createDirectoryAtomically<T>(targetDirectory: string, name: string, type: string, action: (stagingDirectory: string) => Promise<T>) {
	const targetPath = join(targetDirectory, name)
	if (await exists(targetPath)) throw new Error(`${type} "${name}" is already exists, so it cannot be created`)

	await Deno.mkdir(targetDirectory, { recursive: true })
	const stagingDirectory = await Deno.makeTempDir({
	  dir: targetDirectory,
	  prefix: `nixos-config-cli.${type}.${name}_tmp-`,
	})

	try {
		const result = await action(stagingDirectory)
		await Deno.rename(stagingDirectory, targetPath)
		return result
	} catch (error) {
		await Deno.remove(stagingDirectory, { recursive: true }).catch(() => null)
		throw error
	}
}
