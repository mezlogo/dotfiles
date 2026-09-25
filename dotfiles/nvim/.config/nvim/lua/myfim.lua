local M = {}

M.llm_fim_url = 'https://codestral.mistral.ai/v1/fim/completions'
M.llm_fim_key = vim.env.LLM_FIM_API_KEY
M.llm_max_tokens = 200

M.get_file_name_before_and_after_text = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr):match("([^/\\]+)$") or ""

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_row, current_col = cursor[1] - 1, cursor[2]

  local last_row = vim.api.nvim_buf_line_count(0)
  local last_col = #vim.api.nvim_buf_get_lines(0, last_row - 1, last_row, false)[1]

  local before_table = vim.api.nvim_buf_get_text(bufnr, 0, 0, current_row, current_col, {})
  local after_table = vim.api.nvim_buf_get_text(bufnr, current_row, current_col, last_row - 1, last_col, {})

  local before_text = table.concat(before_table, "\n")
  local after_text = table.concat(after_table, "\n")

  return {
    filename = filename, before_text = before_text, after_text = after_text, current_row = current_row, current_col = current_col,
  }
end

M.call_curl = function(url, method, headers, body, responseCallback)
  local uv = vim.uv
  local stdout_pipe = uv.new_pipe(false)
  local stderr_pipe = uv.new_pipe(false)
  local handle
  local on_exit = function (code)
    print('curl exit code: ' .. code)

    uv.read_stop(stdout_pipe)
    uv.close(stdout_pipe)

    uv.read_stop(stderr_pipe)
    uv.close(stderr_pipe)

    uv.close(handle)
  end

  local cmd = 'curl'

  local args = {
    '-s',
    '--location', url,
    '-X', method,
  }

  if body then
    table.insert(args, '--data')
    table.insert(args, vim.json.encode(body))
  end

  for key, value in pairs(headers) do
    table.insert(args, '--header')
    table.insert(args, key .. ': ' .. value)
  end

  local options = {
    args = args,
    stdio = { nil, stdout_pipe, stderr_pipe },
  }

  handle = uv.spawn(cmd, options, on_exit)

  uv.read_start(stdout_pipe, function (err, data)
    if err then
      print('stdout_pipe/err: ' .. err)
    end
    if data then
      responseCallback(data)
    end
  end)

  uv.read_start(stderr_pipe, function (err, data)
    if err then
      print('stderr_pipe/err: ' .. err)
    end
    if data then
      print('stderr_pipe/data: ' .. data)
    end
  end)
end

M.split_string_by_newline = function(str)
  local result = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(result, line)
  end
  return result
end


M.capture_text_then_call_fim_complition_then_insert_result = function()
  local result = M.get_file_name_before_and_after_text()
  local headers = {
    ["Content-Type"] = 'application/json',
    Accept = 'application/json',
    Authorization = 'Bearer ' .. M.llm_fim_key,
  }
  local request = {
    model = 'codestral-latest',
    stream = false,
    max_tokens = M.llm_max_tokens,
    temperature = 0,
    prompt = result.before_text,
    suffix = result.after_text,
  }

  M.call_curl(M.llm_fim_url, 'POST', headers, request, function(data)
    if data then
      local payload = vim.json.decode(data)
      if payload and payload.choices and 0 < #payload.choices then
        local choice =  payload.choices[1]
        if choice.message and choice.message.content then
          local content = choice.message.content
          local content_table = M.split_string_by_newline(content)
          vim.schedule(function()
            vim.api.nvim_buf_set_text(0, result.current_row, result.current_col, result.current_row, result.current_col, content_table)
          end)
        end
      end
    end
  end)
end

return M
