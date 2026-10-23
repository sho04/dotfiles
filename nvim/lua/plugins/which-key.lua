return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		icons = {
			mappings = true,
		},
		spec = {
			{ "<leader>b", group = "Buffer" },
			{ "<leader>c", group = "Code" },
			{ "<leader>d", group = "Diagnostics" },
			{ "<leader>e", group = "Explorer" },
			{ "<leader>f", group = "Find" },
			{ "<leader>h", group = "Git hunk" },
			{ "<leader>q", group = "Sessions" },
			{ "<leader>r", group = "Refactor" },
			{ "<leader>t", group = "Terminal/toggles" },
			{ "<leader>w", group = "Window/workspace" },
		},
	},
}
