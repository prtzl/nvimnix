local x = vim.diagnostic.severity

vim.diagnostic.config {
    virtual_text = true,
    signs = {
        text = {
            [ x.ERROR ] = "🔥",
            [ x.WARN ] = "!",
            [ x.HINT ] = "💡",
            [ x.INFO ] = "🔸",
        },
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

