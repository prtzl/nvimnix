local map = require('utils').map

--------------------------------------------------------------------------------
-- Toggle formatting on a file (default on)
local formatToggleState = true

-- Format the file before it is written
local formatToggle = function()
    local client = vim.lsp.get_clients({ bufnr = 0 })[1]
    if formatToggleState and client ~= nil then
        vim.lsp.buf.format { async = false }
    end
end

vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('OnWrite', {}),
    callback = formatToggle
})

local toggleFormat = function()
    if not formatToggleState then
        formatToggleState = true
        print("Format enabled!")
    else
        formatToggleState = false
        print("Format disabled!")
    end
end

map("n", "<F10>", function() toggleFormat() end,
    { desc = "Toggle file on-save format (default on)" })
map("i", "<F10>", function() toggleFormat() end,
    { desc = "Toggle file on-save format (default on)" })

--------------------------------------------------------------------------------
-- Reload file when it has changed
vim.api.nvim_create_autocmd({ 'VimEnter', 'FocusGained', 'BufEnter' }, {
    group = vim.api.nvim_create_augroup('ReloadFileOnChange', {}),
    command = 'checktime',
})
