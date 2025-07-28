local npairs = require("nvim-autopairs")

npairs.setup {
    check_ts = true,
    ts_config = {
        lua = { "strings", "source" },
        java = false,
    },
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
    fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        before_key = 'h',
        after_key = 'l',
        cursor_pos_before = true,
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        manual_position = true,
        highlight = 'Search',
        highlight_grey = 'Comment'
    },
    enable_check_bracket_line = false,
    ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
}

-- Hook up autopairs to cmp - when you select, it will put braces around (functions, if, for, etc.)
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
