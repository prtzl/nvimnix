-- Enable treesitter: format and color all the source files!
require 'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
        disable = function(lang, bufnr) -- Disable in large buffers
            return vim.api.nvim_buf_line_count(bufnr) > 5000
        end,
        additional_vim_regex_highlighting = false,
    },

    -- using rainbow-delimiters-nvim instead
    rainbow = {
        enable = false,
    },

    -- Add parser install dir for "external (not nix, oops)" parsers, experimental, etc.
    parser_install_dir = vim.fn.stdpath("data") .. "/site",

    -- Use autopairs-nvim plugin
    autopairs = {
        enable = false,
    },

    indent = {
        enable = true,
    },
}

-- Manualy add epics nvim plugin - just loads up epics treesitter modules at runtime
require("epics").setup {}
