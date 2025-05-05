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

-- Custom telescope searches
-- grep for word under cursor
map("n", "<leader>s",
    function()
        local word = vim.fn.expand("<cword>");
        require("telescope.builtin").live_grep({ default_text = word, })
    end)
-- Grep function call/declare/signature/assign fptr "<cword>(...)" for word under cursor
-- mostly just for C/C++ since lua can have functions as part of of a struct, like vim.g.myFunction = function()
-- BUT, lua LSP works and is nice. So use go-to-definition hah
map("n", "<leader>f",
    function()
        local word = vim.fn.expand("<cword>");
        -- INFO: this pattern also finds two-line function def/dec where return type is on separate line
        -- INFO: It can exclude them by modifying third or parameter to search for commented lines without anything in front, maybe
        local pattern = [[(\s?,?\w\s*=\s*|^\s+|.*[/\-#*]{1,2}\s*)]] .. word .. [[[\(.*\)]?]];
        require("telescope.builtin").live_grep({
            default_text = pattern,
        })
    end)
-- Grep function definition/declaration with two line type "[\w+\s+] <cword>(.*)" as well for the word under cursor
map("n", "<leader>F",
    function()
        local word = vim.fn.expand("<cword>");
        -- INFO: this pattern skips two-line function def/dec where return type is on separate line
        -- INFO: It can be made to include them by chaning the last + to *. This then also finds some commented function calls
        -- since they look like commented two line (line commented) function declarations/definitions
        local pattern = [[(^(\s*)[/\-#*]{1,2}\s*|^)(\w+\s+)+]] .. word .. [[\(.*\)\s*;*({?(.*)*}?)*]];
        require("telescope.builtin").live_grep({
            default_text = pattern,
            additional_args = function()
                return { "--pcre2" }
            end,
        })
    end)
-- Grep MACRO use signature "<#define/#if/...> <cword>" for word under cursor
map("n", "<leader>m",
    function()
        local word = vim.fn.expand("<cword>");
        local pattern = [[#\w+\s]] .. word;
        require("telescope.builtin").live_grep({
            default_text = pattern,
        })
    end)
-- Grep MACRO definition "#define <cword>" for word under cursor
map("n", "<leader>M",
    function()
        local word = vim.fn.expand("<cword>");
        local pattern = "#define " .. word;
        require("telescope.builtin").live_grep({
            default_text = pattern,
        })
    end)

-- Diagnostic
map("n", "<SPACE>e", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "<SPACE>q", vim.diagnostic.setloclist)

-- Spell toggle
map("n", "<F3>", function() vim.g.toggleSpell() end)
map("i", "<F3>", function() vim.g.toggleSpell() end)

-- Autoformat toggle
map("n", "<F4>", function() vim.g.toggleFormat(nil) end)
map("i", "<F4>", function() vim.g.toggleFormat(nil) end)

-- Set key mapping to toggle LSP on or off
map("n", "<F5>", function() vim.g.toggle_lsp() end)
map("i", "<F5>", function() vim.g.toggle_lsp() end)

-- Comments
map("n", "<C-/>", "gcc", { remap = true, })
map("v", "<C-/>", "gc", { remap = true, })
map("i", "<C-/>", "<ESC>gcc<RIGHT>i", { remap = true, })
-- Somehow the above version works outside tmux, but not in. And other way around ...
map("n", "<C-_>", "gcc", { remap = true, })
map("v", "<C-_>", "gc", { remap = true, })
map("i", "<C-_>", "<ESC>gcc<RIGHT>i", { remap = true, })

-- Git - lazygit
map("n", "<C-\\>", ":LazyGit<CR>")

-- nvim tree view
map("n", "<C-t>", ":NvimTreeFindFile<CR>")

-- nvim diagnostics
map("n", "<space>e", vim.diagnostic.open_float)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "[d", vim.diagnostic.goto_prev)
