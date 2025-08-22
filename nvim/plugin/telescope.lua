local telescope = require 'telescope'
local actions = require 'telescope.actions'
local builtin = require 'telescope.builtin'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local conf = require 'telescope.config'.values

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

-- Actually use the extension for performance gainz (havent's noticed any issues until now tho ...)
require('telescope').load_extension('fzf')

-- From TJ DevRies: live grep, but separating pattern with double space makes rg match file as well with second argument
local live_multigrep = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd or vim.uv.cwd()

    local finder = finders.new_async_job {
        command_generator = function(prompt)
            if not prompt or prompt == "" then
                return nil
            end

            local pieces = vim.split(prompt, "  ")
            local args = { "rg" }
            if pieces[1] then
                table.insert(args, "-e")
                table.insert(args, pieces[1])
            end

            if pieces[2] then
                table.insert(args, "-g")
                table.insert(args, pieces[2])
            end

            return vim.iter({
                args,
                { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
            }):flatten():totable()
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
    }

    pickers.new(opts, {
        debounce = 100,
        prompt_title = "Multi Grep",
        finder = finder,
        previewer = conf.grep_previewer(opts),
        sorter = require("telescope.sorters").empty(),
    }):find()
end

-- Removes douplicate/overlapping directories
local function dedup_and_prune_dirs(dirs)
    -- normalize all dirs to absolute real paths
    local norm = {}
    for _, d in ipairs(dirs) do
        table.insert(norm, vim.fn.fnamemodify(d, ":p"))
    end

    -- sort by length (shortest first, so parents come before children)
    table.sort(norm, function(a, b) return #a < #b end)

    local result = {}
    for _, d in ipairs(norm) do
        local is_sub = false
        for _, kept in ipairs(result) do
            if string.sub(d, 1, #kept) == kept then
                -- d is inside kept, so skip
                is_sub = true
                break
            end
        end
        if not is_sub then
            table.insert(result, d)
        end
    end

    return result
end

-- Helper to get project-specific search dirs from direnv
local function project_search_dirs()
    local env_val = os.getenv("NVIM_SEARCH_DIRS")
    local dirs = { vim.fn.getcwd() } -- always include cwd

    if env_val and env_val ~= "" then
        for dir in string.gmatch(env_val, "%S+") do
            local abs_dir = vim.fn.fnamemodify(dir, ":p")
            if vim.fn.isdirectory(abs_dir) == 1 then
                table.insert(dirs, abs_dir)
            else
                print("Warning: directory does not exist: " .. abs_dir)
            end
        end
    end

    return dedup_and_prune_dirs(dirs)
end

-- My default live grep - separate search term by two spaces and the second argument is now file type pattern
vim.keymap.set("n", "<leader>g", function()
    live_multigrep({
        search_dirs = project_search_dirs(),
        cwd = vim.fn.getcwd(),
    })
end, { desc = "Live multigrep - second option is file filter (project dirs from NVIM_SEARCH_DIRS)" })

-- Keymaps for project-specific searches
vim.keymap.set("n", "<leader>p", function()
    builtin.find_files({
        search_dirs = project_search_dirs(),
        cwd = vim.fn.getcwd(),
    })
end, { desc = "Find files (project dirs from NVIM_SEARCH_DIRS)" })
