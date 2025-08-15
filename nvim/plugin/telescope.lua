local telescope = require 'telescope'
local actions = require 'telescope.actions'
local builtin = require 'telescope.builtin'

-- Helper to get project-specific search dirs from direnv
local function project_search_dirs()
    local env_val = os.getenv("NVIM_SEARCH_DIRS")
    if not env_val or env_val == "" then
        return { vim.fn.getcwd() }
    end

    local dirs = {}
    for dir in string.gmatch(env_val, "%S+") do
        -- Make fully absolute path
        local abs_dir = vim.fn.fnamemodify(dir, ":p")
        if vim.fn.isdirectory(abs_dir) == 1 then
            table.insert(dirs, abs_dir)
        else
            print("Warning: directory does not exist: " .. abs_dir)
        end
    end
    return dirs
end

telescope.setup {
    defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
            width = 0.99,
            prompt_position = 'top',
            preview_width = 0.5,
            horizontal = {
                wrap = true,
            },
        },
        sorting_strategy = 'ascending',
        border = true,
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<c-u>"] = false,
            }
        },
        path_display = { "truncate" },
        dynamic_preview_title = true,
    },
}

-- Keymaps for project-specific searches
vim.keymap.set("n", "<leader>pf", function()
    builtin.find_files({
        search_dirs = project_search_dirs(),
        hidden = true,
    })
end, { desc = "Find files (project dirs from NVIM_SEARCH_DIRS)" })

vim.keymap.set("n", "<leader>pg", function()
    builtin.live_grep({
        search_dirs = project_search_dirs(),
    })
end, { desc = "Live grep (project dirs from NVIM_SEARCH_DIRS)" })
