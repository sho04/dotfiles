return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		indent = { char = "|" },
		scope = {
			enabled = true,
			char = "|",
		},
		exclude = {
			filetypes = { "help", "lazy", "mason", "neo-tree", "terminal" },
		},
	},
}
