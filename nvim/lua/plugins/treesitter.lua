return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")
			local parsers = require("config.languages").treesitter

			treesitter.setup({})

			vim.api.nvim_create_user_command("TSInstallConfigured", function(args)
				local task = treesitter.install(parsers)
				if args.bang then task:wait(300000) end
			end, {
				bang = true,
				desc = "Install the configured Treesitter parsers",
			})

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("dotfiles-treesitter", { clear = true }),
				callback = function()
					if not pcall(vim.treesitter.start) then return end
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		lazy = false,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@function.outer"] = "V",
						["@parameter.outer"] = "v",
					},
				},
				move = { set_jumps = true },
			})

			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			vim.keymap.set({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end, { desc = "Around function" })
			vim.keymap.set({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end, { desc = "Inside function" })
			vim.keymap.set({ "x", "o" }, "ab", function()
				select.select_textobject("@block.outer", "textobjects")
			end, { desc = "Around block" })
			vim.keymap.set({ "x", "o" }, "ib", function()
				select.select_textobject("@block.inner", "textobjects")
			end, { desc = "Inside block" })
			vim.keymap.set({ "x", "o" }, "ap", function()
				select.select_textobject("@parameter.outer", "textobjects")
			end, { desc = "Around parameter" })
			vim.keymap.set({ "x", "o" }, "ip", function()
				select.select_textobject("@parameter.inner", "textobjects")
			end, { desc = "Inside parameter" })

			vim.keymap.set({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function" })
			vim.keymap.set({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Previous function" })
			vim.keymap.set({ "n", "x", "o" }, "]p", function()
				move.goto_next_start("@parameter.inner", "textobjects")
			end, { desc = "Next parameter" })
			vim.keymap.set({ "n", "x", "o" }, "[p", function()
				move.goto_previous_start("@parameter.inner", "textobjects")
			end, { desc = "Previous parameter" })
		end,
	},
}
