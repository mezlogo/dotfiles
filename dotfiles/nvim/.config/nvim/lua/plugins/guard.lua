return {
  "nvimdev/guard.nvim",
  config = function()
    -- 1. Set global configuration to disable auto-format on save
    vim.g.guard_config = {
      fmt_on_save = false, -- Disable automatic formatting when saving a file
      -- You can keep other defaults or add them here if needed
      -- lsp_as_default_formatter = false,
      -- save_on_fmt = true,
      -- etc.
    }
    local ft = require("guard.filetype")
    ft("json"):fmt({
      cmd = 'jq',
      stdin = true
    })

    vim.keymap.set('n', '<leader>F', ':Guard fmt<CR>')
  end
}
