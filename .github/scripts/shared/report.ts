export type Report = {
	host: string
	closureSize: number | null
	storePaths: number | null
	built: number
	substituted: number
	wallClock: number
	slow: { name: string; duration: number }[]
	largest: { path: string; narSize: number }[]
}
