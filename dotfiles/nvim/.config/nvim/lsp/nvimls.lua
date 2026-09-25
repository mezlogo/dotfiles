return {
  cmd = {'lua-language-server'},
  filetypes = {'lua'},
  root_markers = {'.luarc.json'},
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'}
      },
      workspace = {
        checkThirdParty = false,
        library = {
          -- Make the server aware of Neovim runtime files
          vim.env.VIMRUNTIME,
          vim.fn.stdpath('config'),
        },
      },
    },
  },
}
