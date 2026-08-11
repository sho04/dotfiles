local map = vim.keymap.set

map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Search text" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", { desc = "Search word" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffer" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Search help" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Search keymaps" })

map("n", "<leader>e", "<cmd>Neotree toggle left<CR>", { desc = "Toggle file tree" })
map("n", "<leader>E", "<cmd>Neotree reveal left<CR>", { desc = "Reveal current file" })
map("n", "<leader>eg", "<cmd>Neotree git_status toggle left<CR>", { desc = "Git status tree" })

map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

map("n", "<leader>wh", "<C-w>h", { desc = "Focus left window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Focus lower window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Focus upper window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Focus right window" })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<leader>wq", "<cmd>close<CR>", { desc = "Close window" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })

map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Diagnostic details" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostic list" })

map({ "n", "x" }, "<leader>wf", function()
	require("conform").format({ async = false, lsp_format = "fallback", timeout_ms = 3000 })
end, { desc = "Format buffer" })

map("n", "<leader>tt", function()
	vim.cmd("botright 12split")
	vim.cmd.terminal()
	vim.cmd.startinsert()
end, { desc = "Terminal below" })

map("n", "<leader>tv", function()
	vim.cmd("vsplit")
	vim.cmd.terminal()
	vim.cmd.startinsert()
end, { desc = "Terminal right" })
