-- Diagnostic signs
local signs = {
    { name = 'DiagnosticSignError', text = '🔥' },
    { name = 'DiagnosticSignWarn', text = '!' },
    { name = 'DiagnosticSignHint', text = '💡' },
    { name = 'DiagnosticSignInfo', text = '🔸' },
}

for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, {
        text = sign.text,
        texthl = sign.name,
        numhl = ''
    })
end

vim.diagnostic.config {
    virtual_text = true,
    signs = {
        active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
        scope = 'line',
    },
}

