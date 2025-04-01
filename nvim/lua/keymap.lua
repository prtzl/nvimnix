-- Keymaps
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts ~= nil then
        options = vim.tbl_extend("force", options, opts)
        vim.keymap.set(mode, lhs, rhs, options)
    else
        vim.keymap.set(mode, lhs, rhs)
    end
    -- vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Window movement in insert mode
map("i", "<c-w><left>", "<esc><right><c-w><left><ins>", nil)
map("i", "<c-w><right>", "<esc><right><c-w><right><ins>", nil)
map("i", "<c-w><up>", "<esc><right><c-w><up><ins>", nil)
map("i", "<c-w><down>", "<esc><right><c-w><down><ins>", nil)

map("n", "<s-up>", ":move-2<cr>", nil)
map("n", "<s-down>", ":move+1<cr>", nil)
map("i", "<s-up>", "<esc>:move-2<cr><ins><right>", nil)
map("i", "<s-down>", "<esc>:move+1<cr><ins><right>", nil)

-- Resizing windows
map("n", "<c-s-up>", ":resize +5<cr>", nil)
map("n", "<c-s-down>", ":resize -5<cr>", nil)
map("n", "<c-s-left>", ":vertical resize -5<cr>", nil)
map("n", "<c-s-right>", ":vertical resize +5<cr>", nil)

-- backspace delete
map("!", "<c-bs>", "<c-w>", nil)
map("!", "<c-h>", "<c-w>", nil)

-- move to the end of line while in insert mode
map("i", "<c-]>", "<esc>A", nil)

-- Move back and forth in buffers
-- Note so self: <c-[> is maped as if <Esc> is pressed - higher power control, abandon hope
map("n", "[[", ":bnext<cr>", nil)
map("n", "]]", ":bprev<cr>", nil)

-- LSP
map("n", "gd", vim.lsp.buf.declaration, nil)
map("n", "gD", vim.lsp.buf.definition, nil)
map("n", "gh", vim.lsp.buf.hover, nil)
map("n", "gi", vim.lsp.buf.implementation, nil)
map("n", "gr", vim.lsp.buf.references, nil)
map("n", "<f2>", vim.lsp.buf.rename, { silent = false })
map("n", "<f8>", vim.lsp.buf.code_action, { silent = false })

-- Snippets - move between fields
map("i", "<c-j>", "<cmd>lua require(luasnip).jump(1)<CR>", nil)
map("s", "<c-j>", "<cmd>lua require(luasnip).jump(1)<CR>", nil)
map("i", "<c-k>", "<cmd>lua require(luasnip).jump(-1)<CR>", nil)
map("s", "<c-k>", "<cmd>lua require(luasnip).jump(-1)<CR>", nil)

-- FZF
map("n", "<c-p>", require("telescope.builtin").find_files, nil)
map("n", "<c-a>", function()
    require("telescope.builtin").find_files { no_ignore = true, no_ignore_parent = true, hidden = true }
end, nil)
map("n", "<c-g>", require("telescope.builtin").live_grep, nil)
map("n", "<c-b>", require("telescope.builtin").buffers, nil)
map("n", "<c-f>", require("telescope.builtin").current_buffer_fuzzy_find, nil)

-- Diagnostic
map("n", "<space>e", vim.diagnostic.open_float, nil)
map("n", "[d", vim.diagnostic.goto_prev, nil)
map("n", "]d", vim.diagnostic.goto_next, nil)
map("n", "<space>q", vim.diagnostic.setloclist, nil)

-- Spell toggle
map("n", "<f3>", function() vim.g.toggleSpell() end, nil)
map("i", "<f3>", function() vim.g.toggleSpell() end, nil)

-- Autoformat toggle
map("n", "<f4>", function() vim.g.toggleFormat() end, nil)
map("i", "<f4>", function() vim.g.toggleFormat() end, nil)

-- Set key mapping to toggle LSP on or off
map("n", "<f5>", function() vim.g.toggle_lsp() end, nil)
map("i", "<f5>", function() vim.g.toggle_lsp() end, nil)

-- Comments
map("n", "<c-_>", "gcc", { noremap = false })
map("v", "<c-_>", "gcc", { noremap = false })
map("i", "<c-_>", "<esc>gcc<right>i", { noremap = false })

-- Git - lazygit
map("n", "<c-\\>", ":LazyGit<cr>", nil)

-- nvim tree view
map("n", "<c-t>", ":NvimTreeToggle<cr>", nil)
