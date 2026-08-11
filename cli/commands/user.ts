import { join } from 'node:path'
import { createDirectoryAtomically, exists } from '../shared/fs.ts'
import { nixString } from '../shared/nix.ts'
import { findProfiles } from '../shared/repository.ts'
import { writeTemplate } from '../shared/template.ts'
import varidator from '../shared/validator.ts'

export const passwordMethods = ['none', 'manual', 'sops', 'file'] as const
export type PasswordMethod = typeof passwordMethods[number]

export type UserOptions = {
	username: string
	stateVersion: string
	passwordMethod: PasswordMethod
	sopsSecret?: string
	hashedPasswordFile?: string
}

function buildPasswordPolicy(options: UserOptions) {
	const target = 'accounts.passwordPolicy.${userConfig.username}'

	switch (options.passwordMethod) {
		case 'none':
			return `${target}.type = "none";`
		case 'manual':
			return `${target}.type = "manual";`
		case 'sops':
			return `${target} = {\n    type = "sops";\n    sopsSecret = ${nixString(options.sopsSecret ?? '')};\n  };`
		case 'file':
			return `${target} = {\n    type = "file";\n    hashedPasswordFile = ${nixString(options.hashedPasswordFile ?? '')};\n  };`
	}
}

export async function validateUserOptions(repository: string, options: UserOptions) {
	const usernameError = varidator.username(options.username)
	if (usernameError) throw new Error(usernameError)

	if (await exists(join(repository, 'users', options.username))) {
		throw new Error(`user "${options.username}" is already exists, so it cannot be created`)
	}

	const stateVersionError = varidator.stateVersion(options.stateVersion)
	if (stateVersionError) throw new Error(stateVersionError)

	if (!passwordMethods.includes(options.passwordMethod)) {
		throw new Error(`Invalid password policy: ${options.passwordMethod} (available: ${passwordMethods.join(', ')})`)
	}

	if (options.passwordMethod === 'sops') {
		if (!options.sopsSecret) throw new Error('sops secret name is required when the password policy is "sops".')
		const sopsSecretError = varidator.sopsSecretName(options.sopsSecret)
		if (sopsSecretError) throw new Error(sopsSecretError)
	}

	if (options.passwordMethod === 'file') {
		if (!options.hashedPasswordFile) throw new Error('hashedPasswordFile path is required when the password policy is "file".')
		const pathError = varidator.absolutePath(options.hashedPasswordFile)
		if (pathError) throw new Error(pathError)
	}
}

export async function createUser(repository: string, options: UserOptions) {
	await validateUserOptions(repository, options)

	const profiles = await findProfiles(repository)
	if (profiles.length === 0) {
		throw new Error('Cannot find profile.')
	}

	return await createDirectoryAtomically(join(repository, 'users'), options.username, 'user', async (stgDir) => {
		await writeTemplate(join(stgDir, 'identity.nix'), 'user/identity.nix', {
			USERNAME: options.username,
		})
		await writeTemplate(join(stgDir, 'account.nix'), 'user/account.nix', {
			PASSWORD_POLICY: buildPasswordPolicy(options),
		})
		await writeTemplate(join(stgDir, 'home', 'base', 'default.nix'), 'user/home/base/default.nix', {
			STATE_VERSION: options.stateVersion,
		})

		for (const profile of profiles) {
			await writeTemplate(join(stgDir, 'home', profile, 'default.nix'), 'user/home/profile/default.nix')
		}
	})
}
