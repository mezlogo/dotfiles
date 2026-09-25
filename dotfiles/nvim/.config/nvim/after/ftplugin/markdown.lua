local mychat = require('mychat')
vim.keymap.set("n", "<leader>x", mychat.call_chat, { buffer = true, desc = 'generate code using whole file and FIM' })

