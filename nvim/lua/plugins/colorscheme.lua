return {
	"projekt0n/github-nvim-theme",
	name = "github-theme",
	lazy = false,
	priority = 1000,
	config = function()
		require("github-theme").setup({})
		vim.cmd.colorscheme("github_dark_default")

		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#161b22" })
		vim.api.nvim_set_hl(0, "LineNr", { fg = "#484f58" })
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#f0f6fc", bold = true })
		vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#30363d" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#161b22" })
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#484f58", bg = "#161b22" })
		vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "#010409" })
		vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "#010409" })
		vim.api.nvim_set_hl(0, "NeoTreeEndOfBuffer", { bg = "#010409" })
		vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = "#30363d", bg = "#010409" })
		vim.api.nvim_set_hl(0, "DiagnosticSignError", { fg = "#f85149" })
		vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#d29922" })
		vim.api.nvim_set_hl(0, "DiagnosticSignInfo", { fg = "#58a6ff" })
		vim.api.nvim_set_hl(0, "DiagnosticSignHint", { fg = "#8b949e" })
		vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#3fb950" })
		vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#d29922" })
		vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f85149" })
	end,
}
