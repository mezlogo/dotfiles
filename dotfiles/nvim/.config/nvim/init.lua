require('config.base')
require('config.keymaps')
require('config.lazy')
require('config.detectkotlin')

local enable_lsp = vim.g.enable_lsp

if enable_lsp then
  vim.lsp.enable(enable_lsp)
end

-- find first file with given extension e.g. ".java" and open it in a buffer
local function find_and_open(extension)
  local file = vim.fn.glob("**/*" .. extension, nil, true)[1]
  if file then
    vim.cmd("e " .. file)
  else
    print("Can not find any file with given extension: " .. extension)
  end
end

local open_ft = vim.g.open_ft
if open_ft then
  find_and_open(open_ft)
end

vim.cmd([[colorscheme kanagawa]])

-- vim.api.nvim_create_user_command('LspNvim', function()
--   vim.lsp.enable('nvimls')
-- end, {})

-- vim.lsp.enable('jinja_lsp')
-- vim.lsp.enable('kotlin_lsp')
vim.lsp.enable('nvimls')
vim.lsp.enable('jsonls')
vim.lsp.enable('protols')

-- vim.lsp.log.set_level('debug');

-- In your `init.lua` or filetype plugin
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_gb"

    vim.opt_local.dictionary = "/usr/share/dict/british-english"
    vim.opt_local.complete:append("k")  -- 'k' enables dictionary completion
  end,
})

require('myscratch').setup()
