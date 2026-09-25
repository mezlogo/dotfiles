vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent dir in Oil" })
vim.keymap.set("n", "gl", function()
	vim.diagnostic.open_float()
end, { desc = "Open parent dir in Oil" })
vim.keymap.set("n", "<leader>cf", function()
	require("conform").format({
		lsp_format = "fallback",
	})
end, { desc = "Format current file" })
