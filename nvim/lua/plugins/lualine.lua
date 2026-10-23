local function active_lsp()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then return "" end

	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end
	table.sort(names)
	return table.concat(names, ",")
end

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			icons_enabled = true,
			theme = "auto",
			component_separators = "",
			section_separators = "",
			globalstatus = true,
			disabled_filetypes = { statusline = { "neo-tree" } },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch" },
			lualine_c = { { "filename", path = 1 }, "diff" },
			lualine_x = {
				{
					"diagnostics",
					symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
				},
				active_lsp,
				"filetype",
			},
			lualine_y = {},
			lualine_z = { "location" },
		},
		tabline = {
			lualine_a = {
				{
					"buffers",
					show_filename_only = false,
					max_length = function() return vim.o.columns end,
					use_mode_colors = false,
					buffers_color = {
						active = { fg = "#f0f6fc", bg = "#161b22", gui = "bold" },
						inactive = { fg = "#8b949e", bg = "#0d1117" },
					},
					symbols = { modified = " ●", alternate_file = "", directory = "" },
				},
			},
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = {},
		},
	},
}
