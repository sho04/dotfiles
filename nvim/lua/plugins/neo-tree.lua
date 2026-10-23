return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
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
		sources = { "filesystem", "buffers", "git_status", "document_symbols" },
		source_selector = {
			winbar = true,
			sources = {
				{ source = "filesystem", display_name = "󰉓 Files" },
				{ source = "buffers", display_name = "󰈚 Buffers" },
				{ source = "git_status", display_name = "󰊢 Git" },
			},
		},
		close_if_last_window = true,
		enable_diagnostics = true,
		enable_git_status = true,
		default_component_configs = {
			indent = {
				indent_marker = "│",
				last_indent_marker = "└",
				with_expanders = true,
				expander_collapsed = "",
				expander_expanded = "",
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
		document_symbols = {
			follow_cursor = true,
			window = { mappings = { ["<C-r>"] = "none" } },
		},
		window = {
			position = "float",
			popup = {
				size = { width = "70%", height = "80%" },
				border = "rounded",
			},
		},
	},
}
