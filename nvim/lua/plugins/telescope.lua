return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	cmd = "Telescope",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
			cond = function() return vim.fn.executable("cmake") == 1 end,
		},
	},
	config = function()
		local telescope = require("telescope")
		telescope.setup({
			defaults = {
				borderchars = { "-", "|", "-", "|", "+", "+", "+", "+" },
				entry_prefix = "  ",
				path_display = { "smart" },
				prompt_prefix = "> ",
				selection_caret = "> ",
				sorting_strategy = "ascending",
				layout_config = {
					prompt_position = "top",
				},
			},
		})
		pcall(telescope.load_extension, "fzf")
	end,
}
