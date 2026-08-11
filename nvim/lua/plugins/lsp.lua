local servers = {
	"bashls",
	"clangd",
	"docker_compose_language_service",
	"dockerls",
	"eslint",
	"jsonls",
	"lua_ls",
	"pyright",
	"ruff",
	"rust_analyzer",
	"taplo",
	"ts_ls",
	"yamlls",
}

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			"mason-org/mason.nvim",
			{ "b0o/SchemaStore.nvim", lazy = true },
		},
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config("*", { capabilities = capabilities })

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							diagnosticMode = "openFilesOnly",
							useLibraryCodeForTypes = true,
						},
					},
				},
			})

			vim.lsp.config("ruff", {
				on_attach = function(client)
					client.server_capabilities.hoverProvider = false
				end,
			})

			vim.lsp.config("jsonls", {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			})

			vim.lsp.config("yamlls", {
				settings = {
					yaml = {
						schemaStore = { enable = false, url = "" },
						schemas = require("schemastore").yaml.schemas(),
						validate = true,
					},
				},
			})

			vim.lsp.config("eslint", {
				settings = {
					workingDirectory = { mode = "auto" },
				},
			})

			vim.lsp.enable(servers)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("dotfiles-lsp", { clear = true }),
				callback = function(event)
					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					local telescope = require("telescope.builtin")
					map("gd", telescope.lsp_definitions, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gr", telescope.lsp_references, "Find references")
					map("gi", telescope.lsp_implementations, "Go to implementation")
					map("K", vim.lsp.buf.hover, "Hover documentation")
					map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("<leader>fs", telescope.lsp_document_symbols, "Document symbols")
					map("<leader>fS", telescope.lsp_dynamic_workspace_symbols, "Workspace symbols")
					map("<leader>ti", function()
						local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
						vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
					end, "Toggle inlay hints")

					vim.keymap.set("x", "<leader>ca", vim.lsp.buf.code_action, {
						buffer = event.buf,
						desc = "LSP: Code action",
					})
				end,
			})
		end,
	},
	{
		"seblyng/roslyn.nvim",
		ft = { "cs", "razor" },
		dependencies = { "neovim/nvim-lspconfig" },
		opts = {
			broad_search = false,
			filewatching = "roslyn",
		},
		config = function(_, opts)
			require("roslyn").setup(opts)
			vim.lsp.config("roslyn", {
				settings = {
					["csharp|background_analysis"] = {
						dotnet_analyzer_diagnostics_scope = "openFiles",
						dotnet_compiler_diagnostics_scope = "openFiles",
					},
					["csharp|completion"] = {
						dotnet_show_completion_items_from_unimported_namespaces = true,
					},
					["csharp|inlay_hints"] = {
						csharp_enable_inlay_hints_for_types = true,
						dotnet_enable_inlay_hints_for_parameters = true,
					},
					["csharp|symbol_search"] = {
						dotnet_search_reference_assemblies = true,
					},
				},
			})
		end,
	},
}
