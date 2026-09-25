-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function opts(description)
  return {
    noremap = true,
    silent = true,
    desc = description,
  }
end

-- Took from https://github.com/Sin-cy/dotfiles/blob/main/nvim/.config/nvim/lua/sethy/core/keymaps.lua
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts("moves lines down in visual selection"))
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts("moves lines up in visual selection"))

vim.keymap.set("n", "<C-d>", "<C-d>zz", opts("move down in buffer with cursor centered"))
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts("move up in buffer with cursor centered"))
vim.keymap.set("n", "n", "nzzzv", opts("next search result with cursor centered"))
vim.keymap.set("n", "N", "Nzzzv", opts("prev search result with cursor centered"))

vim.keymap.set("v", "<", "<gv", opts("shift to the left selected lines"))
vim.keymap.set("v", ">", ">gv", opts("shift to the right selected lines"))
vim.keymap.set("n", "x", '"_x', opts("prevent x delete from registering when next paste"))

--vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
--    { desc = "Replace word cursor is on globally" })

-- Other sources
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", opts("turn off search highlight")) -- Clear with Escape

-- Use <Esc> to exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ "t", "i" }, "<A-h>", "<C-\\><C-n><C-w>h")
vim.keymap.set({ "t", "i" }, "<A-j>", "<C-\\><C-n><C-w>j")
vim.keymap.set({ "t", "i" }, "<A-k>", "<C-\\><C-n><C-w>k")
vim.keymap.set({ "t", "i" }, "<A-l>", "<C-\\><C-n><C-w>l")
vim.keymap.set({ "n" }, "<A-h>", "<C-w>h")
vim.keymap.set({ "n" }, "<A-j>", "<C-w>j")
vim.keymap.set({ "n" }, "<A-k>", "<C-w>k")
vim.keymap.set({ "n" }, "<A-l>", "<C-w>l")

-- Map treesitter based keymaps
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    local ok, _ = pcall(vim.treesitter.get_parser)
    if ok then
      vim.keymap.set('n', 'zM', require('myparser').fold_method_bodies, opts("fold method bodies only"))
      vim.keymap.set('n', ']m', require('myparser').goto_next_method, opts("goto next method declaration line"))
      vim.keymap.set('n', '[m', require('myparser').goto_prev_method, opts("goto prev method declaration line"))
    end
  end,
})

local myfim = require('myfim')
vim.keymap.set("n", "<leader>x", myfim.capture_text_then_call_fim_complition_then_insert_result,
  opts("generate code using whole file and FIM"))


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(event)
    local map = vim.keymap.set
    local opts = { silent = true, buffer = event.buf }

    map("n", "gK", vim.lsp.buf.signature_help, opts)    -- signature help (if hover not enough)
    map("n", "grf", vim.lsp.buf.format, opts)
  end,
})

vim.keymap.set("n", "R", "<Plug>(JqPlaygroundRunQuery)")

--- LuaSnip keymaps
vim.keymap.set({"i"}, "<C-K>", function() require("luasnip").expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() require("luasnip").jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-J>", function() require("luasnip").jump(-1) end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-E>", function()
  if require("luasnip").choice_active() then
    require("luasnip").change_choice(1)
  end
end, {silent = true})
