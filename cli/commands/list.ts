import { findModules, findProfiles, findUsers } from '../shared/repository.ts'

export const listTargets = ['profiles', 'users', 'modules'] as const
export type ListTarget = typeof listTargets[number]

export async function listEntries(repository: string, target: ListTarget) {
	switch (target) {
		case 'profiles':
			return await findProfiles(repository)
		case 'users':
			return await findUsers(repository)
		case 'modules':
			return await findModules(repository)
	}
}
