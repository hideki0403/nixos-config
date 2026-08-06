import { Checkbox, Confirm, Input, Select } from '@cliffy/prompt'
import { join } from 'node:path'
import { createDirectoryAtomically, exists } from '../shared/fs.ts'
import { nixString } from '../shared/nix.ts'
import { checkValidRepository, findModules, findProfiles, findUsers, hasHomeProfile } from '../shared/repository.ts'
import { writeTemplate } from '../shared/template.ts'
import varidator from '../shared/validator.ts'

function parseGroups(value: string) {
	const groups = value.trim() === '' ? [] : value.trim().split(/\s+/)
	const invalid = groups.find((group) => !/^[a-z_][a-z0-9_.-]*$/.test(group))
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

function buildUserGroups(users: string[], groups: string[]) {
	const builtGroups = `[ ${groups.map(nixString).join(' ')} ]`
	return `\n${users.map((user) => `  users.users.${nixString(user)}.extraGroups = ${builtGroups};`).join('\n')}\n`
}

function buildHomeManagerUsers(users: string[], profile: string) {
	return users.length === 0 ? '' : `\n${users.map((user) => `  home-manager.users.${nixString(user)} = import ../../users/${user}/home/${profile};`).join('\n')}\n`
}

export async function createHost(repository: string) {
	await checkValidRepository(repository)

	const [profiles, users, modules] = await Promise.all([
		findProfiles(repository),
		findUsers(repository),
		findModules(repository),
	])

	if (profiles.length === 0) {
		throw new Error('Cannot find profile.')
	}

	if (users.length === 0) {
		throw new Error('User not found. Please create the user first.')
	}

	const hostname = await Input.prompt({
		message: 'hostname',
		validate: (value: string) => varidator.hostname(value) ?? true,
	})

	const stateVersion = await Input.prompt({
		message: 'NixOS StateVersion',
		default: '25.11',
		validate: (value: string) => varidator.stateVersion(value) ?? true,
	})

	const targetRoot = await Input.prompt({
		message: 'Select root directory',
		default: '/',
		validate: async (value: string) => value !== '' && await exists(value) && (await Deno.stat(value)).isDirectory ? true : 'Please enter a valid directory.',
	})

	const profile = await Select.prompt({
		message: 'System profile',
		options: profiles.map((value) => ({ name: value, value })),
	})

	const selectedUsers = await Checkbox.prompt({
		message: 'Users',
		options: users.map((value) => ({ name: value, value })),
		validate: (value: string[]) => value.length > 0 ? true : 'Please select at least one user.',
	})

	const missingHomes = []
	for (const user of selectedUsers) {
		if (!await hasHomeProfile(repository, user, profile)) {
			missingHomes.push(`users/${user}/home/${profile}/default.nix`)
		}
	}
	if (missingHomes.length > 0) {
		throw new Error(`Cannot find Home Manager profile(s):\n${missingHomes.join('\n')}`)
	}

	const selectedModules = await Checkbox.prompt({
		message: 'Optional modules',
		options: modules,
	})

	const groups = parseGroups(
		await Input.prompt({
			message: 'Additional groups (space-separated)',
			default: ['laptop', 'desktop'].includes(profile) ? 'networkmanager' : '',
			validate: (value: string) => {
			  try {
					parseGroups(value)
					return true
				} catch {
					return 'Invalid group name.'
				}
			}
		}),
	)

	if (
		!await Confirm.prompt({
			message: 'Generate hardware-configuration.nix and create host?',
			default: false,
		})
	) {
		console.log('cancelled')
		return
	}

	const templateImports = [
		'./hardware-configuration.nix',
		`../../profiles/${profile}`,
		...selectedModules.map((module) => `../../modules/${module}`),
		...users.map((user) => `../../users/${user}/account.nix`),
	].map((entry) => `    ${entry}`).join('\n')

	const output = await createDirectoryAtomically(join(repository, 'hosts'), hostname, 'host', async (directory) => {
		await generateHardwareConfiguration(targetRoot, join(directory, 'hardware-configuration.nix'))
		await writeTemplate(join(directory, 'configuration.nix'), 'host/configuration.nix', {
			HOSTNAME: hostname,
			STATE_VERSION: stateVersion,
			IMPORTS: templateImports,
			USER_GROUPS: buildUserGroups(selectedUsers, groups),
			HOME_MANAGER_USERS: buildHomeManagerUsers(selectedUsers, profile),
		})
	})

	console.log(`\nCreated: ${output}`)
	console.log(
		`Please run:\n  sudo env NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake ${repository}#${hostname}`,
	)
}
