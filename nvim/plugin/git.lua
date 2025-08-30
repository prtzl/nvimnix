local map = require("utils").map

require('gitsigns').setup {
    signs                        = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '−' },
        topdelete    = { text = '‾' },
        changedelete = { text = '≃' },
        untracked    = { text = '┆' },
    },
    signs_staged                 = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '−' },
        topdelete    = { text = '‾' },
        changedelete = { text = '≃' },
        untracked    = { text = '┆' },
    },
    signs_staged_enable          = true,
    signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl                        = true,  -- Toggle with `:Gitsigns toggle_numhl`
    linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir                 = {
        follow_files = true
    },
    auto_attach                  = true,
    attach_to_untracked          = true,
    current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts      = {
        virt_text = true,
        virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
    },
    current_line_blame_formatter = '<author>, <author_time:%R>: <abbrev_sha>',
    sign_priority                = 6,
    update_debounce              = 100,
    status_formatter             = nil,   -- Use default
    max_file_length              = 40000, -- Disable if file is longer than this (in lines)
    preview_config               = {
        -- Options passed to nvim_open_win
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
    },
    on_attach                    = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map_local(mode, lhs, rhs, opts)
            opts = opts or {}
            opts.buffer = bufnr
            map(mode, lhs, rhs, opts)
        end

        map_local('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = 'Next Git hunk' })

        map_local('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = 'Previous Git hunk' })

        map_local('n', '<leader>gd', gs.diffthis, { desc = "Git diff current file" })
        map_local('n', '<leader>gs', gs.stage_hunk, { desc = "Git stage hunk" })
        map_local('n', '<leader>gu', gs.undo_stage_hunk, { desc = "Git undo stage hunk" })
        map_local('n', '<leader>gp', gs.preview_hunk, { desc = "Git preview hunk" })
    end,
}
