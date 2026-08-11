import { Checkbox, Confirm, Input, Select } from '@cliffy/prompt'
import { type HardwareConfiguration, type HostOptions, validateGroups } from '../commands/host.ts'
import { exists } from '../shared/fs.ts'
import { findModules, findProfiles, findUsers } from '../shared/repository.ts'
import { assertInteractive } from '../shared/tty.ts'
import varidator from '../shared/validator.ts'

export type HostDefaults = Partial<Omit<HostOptions, 'hardware'>> & {
	hardwareConfig?: string
	targetRoot?: string
}

export async function resolveHostOptions(repository: string, defaults: HostDefaults): Promise<HostOptions | undefined> {
	assertInteractive()

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

	const hostname = defaults.hostname ?? await Input.prompt({
		message: 'hostname',
		validate: (value: string) => varidator.hostname(value) ?? true,
	})

	const stateVersion = defaults.stateVersion ?? await Input.prompt({
		message: 'NixOS StateVersion',
		default: '25.11',
		validate: (value: string) => varidator.stateVersion(value) ?? true,
	})

	let hardware: HardwareConfiguration
	if (defaults.hardwareConfig !== undefined) {
		hardware = { type: 'file', path: defaults.hardwareConfig }
	} else {
		const targetRoot = defaults.targetRoot ?? await Input.prompt({
			message: 'Select root directory',
			default: '/',
			validate: async (value: string) => value !== '' && await exists(value) && (await Deno.stat(value)).isDirectory ? true : 'Please enter a valid directory.',
		})
		hardware = { type: 'generate', targetRoot }
	}

	const profile = defaults.profile ?? await Select.prompt({
		message: 'System profile',
		options: profiles.map((value) => ({ name: value, value })),
	})

	const selectedUsers = defaults.users ?? await Checkbox.prompt({
		message: 'Users',
		options: users.map((value) => ({ name: value, value })),
		validate: (value: string[]) => value.length > 0 ? true : 'Please select at least one user.',
	})

	const selectedModules = defaults.modules ?? await Checkbox.prompt({
		message: 'Optional modules',
		options: modules,
	})

	const groups = defaults.groups ?? validateGroups(
		(await Input.prompt({
			message: 'Additional groups (space-separated)',
			default: ['laptop', 'desktop'].includes(profile) ? 'networkmanager' : '',
			validate: (value: string) => {
				try {
					validateGroups(value.trim() === '' ? [] : value.trim().split(/\s+/))
					return true
				} catch {
					return 'Invalid group name.'
				}
			},
		})).trim().split(/\s+/).filter((entry) => entry !== ''),
	)

	if (
		!await Confirm.prompt({
			message: hardware.type === 'generate' ? 'Generate hardware-configuration.nix and create host?' : 'Create host?',
			default: false,
		})
	) {
		return undefined
	}

	return { hostname, stateVersion, profile, users: selectedUsers, modules: selectedModules, groups, hardware }
}
