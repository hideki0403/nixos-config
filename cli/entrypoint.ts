import { dirname, resolve } from 'node:path'
import { Command } from '@cliffy/command'
import { createHost } from './commands/host.ts'
import { createUser } from './commands/user.ts'
import { setPassword } from './commands/password.ts'

const command = new Command()
  .name('nixos-config-cli')
	.description('NixOS configuration CLI')
	.globalOption('-r, --repo <path:string>', 'Flake repository', {
		default: import.meta.dirname == null ? Deno.cwd() : dirname(import.meta.dirname),
	})
	.globalAction(() => {
		if (!Deno.stdin.isTerminal() || !Deno.stdout.isTerminal()) {
			throw new Error('Please run in a terminal')
		}
	})
	// host
	.command('host', 'Create a host configuration')
	.action(async (options) => await createHost(resolve(options.repo)))
	// user
	.command('user', 'Create a user profile')
	.action(async (options) => await createUser(resolve(options.repo)))
	// password
	.command('password', 'Set the user password')
	.action(async (options) => await setPassword(resolve(options.repo)))

try {
	await command.parse(Deno.args)
} catch (error) {
	console.error(`Error: ${error instanceof Error ? error.message : String(error)}`)
	Deno.exit(1)
}
