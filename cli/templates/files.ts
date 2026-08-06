const templates = {
  'host/configuration.nix': new URL('./host/configuration.nix', import.meta.url),
  'user/account.nix': new URL('./user/account.nix', import.meta.url),
  'user/identity.nix': new URL('./user/identity.nix', import.meta.url),
  'user/home/base/default.nix': new URL('./user/home/base/default.nix', import.meta.url),
  'user/home/profile/default.nix': new URL('./user/home/profile/default.nix', import.meta.url),
} as const

export type Templates = typeof templates
export default templates
