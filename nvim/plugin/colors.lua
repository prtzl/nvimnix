-- This shit has to be set so that the completion menu (possibly more) is colored
vim.cmd 'set termguicolors'

-- Color mode
vim.o.background = "dark"
vim.cmd("colorscheme base16-da-one-ocean")

local color_bg = require('base16-colorscheme').colors.base00

-- Overrides
-- Transparent complete
vim.api.nvim_set_hl(0, "CmpItemAbbr", { cternbg = None, bg = None })

-- More visible match and line highlights in Telescope preview
vim.api.nvim_set_hl(0, "TelescopePreviewMatch", { bg = "#ffaf5f", fg = "#000000", bold = true, })
vim.api.nvim_set_hl(0, "TelescopePreviewLine", { bg = "#44475a", bold = true, })
vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = color_bg, })
vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = color_bg, })


-- Telescope borders
vim.api.nvim_set_hl(0, "TelescopeBorder", { ctermbg = 220 })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { ctermbg = 220 })
