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
    word_diff = false,
    watch_gitdir = {
        -- interval =1000,     -- Check for git changes every 1 second
        follow_files = true, -- Follow files in git submodules
    },
    on_attach = function(bufnr)
        -- Key mappings for GitSigns actions
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gd', ':Gitsigns diffthis<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gs', ':Gitsigns stage_hunk<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gt', ':Gitsigns toggle_signs<CR>',
            { noremap = true, silent = true })
    end,
}
