-- Base gui
vim.g.mapleader = " "
vim.g.maplocalleader = " " -- Set local leader key (NEW)
vim.opt.cursorline = true
-- vim.opt.guicursor = ""     -- keep it blocky, my man
vim.opt.laststatus = 2
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.ruler = true
vim.opt.scrolloff = 10
vim.opt.showcmd = true
vim.opt.showmatch = true
-- vim.opt.showmode = true
vim.opt.sidescrolloff = 8
vim.opt.wildmenu = true
vim.opt.wildmode = 'list:full'
vim.opt.shortmess:append("c")

-- File handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.undofile = true
vim.opt.autoread = true
vim.opt.autowrite = false
vim.opt.autochdir = false

-- History of commands (1000 commands)
vim.opt.history = 1000

-- Clipboard
vim.opt.clipboard:append { 'unnamedplus' }

-- Format
vim.opt.encoding = 'utf8'
vim.opt.fileformats = { 'unix', 'dos', 'mac' }

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Tab
vim.opt.tabstop = 2
vim.opt.softtabstop = 0 -- follows tabstop
vim.opt.shiftwidth = 0  -- follows tabstop
vim.opt.shiftround = true
vim.opt.expandtab = true

-- Don't wrap
vim.opt.wrap = false

-- Autoindent
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Window split
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Timeout
vim.opt.ttimeoutlen = 0
vim.opt.timeoutlen = 1000

-- Enable backspace on characters
vim.opt.backspace = { 'indent', 'eol', 'start' }

-- Grep
if vim.fn.executable("rg") then
  vim.opt.grepprg = "rg --vimgrep --no-heading"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- Set floating window dimensions
vim.opt.pumheight = 10 -- cap height for popup windows at 10 lines

-- Improved cpp
vim.g.cpp_class_decl_highlight = 1
vim.g.cpp_class_scope_highlight = 1
vim.g.cpp_member_variable_highlight = 1

-- Prevent strange file save behaviour.
-- https://github.com/srid/emanote/issues/180
vim.opt.backupcopy = 'yes'

vim.opt.cmdheight = 1                             -- Command line height
vim.opt.completeopt = "menuone,noinsert,noselect" -- Completion options
vim.opt.concealcursor = ""                        -- Don't hide cursor line markup
vim.opt.conceallevel = 0                          -- Don't hide markup
vim.opt.errorbells = false                        -- No error bells
vim.opt.fillchars = { eob = " " }                 -- Hide ~ on empty lines
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"   -- Use treesitter for folding
vim.opt.foldlevel = 99                            -- Start with all folds open
vim.opt.foldmethod = "expr"                       -- Use expression for folding
vim.opt.guicursor =
"n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"
vim.opt.hidden = true           -- Allow hidden buffers
vim.opt.iskeyword:append("-")   -- Treat dash as part of word
vim.opt.lazyredraw = true       -- Don't redraw during macros
vim.opt.matchtime = 2           -- How long to show matching bracket
vim.opt.modifiable = true       -- Allow buffer modifications
vim.opt.path:append("**")       -- include subdirectories in search
vim.opt.pumblend = 10           -- Popup menu transparency
vim.opt.pumheight = 10          -- Popup menu height
vim.opt.pumheight = 10          -- cap height for popup windows at 10 lines
vim.opt.selection = "exclusive" -- Selection behavior
vim.opt.showmode = false        -- Don't show mode in command line
vim.opt.signcolumn = "yes"      -- Always show sign column
vim.opt.synmaxcol = 300         -- Syntax highlighting limit
vim.opt.updatetime = 300        -- Faster completion
vim.opt.winblend = 0            -- Floating window transparency
