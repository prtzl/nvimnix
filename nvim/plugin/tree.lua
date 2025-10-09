local nvimtree = require('nvim-tree')
local map = require('utils').map

nvimtree.setup {
    update_focused_file = {
        enable = true,
        update_cwd = false,
    },
    git = {
        enable = true,
    },
    view = {
        width = 30,
        adaptive_size = true,
    },
    filters = {
        enable = true,
        git_ignored = true,
        dotfiles = false,
        custom = {
            ".direnv",
            ".git",
            "result",
            "result-man",
        },
    },
    renderer = {
        icons = {
            glyphs = {
                default = "",
                symlink = "",
                folder = {
                    arrow_open = "",
                    arrow_closed = "",
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                    symlink = "",
                    symlink_open = "",
                },
                git = {
                    unstaged = "",
                    staged = "S",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "U",
                    deleted = "",
                    ignored = "◌",
                },
            },
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
            },
        },
    },
    diagnostics = {
        enable = true,
        show_on_dirs = true,
        icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
        },
    },
}

-- nvim tree view
map("n", "<C-t>", ":NvimTreeFindFile<CR>", { desc = "nvim-tree toggle" })
