local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.expandtab = true
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.smartindent = true

opt.termguicolors = true
opt.colorcolumn = "120"
opt.signcolumn = "yes"
opt.wrap = false
opt.fillchars:append({ eob = " " })
opt.laststatus = 3
opt.showmode = false
opt.ruler = false
opt.showcmd = false
opt.pumheight = 12

opt.splitbelow = true
opt.splitright = true
opt.equalalways = false

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

opt.autoread = true
opt.backup = false
opt.writebackup = false
opt.swapfile = true
opt.undofile = true
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 400

opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.mouse = "a"

opt.foldlevel = 99
opt.foldlevelstart = 99

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
