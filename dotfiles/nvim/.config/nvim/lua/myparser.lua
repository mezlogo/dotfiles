local M = {}

M.goto_prev_method = function()
  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = vim.treesitter.query.parse(
    parser:lang(),
    [[
        (function_declaration) @func
        (arrow_function) @func
        ]]
  )

  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local last_method_line = current_line
  local prev_method_line = nil
  local hasReachCurrentLine = false

  for id, node in query:iter_captures(root) do
    local range = { node:range() }
    local method_line = range[1] + 1

    if current_line <= method_line then
      hasReachCurrentLine = true
    end

    if not hasReachCurrentLine then
      prev_method_line = method_line
    end

    last_method_line = method_line
  end

  local result = (hasReachCurrentLine) and prev_method_line or last_method_line
  vim.api.nvim_win_set_cursor(0, { result, 0 })
end

M.goto_next_method = function()
  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = vim.treesitter.query.parse(
    parser:lang(),
    [[
        (function_declaration) @func
        (arrow_function) @func
        ]]
  )

  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local first_method_line = nil

  for id, node in query:iter_captures(root) do
    local range = { node:range() }
    local method_line = range[1] + 1

    if first_method_line == nil then
      first_method_line = method_line
    end

    if current_line < method_line then
      vim.api.nvim_win_set_cursor(0, { method_line, 0 })
      return
    end
  end

  if not (first_method_line == nil) then
    vim.api.nvim_win_set_cursor(0, { first_method_line, 0 })
  end
end

M.fold_method_bodies = function()
  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  local query = vim.treesitter.query.parse(
    parser:lang(),
    [[
        (function_declaration) @func
        (arrow_function) @func
        ]]
  )

  for id, node in query:iter_captures(root) do
    local range = { node:range() }
    local from = range[1] + 1
    local to = range[3] + 1
    if 1 < (to - from) then
      from = from + 1
      to = to - 1
      local cmd = string.format("%d,%dfold", from, to)
      vim.cmd(cmd)
    end
  end
end

return M
