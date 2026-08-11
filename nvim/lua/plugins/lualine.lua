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
	opts = {
		options = {
			icons_enabled = false,
			theme = "auto",
			component_separators = "",
			section_separators = "",
			globalstatus = true,
			disabled_filetypes = { statusline = { "neo-tree" } },
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch" },
			lualine_c = { { "filename", path = 1 } },
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
	},
}
