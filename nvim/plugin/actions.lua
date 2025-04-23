-- Current format state, enabled on start
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

function vim.g.toggleFormat(state)
    print("Input state, current state: ", state, formatToggleState)
    if ((state ~= nil) and state) or (not formatToggleState) then
        formatToggleState = true
        print("Format enabled!")
    else
        formatToggleState = false
        print("Format disabled!")
    end
end

-- Reload file when it has changed
vim.api.nvim_create_autocmd({ 'VimEnter', 'FocusGained', 'BufEnter' }, {
    group = vim.api.nvim_create_augroup('ReloadFileOnChange', {}),
    command = 'checktime',
})
