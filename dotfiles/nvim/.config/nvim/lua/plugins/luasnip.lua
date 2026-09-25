local function setLuaSnipKeyMaps()

  local ls = require("luasnip")

  vim.keymap.set({"i"}, "<C-K>", function() ls.expand() end, {silent = true})
  vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
  vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

  vim.keymap.set({"i", "s"}, "<C-E>", function()
    if ls.choice_active() then
      ls.change_choice(1)
    end
  end, {silent = true})

end

return {
  "L3MON4D3/LuaSnip",
  event = "VeryLazy",
  dependencies = {
    "rafamadriz/friendly-snippets", -- optional but recommended
  },
  -- follow latest release.
  -- version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
  -- install jsregexp (optional!).
  build = "make install_jsregexp",
  config = function()
    local ls = require("luasnip")
    ls.setup({}) -- Basic setup for LuaSnip

    require("luasnip.loaders.from_vscode").lazy_load()
    setLuaSnipKeyMaps()
    local snippets_path = vim.fn.stdpath("config") .. "/lua/snippets"
    require("luasnip.loaders.from_lua").load({ paths = snippets_path })
  end,
}
