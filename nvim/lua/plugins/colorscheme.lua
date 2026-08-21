return {
	"olimorris/onedarkpro.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		local theme = vim.env.NVIM_ONEDARK_STYLE or "onedark_dark"
		local valid_themes = {
			onedark = true,
			onedark_dark = true,
			onedark_vivid = true,
			onelight = true,
			vaporwave = true,
		}
		if not valid_themes[theme] then theme = "onedark_dark" end

		require("onedarkpro").setup({
			styles = { comments = "italic" },
			options = {
				cursorline = true,
				terminal_colors = true,
				transparency = false,
			},
		})
		vim.cmd.colorscheme(theme)
	end,
}
