import { Confirm, Input, Select } from '@cliffy/prompt'
import { type PasswordMethod, type UserOptions } from '../commands/user.ts'
import { findProfiles } from '../shared/repository.ts'
import { assertInteractive } from '../shared/tty.ts'
import varidator from '../shared/validator.ts'

export type UserDefaults = Partial<UserOptions>

export async function resolveUserOptions(repository: string, defaults: UserDefaults): Promise<UserOptions | undefined> {
	assertInteractive()

	const profiles = await findProfiles(repository)
	if (profiles.length === 0) {
		throw new Error('Cannot find profile.')
	}

	const username = defaults.username ?? await Input.prompt({
		message: 'username',
		validate: (value: string) => varidator.username(value) ?? true,
	})

	const stateVersion = defaults.stateVersion ?? await Input.prompt({
		message: 'HomeManager StateVersion',
		default: '25.11',
		validate: (value: string) => varidator.stateVersion(value) ?? true,
	})

	const passwordMethod = defaults.passwordMethod ?? await Select.prompt({
		message: 'Authentication method',
		options: [
			{ name: 'none: Disable password authentication', value: 'none' },
			{ name: 'manual: Use password set with `passwd`', value: 'manual' },
			{ name: 'sops: Use hashed password from sops-nix secret', value: 'sops' },
			{ name: 'file: Use hashedPasswordFile', value: 'file' },
		],
	}) as PasswordMethod

	let sopsSecret = defaults.sopsSecret
	let hashedPasswordFile = defaults.hashedPasswordFile

	if (passwordMethod === 'sops' && sopsSecret === undefined) {
		sopsSecret = await Input.prompt({
			message: 'sops secret name',
			default: `hashed_pw_${username}`,
			validate: (value: string) => varidator.sopsSecretName(value) ?? true,
		})
	}

	if (passwordMethod === 'file' && hashedPasswordFile === undefined) {
		hashedPasswordFile = await Input.prompt({
			message: 'hashedPasswordFile path',
			default: `/var/lib/secrets/${username}`,
			validate: (value: string) => varidator.absolutePath(value) ?? true,
		})
	}

	if (
		!await Confirm.prompt({
			message: 'Create this user?',
			default: false,
		})
	) {
		return undefined
	}

	return { username, stateVersion, passwordMethod, sopsSecret, hashedPasswordFile }
}
