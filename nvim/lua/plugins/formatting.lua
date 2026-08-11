local function format_disabled(bufnr)
	if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return true end
	return vim.fs.root(bufnr, { ".nvim-disable-format" }) ~= nil
end

return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = { "ConformInfo" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				bash = { "shfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				cs = { "csharpier" },
				css = { "prettier" },
				html = { "prettier" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				lua = { "stylua" },
				markdown = { "prettier" },
				python = { "ruff_organize_imports", "ruff_format" },
				rust = { "rustfmt" },
				toml = { "taplo" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				yaml = { "prettier" },
			},
			default_format_opts = {
				lsp_format = "fallback",
				timeout_ms = 3000,
			},
			format_on_save = function(bufnr)
				if format_disabled(bufnr) then return nil end
				return {
					lsp_format = "fallback",
					timeout_ms = 3000,
				}
			end,
			notify_no_formatters = false,
		})

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.g.disable_autoformat = true
				vim.notify("Format-on-save disabled for this session")
			else
				vim.b.disable_autoformat = true
				vim.notify("Format-on-save disabled for this buffer")
			end
		end, { bang = true, desc = "Disable format-on-save" })

		vim.api.nvim_create_user_command("FormatEnable", function(args)
			if args.bang then
				vim.g.disable_autoformat = false
				vim.notify("Format-on-save enabled for this session")
			else
				vim.b.disable_autoformat = false
				vim.notify("Format-on-save enabled for this buffer")
			end
		end, { bang = true, desc = "Enable format-on-save" })
	end,
}
