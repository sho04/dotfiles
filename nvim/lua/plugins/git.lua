return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "-" },
			changedelete = { text = "~" },
			untracked = { text = "?" },
		},
		current_line_blame = false,
		on_attach = function(bufnr)
			local gs = require("gitsigns")
			local function map(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
			end

			map("n", "]h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
					return
				end
				vim.schedule(function() gs.nav_hunk("next") end)
			end, "Next Git hunk")

			map("n", "[h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
					return
				end
				vim.schedule(function() gs.nav_hunk("prev") end)
			end, "Previous Git hunk")

			map("n", "<leader>hp", gs.preview_hunk, "Preview Git hunk")
			map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame current line")
			map("n", "<leader>hd", gs.diffthis, "Diff current file")
		end,
	},
}
