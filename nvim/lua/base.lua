local map = require('utils').map

-- Base gui
vim.g.mapleader = " "
vim.opt.cursorline = true
vim.opt.guicursor = "" -- keep it blocky, my man
vim.opt.laststatus = 2
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = true
vim.opt.scrolloff = 10
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.showmode = true
vim.opt.sidescrolloff = 10
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
vim.opt.tabstop = 4
vim.opt.softtabstop = 0 -- follows tabstop
vim.opt.shiftwidth = 0  -- follows tabstop
vim.opt.shiftround = true
vim.opt.expandtab = true

-- Don't wrap
vim.opt.wrap = false

-- Autoindent
vim.opt.autoindent = true
vim.opt.smartindent = false -- use treesitter

-- Window split
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Timeout
vim.opt.ttimeoutlen = 20
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
