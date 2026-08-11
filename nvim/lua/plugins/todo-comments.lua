return {
	"folke/todo-comments.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		signs = false,
		keywords = {
			FIX = { alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
			TODO = { alt = { "TASK" } },
			HACK = {},
			WARN = { alt = { "WARNING" } },
			PERF = { alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
			NOTE = { alt = { "INFO" } },
			TEST = { alt = { "TESTING", "PASSED", "FAILED" } },
		},
	},
	keys = {
		{ "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
		{ "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
		{ "<leader>fT", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
	},
}
