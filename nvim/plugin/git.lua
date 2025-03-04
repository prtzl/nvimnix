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

-- Configure gitsigns with updated highlight references
require 'gitsigns'.setup {
  signs = {
    add          = { text = '+', },
    change       = { text = '~', },
    delete       = { text = '−', },
    topdelete    = { text = '‾', },
    changedelete = { text = '≃', },
  },
  numhl = true,
  linehl = false,
  word_diff = true,
  watch_gitdir = {
    interval = 1000, -- Check for git changes every 1 second
    follow_files = true, -- Follow files in git submodules
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    -- Key mappings for GitSigns actions
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gd', ':Gitsigns diffthis<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gs', ':Gitsigns stage_hunk<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gt', ':Gitsigns toggle_signs<CR>', { noremap = true, silent = true })
  end,
}

