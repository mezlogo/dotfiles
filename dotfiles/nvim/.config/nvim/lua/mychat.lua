--- llm chat plugin
--[[
By leveraging instruct_llm.ts CLI tool integrate chat with llm within a single markdown file.
`instruct_llm.ts` uses markdown file with additional specific header marks like:
# @SYSTEM
# @USER
# @PREFIX
# @ASSISTANT

This plugins helps to call cli with given input file and capture response as stdout.
When everything is ok is just appends data as @ASSISTANT response.
]]
local M = {}

M.llm_chat_max_tokens = 4000
M.llm_chat_api_url = 'https://codestral.mistral.ai/v1/chat/completions'
M.llm_chat_model_name = 'codestral-latest'

-- util for executing programm
M.exec_programm = function(cmd, args, stdoutCallback, stderrCallback)
  local uv = vim.uv
  local stdout_pipe = uv.new_pipe(false)
  local stderr_pipe = uv.new_pipe(false)
  local handle
  local on_exit = function()
    uv.read_stop(stdout_pipe)
    uv.close(stdout_pipe)

    uv.read_stop(stderr_pipe)
    uv.close(stderr_pipe)

    uv.close(handle)
  end

  local options = {
    args = args,
    stdio = { nil, stdout_pipe, stderr_pipe },
  }

  handle = uv.spawn(cmd, options, on_exit)

  uv.read_start(stdout_pipe, function(err, data)
    if err then
      print('stdout_pipe/err: ' .. err)
    end
    if data then
      stdoutCallback(data)
    end
  end)

  uv.read_start(stderr_pipe, function(err, data)
    if err then
      print('stderr_pipe/err: ' .. err)
    end
    if data then
      stderrCallback(data)
    end
  end)
end

M.call_chat = function()
  vim.cmd('write')
  local filename = vim.api.nvim_buf_get_name(0)
  local args = {
    '--isIncludeAssistant',
    '--maxTokens', M.llm_chat_max_tokens,
    '--apiUrl', M.llm_chat_api_url,
    '--model', M.llm_chat_model_name,
    '--promptFile', filename,
  }

  local stdoutCallback = function(output)
    local lines = vim.split(output, "\n")

    print(vim.inspect(lines))

    vim.schedule(function ()
      vim.api.nvim_buf_set_lines(0, -1, -1, false, lines)
      vim.cmd('write')
    end)
  end

  local stderrCallback = function(err)
    print(err)
  end

  M.exec_programm('instruct_llm.ts', args, stdoutCallback, stderrCallback)
end

M.setup = function(opts)
  opts = opts or {}
  M.llm_chat_max_tokens = opts.llm_chat_max_tokens or M.llm_chat_max_tokens
  M.llm_chat_api_url = opts.llm_chat_api_url or M.llm_chat_api_url
  M.llm_chat_model_name = opts.llm_chat_model_name or M.llm_chat_model_name
end

return M
