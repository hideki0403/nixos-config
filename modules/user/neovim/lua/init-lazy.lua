require("lazy").setup("plugins", {
	defaults = {
		lazy = true,
	},
	dev = {
		path = "@lazy-path@",
		patterns = { "." },
		fallback = true,
	},
	performance = {
		cache = {
			enabled = true,
		},
	},
})