import { dirname, resolve } from 'node:path'
import { Command, EnumType } from '@cliffy/command'
import { createHost, type HardwareConfiguration } from './commands/host.ts'
import { listEntries, type ListTarget, listTargets } from './commands/list.ts'
import { setPassword } from './commands/password.ts'
import { createUser, type PasswordMethod, passwordMethods } from './commands/user.ts'
import { resolveHostOptions } from './prompts/host.ts'
import { resolveUserOptions } from './prompts/user.ts'
import { checkValidRepository } from './shared/repository.ts'
import { parseList, requireOption } from './shared/tty.ts'

const command = new Command()
	.name('nixos-config-cli')
	.description('NixOS configuration CLI')
	.globalType('password-policy', new EnumType(passwordMethods))
	.globalType('list-target', new EnumType(listTargets))
	.globalOption('-r, --repo <path:string>', 'Flake repository', {
		default: import.meta.dirname == null ? Deno.cwd() : dirname(import.meta.dirname),
	})
	.globalAction(async (options) => {
		await checkValidRepository(resolve(options.repo))
	})
	// host
	.command('host', 'Create a host configuration')
	.option('--hostname <hostname:string>', 'Hostname')
	.option('--state-version <version:string>', 'NixOS state version')
	.option('--profile <profile:string>', 'System profile')
	.option('--users <users:string>', 'Users to add to this host (comma-separated)')
	.option('--modules <modules:string>', 'Optional modules to import (comma-separated)')
	.option('--groups <groups:string>', 'Additional groups (comma-separated)')
	.option('--hardware-config <path:string>', 'Use an existing hardware-configuration.nix instead of generating one')
	.option('--root <path:string>', 'Root directory passed to nixos-generate-config')
	.option('-n, --non-interactive', 'Create the host without prompt')
	.action(async (options) => {
		const repository = resolve(options.repo)
		const hardware: HardwareConfiguration | undefined = options.hardwareConfig === undefined ? undefined : {
			type: 'file',
			path: resolve(options.hardwareConfig),
		}

		const resolved = options.nonInteractive ? {
			hostname: requireOption(options.hostname, '--hostname'),
			stateVersion: requireOption(options.stateVersion, '--state-version'),
			profile: requireOption(options.profile, '--profile'),
			users: requireOption(parseList(options.users), '--users'),
			modules: parseList(options.modules) ?? [],
			groups: parseList(options.groups) ?? [],
			hardware: hardware ?? {
				type: 'generate' as const,
				targetRoot: options.root ?? '/',
			},
		} : await resolveHostOptions(repository, {
			hostname: options.hostname,
			stateVersion: options.stateVersion,
			profile: options.profile,
			users: parseList(options.users),
			modules: parseList(options.modules),
			groups: parseList(options.groups),
			hardwareConfig: hardware?.path,
			targetRoot: options.root,
		})

		if (resolved === undefined) {
			console.log('Cancelled')
			return
		}

		const output = await createHost(repository, resolved)

		console.log(`\nCreated: ${output}`)
		console.log(
			`Please run:\n  sudo env NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake ${repository}#${resolved.hostname}`,
		)
	})
	// user
	.command('user', 'Create a user profile')
	.option('--username <username:string>', 'Username')
	.option('--state-version <version:string>', 'Home Manager state version')
	.option('--password-policy <policy:password-policy>', 'Authentication method')
	.option('--sops-secret <name:string>', 'sops secret name (password policy "sops")')
	.option('--hashed-password-file <path:string>', 'hashedPasswordFile path (password policy "file")')
	.option('-n, --non-interactive', 'Create the user without prompting')
	.action(async (options) => {
		const repository = resolve(options.repo)

		const resolved = options.nonInteractive
			? {
				username: requireOption(options.username, '--username'),
				stateVersion: requireOption(options.stateVersion, '--state-version'),
				passwordMethod: requireOption(options.passwordPolicy, '--password-policy') as PasswordMethod,
				sopsSecret: options.sopsSecret,
				hashedPasswordFile: options.hashedPasswordFile,
			}
			: await resolveUserOptions(repository, {
				username: options.username,
				stateVersion: options.stateVersion,
				passwordMethod: options.passwordPolicy as PasswordMethod | undefined,
				sopsSecret: options.sopsSecret,
				hashedPasswordFile: options.hashedPasswordFile,
			})

		if (resolved === undefined) {
			console.log('Cancelled')
			return
		}

		const output = await createUser(repository, resolved)

		console.log(`\nCreated: ${output}`)

		if (resolved.passwordMethod === 'sops') {
			console.log(`\nAdd the "${resolved.sopsSecret}" secret with sops before applying this configuration.`)
		}
		if (resolved.passwordMethod === 'file') {
			console.log(`\nPlace a hashed password (e.g. via mkpasswd) at "${resolved.hashedPasswordFile}" before applying this configuration.`)
		}
		if (resolved.passwordMethod === 'manual') {
			console.log(`\nRun \`passwd ${resolved.username}\` as root before applying this configuration, otherwise the pre-switch check will refuse to switch.`)
		}
	})
	// password
	.command('password', 'Set the user password')
	.action(async (options) => await setPassword(resolve(options.repo)))
	// list
	.command('list <target:list-target>', 'List profiles, users or modules')
	.option('--json', 'Output as a JSON array')
	.action(async (options, target: ListTarget) => {
		const entries = await listEntries(resolve(options.repo), target)
		console.log(options.json ? JSON.stringify(entries) : entries.join('\n'))
	})

try {
	await command.parse(Deno.args)
} catch (error) {
	console.error(`Error: ${error instanceof Error ? error.message : String(error)}`)
	Deno.exit(1)
}
