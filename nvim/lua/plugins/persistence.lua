return {
	"folke/persistence.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {},
	keys = {
		{ "<leader>qs", function() require("persistence").load() end, desc = "Restore project session" },
		{ "<leader>qS", function() require("persistence").select() end, desc = "Select session" },
		{ "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
		{ "<leader>qd", function() require("persistence").stop() end, desc = "Skip saving this session" },
	},
}
