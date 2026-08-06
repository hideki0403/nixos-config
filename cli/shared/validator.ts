const usernamePattern = /^[a-z_][a-z0-9_-]*$/
const hostnamePattern = /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/
const stateVersionPattern = /^\d{2}\.\d{2}$/
const sopsSecretNamePattern = /^[a-zA-Z0-9_-]+$/

const username = (value: string): string | undefined => usernamePattern.test(value) ? undefined : 'Invalid username. Use lowercase letters, numbers, _ or - and start with a lowercase letter or _'
const hostname = (value: string): string | undefined => hostnamePattern.test(value) ? undefined : 'Invalid hostname. Use lowercase letters, numbers, - and letters are max 63 characters'
const stateVersion = (value: string): string | undefined => stateVersionPattern.test(value) ? undefined : 'Invalid state version. Use the format XX.XX'
const sopsSecretName = (value: string): string | undefined => sopsSecretNamePattern.test(value) ? undefined : 'Invalid secret name. Use letters, numbers, _ or -'
const absolutePath = (value: string): string | undefined => value.startsWith('/') ? undefined : 'Please enter an absolute path.'

export default { username, hostname, stateVersion, sopsSecretName, absolutePath }
