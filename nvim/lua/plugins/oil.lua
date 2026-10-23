return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		default_file_explorer = false,
		view_options = { show_hidden = true },
		float = { max_width = 0.8, max_height = 0.8, border = "rounded" },
		keymaps = {
			["q"] = { "actions.close", mode = "n" },
			["<Esc>"] = { "actions.close", mode = "n" },
		},
	},
	keys = {
		{ "-", "<cmd>Oil --float<CR>", desc = "Open parent directory popup" },
	},
}
