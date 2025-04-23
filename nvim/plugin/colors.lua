-- This shit has to be set so that the completion menu (possibly more) is colored
vim.cmd 'set termguicolors'

-- Color mode
vim.o.background = "dark"
vim.cmd("colorscheme base16-da-one-ocean")

local color_bg = require('base16-colorscheme').colors.base00

-- Overrides
-- Transparent complete
vim.api.nvim_set_hl(0, "CmpItemAbbr", { cternbg = nil, bg = nil })

-- More visible match and line highlights in Telescope preview
vim.api.nvim_set_hl(0, "TelescopePreviewMatch", { bg = "#ffaf5f", fg = "#000000", bold = true, })
vim.api.nvim_set_hl(0, "TelescopePreviewLine", { bg = "#44475a", bold = true, })
vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = color_bg, })
vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = color_bg, })


-- Telescope borders
vim.api.nvim_set_hl(0, "TelescopeBorder", { ctermbg = 220 })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { ctermbg = 220 })


-- Define highlight groups for signs and their line/number highlights
vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#5f9400', bold = true })
vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#e5c07b', bold = true })
vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#be5046', bold = true })
vim.api.nvim_set_hl(0, 'GitSignsAddNr', { fg = '#5f9400' })
vim.api.nvim_set_hl(0, 'GitSignsChangeNr', { fg = '#e5c07b' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteNr', { fg = '#be5046' })
vim.api.nvim_set_hl(0, 'GitSignsAddLn', { fg = '#5f9400', underline = true })
vim.api.nvim_set_hl(0, 'GitSignsChangeLn', { fg = '#e5c07b', underline = true })
vim.api.nvim_set_hl(0, 'GitSignsDeleteLn', { fg = '#be5046', underline = true })
vim.api.nvim_set_hl(0, 'GitSignsChangedelete', { fg = '#e5c07b', italic = true })
vim.api.nvim_set_hl(0, 'GitSignsChangedeleteNr', { fg = '#e5c07b' })
vim.api.nvim_set_hl(0, 'GitSignsChangedeleteLn', { fg = '#e5c07b', underline = true })
vim.api.nvim_set_hl(0, 'GitSignsTopdelete', { fg = '#be5046', bold = true })
vim.api.nvim_set_hl(0, 'GitSignsTopdeleteLn', { fg = '#be5046', underline = true })

-- Link highlights to the proper groups (this is what fixes the warnings)
vim.api.nvim_set_hl(0, 'GitSignsAddNr', { link = 'GitSignsAddNr' })
vim.api.nvim_set_hl(0, 'GitSignsChangeNr', { link = 'GitSignsChangeNr' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteNr', { link = 'GitSignsDeleteNr' })
vim.api.nvim_set_hl(0, 'GitSignsAddLn', { link = 'GitSignsAddLn' })
vim.api.nvim_set_hl(0, 'GitSignsChangeLn', { link = 'GitSignsChangeLn' })
vim.api.nvim_set_hl(0, 'GitSignsDeleteLn', { link = 'GitSignsDeleteLn' })
vim.api.nvim_set_hl(0, 'GitSignsChangedeleteLn', { link = 'GitSignsChangedeleteLn' })
vim.api.nvim_set_hl(0, 'GitSignsChangedeleteNr', { link = 'GitSignsChangedeleteNr' })
vim.api.nvim_set_hl(0, 'GitSignsTopdeleteLn', { link = 'GitSignsTopdeleteLn' })
vim.api.nvim_set_hl(0, 'GitSignsTopdeleteNr', { link = 'GitSignsTopdeleteNr' })
