import { Confirm, Input, Select } from '@cliffy/prompt'
import { join } from 'node:path'
import { createDirectoryAtomically } from '../shared/fs.ts'
import { nixString } from '../shared/nix.ts'
import { checkValidRepository, findProfiles } from '../shared/repository.ts'
import { writeTemplate } from '../shared/template.ts'
import varidator from '../shared/validator.ts'

type PasswordMethod = 'none' | 'sops' | 'file'

function buildPasswordPolicy(method: PasswordMethod, sopsSecret: string, hashedPasswordFile: string) {
	const target = 'accounts.passwordPolicy.${userConfig.username}'

	switch (method) {
		case 'none':
			return `${target}.type = "none";`
		case 'sops':
			return `${target} = {\n    type = "sops";\n    sopsSecret = ${nixString(sopsSecret)};\n  };`
		case 'file':
			return `${target} = {\n    type = "file";\n    hashedPasswordFile = ${nixString(hashedPasswordFile)};\n  };`
	}
}

export async function createUser(repository: string) {
	await checkValidRepository(repository)

	const profiles = await findProfiles(repository)
	if (profiles.length === 0) {
		throw new Error('Cannot find profile.')
	}

	const username = await Input.prompt({
		message: 'username',
		validate: (value: string) => varidator.username(value) ?? true,
	})
	const stateVersion = await Input.prompt({
		message: 'HomeManager StateVersion',
		default: '25.11',
		validate: (value: string) => varidator.stateVersion(value) ?? true,
	})

	const passwordMethod = await Select.prompt({
		message: 'Authentication method',
		options: [
			{ name: 'Password (with hashed password file)', value: 'file' },
			{ name: 'Password (with sops)', value: 'sops' },
			{ name: 'None (`su` login only)', value: 'none' },
		],
	}) as PasswordMethod

	let sopsSecret = ''
	let hashedPasswordFile = ''

	if (passwordMethod === 'sops') {
		sopsSecret = await Input.prompt({
			message: 'sops secret name',
			default: `hashed_pw_${username}`,
			validate: (value: string) => varidator.sopsSecretName(value) ?? true,
		})
	}

	if (passwordMethod === 'file') {
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
		console.log('Cancelled')
		return
	}

	const output = await createDirectoryAtomically(join(repository, 'users'), username, 'user', async (stgDir) => {
		await writeTemplate(join(stgDir, 'identity.nix'), 'user/identity.nix', {
			USERNAME: username,
		})
		await writeTemplate(join(stgDir, 'account.nix'), 'user/account.nix', {
			PASSWORD_POLICY: buildPasswordPolicy(passwordMethod, sopsSecret, hashedPasswordFile),
		})
		await writeTemplate(join(stgDir, 'home', 'base', 'default.nix'), 'user/home/base/default.nix', {
			STATE_VERSION: stateVersion,
		})

		for (const profile of profiles.filter((profile) => profile !== 'base')) {
			await writeTemplate(join(stgDir, 'home', profile, 'default.nix'), 'user/home/profile/default.nix')
		}
	})

	console.log(`\nCreated: ${output}`)

	if (passwordMethod === 'sops') {
		console.log(`\nAdd the "${sopsSecret}" secret with sops before applying this configuration.`)
	}
	if (passwordMethod === 'file') {
		console.log(`\nPlace a hashed password (e.g. via mkpasswd) at "${hashedPasswordFile}" before applying this configuration.`)
	}
}
