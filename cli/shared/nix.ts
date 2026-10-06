export function nixString(value: string) {
	return `"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"`
}

export async function nixosRelease(repository: string) {
	const result = await new Deno.Command('nix', {
		args: ['--extra-experimental-features', 'nix-command flakes', 'eval', '--raw', '--inputs-from', repository, 'nixpkgs#lib.trivial.release'],
		stdout: 'piped',
		stderr: 'piped',
	}).output()

	if (!result.success) {
		throw new Error(`Failed to resolve NixOS release\n${new TextDecoder().decode(result.stderr).trim()}`)
	}
	return new TextDecoder().decode(result.stdout).trim()
}
