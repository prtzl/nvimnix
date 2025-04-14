-- This shit has to be set so that the completion menu (possibly more) is colored
vim.cmd 'set termguicolors'

-- Color mode
vim.o.background = "dark"

-- Overrides
vim.api.nvim_set_hl(0, "CmpItemAbbr", { cternbg = None, bg = None })

vim.cmd("colorscheme base16-da-one-ocean")
