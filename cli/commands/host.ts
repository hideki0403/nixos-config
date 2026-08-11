import { join } from 'node:path'
import { createDirectoryAtomically, exists } from '../shared/fs.ts'
import { nixString } from '../shared/nix.ts'
import { findModules, findProfiles, findUsers, hasHomeProfile } from '../shared/repository.ts'
import { writeTemplate } from '../shared/template.ts'
import varidator from '../shared/validator.ts'

export type HardwareConfiguration = {
	type: 'generate'
	targetRoot: string
} | {
	type: 'file'
	path: string
}

export type HostOptions = {
	hostname: string
	stateVersion: string
	profile: string
	users: string[]
	modules: string[]
	groups: string[]
	hardware: HardwareConfiguration
}

const groupPattern = /^[a-z_][a-z0-9_.-]*$/

export function validateGroups(groups: string[]) {
	const invalid = groups.find((group) => !groupPattern.test(group))
	if (invalid) {
		throw new Error(`invalid group name: ${invalid}`)
	}
	return [...new Set(groups)]
}

async function generateHardwareConfiguration(targetRoot: string, output: string) {
	const args = targetRoot === '/' ? ['--show-hardware-config'] : ['--root', targetRoot, '--show-hardware-config']
	const result = await new Deno.Command('nixos-generate-config', {
		args,
		stdout: 'piped',
		stderr: 'piped',
	}).output()

	if (!result.success) {
		throw new Error(`Failed to generate hardware-configuration.nix\n${new TextDecoder().decode(result.stderr).trim()}`)
	}
	await Deno.writeFile(output, result.stdout)
}

async function writeHardwareConfiguration(hardware: HardwareConfiguration, output: string) {
	if (hardware.type === 'file') {
		await Deno.copyFile(hardware.path, output)
		return
	}

	await generateHardwareConfiguration(hardware.targetRoot, output)
}

function buildUserGroups(users: string[], groups: string[]) {
	if (groups.length === 0) return ''
	const builtGroups = `[ ${groups.map(nixString).join(' ')} ]`
	return `\n${users.map((user) => `  users.users.${nixString(user)}.extraGroups = ${builtGroups};`).join('\n')}`
}

function buildHomeManagerUsers(users: string[], profile: string) {
	return users.length === 0 ? '' : `\n${users.map((user) => `  home-manager.users.${nixString(user)} = import ../../users/${user}/home/${profile};`).join('\n')}`
}

export async function validateHostOptions(repository: string, options: HostOptions) {
	const [profiles, users, modules] = await Promise.all([
		findProfiles(repository),
		findUsers(repository),
		findModules(repository),
	])

	const hostnameError = varidator.hostname(options.hostname)
	if (hostnameError) throw new Error(hostnameError)

	if (await exists(join(repository, 'hosts', options.hostname))) {
		throw new Error(`host "${options.hostname}" is already exists, so it cannot be created`)
	}

	const stateVersionError = varidator.stateVersion(options.stateVersion)
	if (stateVersionError) throw new Error(stateVersionError)

	if (!profiles.includes(options.profile)) {
		throw new Error(`Cannot find profile: ${options.profile} (available: ${profiles.join(', ')})`)
	}

	if (options.users.length === 0) {
		throw new Error('Please select at least one user.')
	}

	const unknownUsers = options.users.filter((user) => !users.includes(user))
	if (unknownUsers.length > 0) {
		throw new Error(`Cannot find user(s): ${unknownUsers.join(', ')} (available: ${users.join(', ')})`)
	}

	const missingHomes = []
	for (const user of options.users) {
		if (!await hasHomeProfile(repository, user, options.profile)) {
			missingHomes.push(`users/${user}/home/${options.profile}/default.nix`)
		}
	}
	if (missingHomes.length > 0) {
		throw new Error(`Cannot find Home Manager profile(s):\n${missingHomes.join('\n')}`)
	}

	const unknownModules = options.modules.filter((module) => !modules.includes(module))
	if (unknownModules.length > 0) {
		throw new Error(`Cannot find module(s): ${unknownModules.join(', ')} (available: ${modules.join(', ')})`)
	}

	validateGroups(options.groups)

	if (options.hardware.type === 'file') {
		if (!await exists(options.hardware.path)) {
			throw new Error(`Cannot find hardware configuration: ${options.hardware.path}`)
		}
	} else if (!await exists(options.hardware.targetRoot)) {
		throw new Error(`Cannot find root directory: ${options.hardware.targetRoot}`)
	}
}

export async function createHost(repository: string, options: HostOptions) {
	await validateHostOptions(repository, options)

	const templateImports = [
		'./hardware-configuration.nix',
		`../../profiles/${options.profile}`,
		...options.modules.map((module) => `../../modules/${module}`),
		...options.users.map((user) => `../../users/${user}/account.nix`),
	].map((entry, index) => index === 0 ? entry : `    ${entry}`).join('\n')

	return await createDirectoryAtomically(join(repository, 'hosts'), options.hostname, 'host', async (directory) => {
		await writeHardwareConfiguration(options.hardware, join(directory, 'hardware-configuration.nix'))
		await writeTemplate(join(directory, 'configuration.nix'), 'host/configuration.nix', {
			HOSTNAME: options.hostname,
			STATE_VERSION: options.stateVersion,
			IMPORTS: templateImports,
			USER_GROUPS: buildUserGroups(options.users, options.groups),
			HOME_MANAGER_USERS: buildHomeManagerUsers(options.users, options.profile),
		})
	})
}
