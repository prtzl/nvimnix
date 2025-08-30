-- This shit has to be set so that the completion menu (possibly more) is colored
vim.cmd 'set termguicolors'

-- Color mode
vim.o.background = "dark"

require 'base16-colorscheme'.with_config({
    telescope = true,
    indentblankline = true,
    notify = true,
    ts_rainbow = true,
    cmp = true,
    illuminate = true,
    dapui = true,
})

vim.cmd('colorscheme base16-da-one-ocean')

-- Overrides
-- Override background to inherit terminal one
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" }) -- don't change bg color when switching to inactive windows

-- Transparent complete
vim.api.nvim_set_hl(0, "CmpItemAbbr", { cternbg = nil, bg = nil })

-- Telescope
-- No bracground in telescope
vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })

-- More visible match word in match file list
vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#44475a", bold = true, })
vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = "#ff79c6", bold = true, underline = true, })

-- More visible match line in preview
vim.api.nvim_set_hl(0, "TelescopePreviewMatch", { bg = "none", fg = "#000000", bold = true, })
vim.api.nvim_set_hl(0, "TelescopePreviewLine", { bg = "#3b3c4d", bold = true, underline = true, })
vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none", })
vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = "none", })

-- Telescope borders
vim.api.nvim_set_hl(0, "TelescopeBorder", { ctermbg = 220 })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { ctermbg = 220 })


-- Fix gitsigns highlights (works with word_diff = true)
vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#a6e3a1', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#f9e2af', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#f38ba8', bg = 'NONE' })

-- Word diff highlights (inline highlights inside the line)
vim.api.nvim_set_hl(0, 'GitSignsAddLn', { bg = '#1a2e1a' })
vim.api.nvim_set_hl(0, 'GitSignsChangeLn', { bg = '#2e2a1a' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteLn', { bg = '#2e1a1a' })

-- Word diff text (just the changed words)
vim.api.nvim_set_hl(0, 'GitSignsAddInline', { bg = '#3a5c3a', fg = '#a6e3a1' })
vim.api.nvim_set_hl(0, 'GitSignsChangeInline', { bg = '#5c523a', fg = '#f9e2af' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteInline', { bg = '#5c3a3a', fg = '#f38ba8' })
