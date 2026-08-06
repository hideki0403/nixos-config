import { dirname, join, relative } from 'node:path'
import { exists } from './fs.ts'

export async function checkValidRepository(repository: string) {
	const required = ['flake.nix', 'hosts', 'profiles', 'modules', 'users']
	const missing = []

	for (const path of required) {
		if (!await exists(join(repository, path))) {
			missing.push(path)
		}
	}

	if (missing.length > 0) {
		throw new Error(`"${repository}" is not a valid repository.\nmissing: ${missing.join(', ')}`)
	}
}

export async function findProfiles(repository: string) {
	const root = join(repository, 'profiles')
	const profiles: string[] = []

	for await (const entry of Deno.readDir(root)) {
		if (entry.isDirectory && !entry.isSymlink && entry.name !== 'base' && await exists(join(root, entry.name, 'default.nix'))) {
			profiles.push(entry.name)
		}
	}

	return profiles.sort((left, right) => left.localeCompare(right))
}

export async function findUsers(repository: string) {
	const root = join(repository, 'users')
	const users: string[] = []

	for await (const entry of Deno.readDir(root)) {
		if (entry.isDirectory && !entry.isSymlink && await exists(join(root, entry.name, 'account.nix'))) {
			users.push(entry.name)
		}
	}

	return users.sort((left, right) => left.localeCompare(right))
}

async function listModules(root: string) {
	const modules: string[] = []

	async function search(dir: string) {
		for await (const entry of Deno.readDir(dir)) {
			if (entry.isSymlink) continue

			const path = join(dir, entry.name)
			if (entry.isDirectory) {
				await search(path)
			} else if (entry.isFile && entry.name === 'default.nix') {
				modules.push(dirname(path))
			}
		}
	}

	await search(root)
	return modules.sort((left, right) => left.localeCompare(right))
}

function parseMetadata<T>(metadata: Record<string, unknown>, key: string, fallback: T, file: string): T {
	const value = metadata[key]
	if (value === undefined) return fallback

	if (typeof value !== typeof fallback) {
		throw new Error(`${key} is must be a ${typeof fallback} (in ${file})`)
	}

	return value as T
}

async function loadModule(repository: string, dir: string) {
	const root = join(repository, 'modules')
	const path = relative(root, dir).split('\\').join('/')
	const metadataPath = join(dir, 'module.json')
	const metadata: Record<string, unknown> = await exists(metadataPath) ? JSON.parse(await Deno.readTextFile(metadataPath)) : {}

	if (metadata === null || Array.isArray(metadata)) {
		throw new Error(`${metadataPath} is not a valid JSON file.`)
	}

	if (parseMetadata(metadata, 'hide', false, metadataPath)) {
		return undefined
	}

	return path
}

export async function findModules(repository: string) {
	const root = join(repository, 'modules')
	const modules = await Promise.all((await listModules(root)).map((directory) => loadModule(repository, directory)))
	return modules.filter(module => module !== undefined)
}

export async function hasHomeProfile(repository: string, username: string, profile: string) {
	return await exists(join(repository, 'users', username, 'home', profile, 'default.nix'))
}
