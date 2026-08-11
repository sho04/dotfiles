local opt = vim.opt

-- Line numbers and navigation
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Indentation defaults; project EditorConfig files take precedence.
opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.smartindent = true

-- Display
opt.termguicolors = true
opt.colorcolumn = "120"
opt.signcolumn = "yes"
opt.wrap = false
opt.fillchars:append({ eob = " " })
opt.laststatus = 3

-- Windows and splits
opt.splitbelow = true
opt.splitright = true
opt.equalalways = false

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Files, state, and responsiveness
opt.autoread = true
opt.backup = false
opt.writebackup = false
opt.swapfile = true
opt.undofile = true
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 400

-- Input and integration
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.mouse = "a"

-- Treesitter-backed folds are available without closing files on startup.
opt.foldlevel = 99
opt.foldlevelstart = 99

-- This configuration does not use the legacy language providers.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.diagnostic.config({
	float = {
		border = "single",
		source = "if_many",
	},
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
	underline = true,
	update_in_insert = false,
	virtual_text = false,
})
