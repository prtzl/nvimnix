local map = require('utils').map

-- Window movement in insert mode
map("i", "<C-w><LEFT>", "<ESC><right><c-w><left><ins>")
map("i", "<C-w><RIGHT>", "<ESC><right><c-w><right><ins>")
map("i", "<C-w><up>", "<ESC><RIGHT><c-w><up><ins>")
map("i", "<C-w><down>", "<ESC><RIGHT><c-w><down><ins>")

-- Moving line(s)
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

-- Sort selected lines
map("v", "<LEADER>ts", ":sort<CR>")

-------------------------------------------------------------------------------
-- PLUGINS and PLUGIN-RELATED actions
-- Plugins that don't have or need local file (config) can have their keymaps here (or vim plugins)

-- Snippets - move between fields
map("i", "<C-j>", "<cmd>lua require(luasnip).jump(1)<CR>")
map("s", "<C-j>", "<cmd>lua require(luasnip).jump(1)<CR>")
map("i", "<C-k>", "<cmd>lua require(luasnip).jump(-1)<CR>")
map("s", "<C-k>", "<cmd>lua require(luasnip).jump(-1)<CR>")

-- comment-nvim (toggle line/block comment based on treesitter
map("n", "<C-/>", "gcc", { remap = true, })
map("v", "<C-/>", "gc", { remap = true, })
map("i", "<C-/>", "<ESC>gcc<RIGHT>i", { remap = true, })
-- Somehow the above version works outside tmux, but not in. And other way around ...
map("n", "<C-_>", "gcc", { remap = true, })
map("v", "<C-_>", "gc", { remap = true, })
map("i", "<C-_>", "<ESC>gcc<RIGHT>i", { remap = true, })

-- Lazygit (my "gui" git)
map("n", "<C-\\>", ":LazyGit<CR>")

-- vim-asterix - enhances * and # so that it DOES NOT jump to "next/previous"
map("n", "*", "<PLUG>(asterisk-z*)")
map("n", "#", "<PLUG>(asterisk-z#)")
map("n", "g*", "<PLUG>(asterisk-gz*)")
map("n", "g#", "<PLUG>(asterisk-gz#)")
