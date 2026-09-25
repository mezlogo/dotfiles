-- [[ Setting options ]] See `:h vim.o`
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`
-- To see documentation for an option, you can use `:h 'optionname'`, for example `:h 'number'`
-- (Note the single quotes)

vim.o.winborder = 'rounded'

-- Print the line number in front of each line
vim.opt.number = true

-- Highlight matching bracets
vim.opt.showmatch = true

-- Use relative line numbers, so that it is easier to jump with j, k. This will affect the 'number'
-- option above, see `:h number_relativenumber`
vim.opt.relativenumber = true

-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    vim.opt.clipboard = 'unnamedplus'
  end,
})

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Highlight the line where the cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Show colomn for icons
vim.opt.signcolumn = "yes"

-- Show <tab> and trailing spaces
vim.opt.list = true

-- Tab related configuration
vim.opt.tabstop = 4      -- Visual tab width
vim.opt.softtabstop = 4  -- Tab key indents 4 spaces
vim.opt.shiftwidth = 4   -- Auto-indent uses 4 spaces
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.smarttab = true  -- Better tab behavior
vim.opt.smartindent = true  -- Better indent

-- Search and replace configuration
vim.opt.ignorecase = true   -- Case-insensitive by default
vim.opt.smartcase = true   -- Case-sensitive if uppercase used
vim.opt.hlsearch = true    -- Highlight matches
vim.opt.incsearch = true   -- Live search feedback
vim.opt.inccommand = "nosplit"  -- Preview substitutions inline (Neovim)
vim.opt.gdefault = true    -- :%s/foo/bar/ replaces all occurrences (no /g needed)

vim.opt.backspace = {"start", "eol", "indent"}

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "100"
vim.g.editorconfig = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s) See `:help 'confirm'`
vim.opt.confirm = true

vim.opt.swapfile = false
vim.opt.backup = false       -- Disable backups (swapfile is enough)
vim.opt.undofile = true      -- Keep undo history


-- Use <Esc> to exit terminal mode

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes

-- [[ Basic Autocommands ]].
-- See `:h lua-guide-autocommands`, `:h autocmd`, `:h nvim_create_autocmd()`

-- Highlight when yanking (copying) text.
-- Try it with `yap` in normal mode. See `:h vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Create user commands ]]
-- See `:h nvim_create_user_command()` and `:h user-commands`

-- Create a command `:GitBlameLine` that print the git blame for the current line
vim.api.nvim_create_user_command('GitBlameLine', function()
  local line_number = vim.fn.line('.') -- Get the current line number. See `:h line()`
  local filename = vim.api.nvim_buf_get_name(0)
  print(vim.fn.system({ 'git', 'blame', '-L', line_number .. ',+1', filename }))
end, { desc = 'Print the git blame for the current line' })

-- [[ Add optional packages ]]
-- Nvim comes bundled with a set of packages that are not enabled by
-- default. You can enable any of them by using the `:packadd` command.

-- For example, to add the "nohlsearch" package to automatically turn off search highlighting after
-- 'updatetime' and when going to insert mode
vim.cmd('packadd! nohlsearch')
