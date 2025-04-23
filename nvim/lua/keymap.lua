-- Keymaps
local function map(mode, lhs, rhs, opts)
    local options = { remap = false, silent = true }
    if opts ~= nil then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Window movement in insert mode
map("i", "<C-w><LEFT>", "<ESC><right><c-w><left><ins>")
map("i", "<C-w><RIGHT>", "<ESC><right><c-w><right><ins>")
map("i", "<C-w><up>", "<ESC><RIGHT><c-w><up><ins>")
map("i", "<C-w><down>", "<ESC><RIGHT><c-w><down><ins>")

map("n", "<s-up>", ":move-2<CR>")
map("n", "<s-down>", ":move+1<CR>")
map("i", "<s-up>", "<ESC>:move-2<CR><ins><RIGHT>")
map("i", "<s-down>", "<ESC>:move+1<CR><ins><RIGHT>")
map("v", "<s-up>", ":move '<-2<CR>gv=gv")
map("v", "<s-down>", ":move '>+1<CR>gv=gv")

-- Resizing windows
map("n", "<C-s-up>", ":resize +5<CR>")
map("n", "<C-s-down>", ":resize -5<CR>")
map("n", "<C-s-LEFT>", ":vertical resize -5<CR>")
map("n", "<C-s-RIGHT>", ":vertical resize +5<CR>")

-- backSPACE delete
map("!", "<C-bs>", "<c-w>")
map("!", "<C-h>", "<c-w>")

-- move to the end of line while in insert mode
map("i", "<C-]>", "<ESC>A")

-- Move back and forth in buffers
-- Note so self: <C-[> is maped as if <ESC> is pressed - higher power control, abandon hope
map("n", "]]", ":bnext<CR>")
map("n", "[[", ":bprev<CR>")

-- LSP
map("n", "gd", vim.lsp.buf.declaration)
map("n", "gD", vim.lsp.buf.definition)
map("n", "gh", vim.lsp.buf.hover)
map("n", "gi", vim.lsp.buf.implementation)
map("n", "gr", vim.lsp.buf.references)
map("n", "<F2>", vim.lsp.buf.rename, { silent = false })
map("n", "<F8>", vim.lsp.buf.code_action, { silent = false })

-- Snippets - move between fields
map("i", "<C-j>", "<cmd>lua require(luasnip).jump(1)<CR>")
map("s", "<C-j>", "<cmd>lua require(luasnip).jump(1)<CR>")
map("i", "<C-k>", "<cmd>lua require(luasnip).jump(-1)<CR>")
map("s", "<C-k>", "<cmd>lua require(luasnip).jump(-1)<CR>")

-- FZF
map("n", "<C-p>", require("telescope.builtin").find_files)
map("n", "<C-a>", function()
    require("telescope.builtin").find_files { no_ignore = true, no_ignore_parent = true, hidden = true }
end)
map("n", "<C-g>", require("telescope.builtin").live_grep)
map("n", "<C-b>", require("telescope.builtin").buffers)
map("n", "<C-f>", require("telescope.builtin").current_buffer_fuzzy_find)
map("n", "<C-s>", function() require("telescope.builtin").live_grep({ default_text = vim.fn.expand("<cword>") }) end)

-- Diagnostic
map("n", "<SPACE>e", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "<SPACE>q", vim.diagnostic.setloclist)

-- Spell toggle
map("n", "<F3>", function() vim.g.toggleSpell() end)
map("i", "<F3>", function() vim.g.toggleSpell() end)

-- Autoformat toggle
map("n", "<F4>", function() vim.g.toggleFormat() end)
map("i", "<F4>", function() vim.g.toggleFormat() end)

-- Set key mapping to toggle LSP on or off
map("n", "<F5>", function() vim.g.toggle_lsp() end)
map("i", "<F5>", function() vim.g.toggle_lsp() end)

-- Comments
map("n", "<C-_>", "gcc", { remap = true, })
map("v", "<C-_>", "gcc", { remap = true, })
map("i", "<C-_>", "<ESC>gcc<RIGHT>i", { remap = true, })

-- Git - lazygit
map("n", "<C-\\>", ":LazyGit<CR>")

-- nvim tree view
map("n", "<C-t>", ":NvimTreeFindFile<CR>")
