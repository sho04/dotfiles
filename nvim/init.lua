if vim.fn.has("nvim-0.12") ~= 1 then
	vim.api.nvim_err_writeln("This configuration requires Neovim 0.12 or newer")
	return
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
