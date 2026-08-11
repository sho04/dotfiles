return {
	"saghen/blink.cmp",
	version = "1.*",
	event = "InsertEnter",
	opts = {
		keymap = {
			preset = "enter",
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
		},
		completion = {
			list = {
				selection = {
					preselect = false,
					auto_insert = false,
				},
			},
			menu = {
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind" },
					},
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 300,
				window = { border = "single" },
			},
			ghost_text = { enabled = false },
		},
		sources = {
			default = { "lsp", "path", "buffer" },
		},
		signature = {
			enabled = true,
			window = { border = "single" },
		},
		cmdline = { enabled = false },
	},
}
