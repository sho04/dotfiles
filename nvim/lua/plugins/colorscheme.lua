return {
	"projekt0n/github-nvim-theme",
	name = "github-theme",
	lazy = false,
	priority = 1000,
	config = function()
		require("github-theme").setup({})
		vim.cmd.colorscheme("github_dark_default")

		-- Deliberately text-first, high-contrast signs with a subtle cursor row.
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#161b22" })
		vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#f85149" })
		vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#d29922" })
		vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#58a6ff" })
		vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#8b949e" })
		vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#3fb950" })
		vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#d29922" })
		vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f85149" })
	end,
}
