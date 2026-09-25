local function init_dap_keymap()
  -- Example setup using vim.keymap.set
  local opts = { noremap = true, silent = true }
  local keymap = vim.keymap.set

  -- 1. Toggle breakpoint
  keymap('n', '<leader>db', function() require('dap').toggle_breakpoint() end, opts)

  -- 2. Set breakpoint with condition
  keymap('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, opts)

  -- 3. Start/continue debugging
  keymap('n', '<leader>dc', function() require('dap').continue() end, opts)

  -- 4. Pause debugger
  keymap('n', '<leader>dC', function() require('dap').pause() end, opts)

  -- 5. Step over
  keymap('n', '<leader>do', function() require('dap').step_over() end, opts)

  -- 6. Step into
  keymap('n', '<leader>di', function() require('dap').step_into() end, opts)

  -- 7. Step out
  keymap('n', '<leader>dO', function() require('dap').step_out() end, opts)

  -- 8. Restart debugging session
  keymap('n', '<leader>dr', function() require('dap').restart() end, opts)

  -- 9. Stop/close debugging session
  keymap('n', '<leader>dq', function() require('dap').close() end, opts)

  -- 10. Toggle REPL
  keymap('n', '<leader>dl', function() require('dap').repl.toggle() end, opts)
end


local function getDapKeyBindigsInLazyNvimTableFormat()
  -- For each keymap from function init_dap_keymap return as an array of objects { "<le" }
  -- example:
  -- from keymap('n', '<leader>db', function() require('dap').toggle_breakpoint() end, opts)
  -- to { '<leader>db', function() require('dap').toggle_breakpoint() end }
  return {
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle breakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Set breakpoint with condition' },
    { '<leader>dc', function() require('dap').continue() end, desc = 'Start/continue debugging' },
    { '<leader>dC', function() require('dap').pause() end, desc = 'Pause debugger' },
    { '<leader>do', function() require('dap').step_over() end, desc = 'Step over' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'Step into' },
    { '<leader>dO', function() require('dap').step_out() end, desc = 'Step out' },
    -- { '<leader>dR', function() require('dap').restart() end, desc = 'Restart debugging session' },
    { '<leader>dR', ':DapNew<CR>', desc = 'Restart debugging session' },
    { '<leader>dr', function() require('dap').run_last() end, desc = 'Run last session' },
    { '<leader>dq', function() require('dap').terminate() end, desc = 'Terminate process' },
    { '<leader>dl', function() require('dap-view').toggle() end, desc = 'Toggle dap-view' },
  }
end

return {
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    keys = getDapKeyBindigsInLazyNvimTableFormat(),
  }, {
    "igorlfs/nvim-dap-view",
    ---@module 'dap-view'
    ---@type dapview.Config
    opts = {
      winbar = {
        show = true,
        sections = { "console", "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
        default_section = "console",
      },
    },
    dependencies = {
      'mfussenegger/nvim-dap',
    },
  },
}
