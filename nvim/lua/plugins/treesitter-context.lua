return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		max_lines = 3,
		multiline_threshold = 1,
	},
	keys = {
		{ "<leader>tc", "<cmd>TSContext toggle<CR>", desc = "Toggle sticky code context" },
	},
}
