return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		{
			"antosha417/nvim-lsp-file-operations",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = {},
		},
	},
	init = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
	end,
	opts = {
		close_if_last_window = true,
		enable_diagnostics = true,
		enable_git_status = true,
		default_component_configs = {
			indent = {
				indent_marker = "|",
				last_indent_marker = "`",
				with_expanders = true,
				expander_collapsed = "+",
				expander_expanded = "-",
			},
			icon = {
				folder_closed = "[+]",
				folder_open = "[-]",
				folder_empty = "[ ]",
				default = " ",
				provider = function(icon) return icon end,
			},
			git_status = {
				symbols = {
					added = "A",
					conflict = "!",
					deleted = "D",
					ignored = "I",
					modified = "M",
					renamed = "R",
					staged = "S",
					unstaged = "U",
					untracked = "?",
				},
			},
		},
		filesystem = {
			filtered_items = {
				visible = true,
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_hidden = false,
			},
			follow_current_file = {
				enabled = true,
				leave_dirs_open = false,
			},
			hijack_netrw_behavior = "disabled",
			use_libuv_file_watcher = true,
		},
		window = {
			position = "left",
			width = 32,
		},
	},
}
