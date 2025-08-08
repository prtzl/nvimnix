require('gitsigns').setup {
    signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '−' },
        topdelete    = { text = '‾' },
        changedelete = { text = '≃' },
    },
    numhl = true,
    linehl = false,
    word_diff = false,
    watch_gitdir = {
        follow_files = true,
    },
    on_attach = function(bufnr)
        print("✅ Gitsigns attached to buffer " .. bufnr) -- debug print
        local gs = package.loaded.gitsigns

        local function map(mode, lhs, rhs, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
        end

        map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = 'Next Git hunk' })

        map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = 'Previous Git hunk' })

        -- Optional: Other Git hunk actions
        map('n', '<leader>gd', gs.diffthis, { desc = "Git diff current file" })
        map('n', '<leader>gs', gs.stage_hunk, { desc = "Git stage hunk" })
        map('n', '<leader>gu', gs.undo_stage_hunk, { desc = "Git undo stage hunk" })
        map('n', '<leader>gp', gs.preview_hunk, { desc = "Git preview hunk" })
    end,
}
