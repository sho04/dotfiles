local group = vim.api.nvim_create_augroup("dotfiles", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	group = group,
	command = "silent! checktime",
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = {
		"css",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"jsonc",
		"typescript",
		"typescriptreact",
		"yaml",
	},
	callback = function()
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 2
		vim.bo.softtabstop = 2
		vim.bo.tabstop = 2
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.wo.wrap = true
		vim.wo.linebreak = true
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = group,
	callback = function(args)
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], {
			buffer = args.buf,
			desc = "Leave terminal input",
		})
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	group = group,
	callback = function()
		if vim.fn.argc() ~= 1 then return end

		local directory = vim.fn.argv(0)
		if vim.fn.isdirectory(directory) ~= 1 then return end

		local directory_buffer = vim.api.nvim_get_current_buf()
		vim.cmd.cd(vim.fn.fnameescape(directory))
		vim.cmd.enew()
		vim.api.nvim_buf_delete(directory_buffer, { force = true })
	end,
})
