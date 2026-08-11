import { Confirm, Input, Secret, Select } from '@cliffy/prompt'
import { dirname, join } from 'node:path'
import { exists } from '../shared/fs.ts'
import { findUsers } from '../shared/repository.ts'
import { assertInteractive } from '../shared/tty.ts'
import varidator from '../shared/validator.ts'

const HASH_METHOD = 'yescrypt'
const MAX_PASSWORD_ATTEMPTS = 3

async function findDeclaredHashedPasswordFile(repository: string, username: string) {
	const accountPath = join(repository, 'users', username, 'account.nix')
	if (!await exists(accountPath)) return undefined

	const source = await Deno.readTextFile(accountPath)
	const policyMatch = source.match(/accounts\.passwordPolicy\.\$\{userConfig\.username\}[^;]*?type\s*=\s*"([a-z]+)"/s)
	if (policyMatch && policyMatch[1] !== 'file') {
		console.log(`user "${username}" is not declared as type "file" (current: "${policyMatch[1]}"). The generated file will be unused until the declaration is changed.`)
	}

	const pathMatch = source.match(/hashedPasswordFile\s*=\s*"([^"]+)"/)
	const declaredPath = pathMatch?.[1]

	return declaredPath && !declaredPath.includes('${') ? declaredPath : undefined
}

async function readPassword() {
	for (let attempt = 1; attempt <= MAX_PASSWORD_ATTEMPTS; attempt++) {
		const password = await Secret.prompt({ message: 'Password', minLength: 1 })
		const confirmation = await Secret.prompt({ message: 'Confirm password', minLength: 1 })

		if (password === confirmation) return password
		console.log(`Passwords do not match. (${attempt}/${MAX_PASSWORD_ATTEMPTS})`)
	}

	throw new Error('Too many mismatched attempts.')
}

async function hashPassword(password: string) {
	const child = new Deno.Command('mkpasswd', {
		args: ['-m', HASH_METHOD, '-s'],
		stdin: 'piped',
		stdout: 'piped',
		stderr: 'piped',
	}).spawn()

	const writer = child.stdin.getWriter()
	await writer.write(new TextEncoder().encode(`${password}\n`))
	await writer.close()

	const result = await child.output()
	if (!result.success) {
		throw new Error(`Failed to hash password\n${new TextDecoder().decode(result.stderr).trim()}`)
	}

	return new TextDecoder().decode(result.stdout).trim()
}

async function writeHashedPasswordFile(path: string, hash: string) {
	const dir = dirname(path)
	await Deno.mkdir(dir, { recursive: true })
	await Deno.chmod(dir, 0o711)
	await Deno.chown(dir, 0, 0)

	const tmpPath = await Deno.makeTempFile({ dir })
	try {
		await Deno.writeTextFile(tmpPath, `${hash}\n`)
		await Deno.chmod(tmpPath, 0o600)
		await Deno.chown(tmpPath, 0, 0)
		await Deno.rename(tmpPath, path)
	} catch (error) {
		await Deno.remove(tmpPath).catch(() => null)
		throw error
	}
}

export async function setPassword(repository: string) {
	assertInteractive()

	if (Deno.uid() !== 0) {
		throw new Error('This command must be run as root. Please retry with sudo.')
	}

	const users = await findUsers(repository)
	if (users.length === 0) {
		throw new Error('User not found. Please create the user first.')
	}

	const username = await Select.prompt({
		message: 'User',
		options: users.map((value) => ({ name: value, value })),
	})

	const declaredPath = await findDeclaredHashedPasswordFile(repository, username)

	const path = await Input.prompt({
		message: 'hashedPasswordFile path',
		default: declaredPath ?? `/var/lib/secrets/${username}`,
		validate: (value: string) => varidator.absolutePath(value) ?? true,
	})

	if (await exists(path)) {
		if (
			!await Confirm.prompt({
				message: `"${path}" already exists. Overwrite?`,
				default: false,
			})
		) {
			console.log('Cancelled')
			return
		}
	}

	const password = await readPassword()
	const hash = await hashPassword(password)
	await writeHashedPasswordFile(path, hash)

	console.log(`\nWrote hashed password to: ${path}`)
}
