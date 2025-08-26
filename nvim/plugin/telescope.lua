local telescope = require 'telescope'
local actions = require 'telescope.actions'
local builtin = require 'telescope.builtin'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local conf = require 'telescope.config'.values
local sorters = require "telescope.sorters"
local flatten = vim.tbl_flatten

local map = require('utils').map

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

--------------------------------------------------------------------------------

-- From TJ DevRies: live grep, but separating pattern with double space makes rg match file as well with second argument
local live_multigrep = function(opts)
    opts = opts or {}
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
    opts.shortcuts = opts.shortcuts
        or {
            ["l"] = "*.lua",
            ["v"] = "*.vim",
            ["n"] = "*.{vim,lua}",
            ["c"] = "*.{c,cpp}",
            ["h"] = "*.{h,hpp}",
            ["r"] = "*.rs",
            ["g"] = "*.go",
        }
    opts.pattern = opts.pattern or "%s"

    local custom_grep = finders.new_async_job {
        command_generator = function(prompt)
            if not prompt or prompt == "" then
                return nil
            end

            local prompt_split = vim.split(prompt, "  ")

            local args = { "rg" }
            if prompt_split[1] then
                table.insert(args, "-e")
                table.insert(args, prompt_split[1])
            end

            if prompt_split[2] then
                table.insert(args, "-g")

                local pattern
                if opts.shortcuts[prompt_split[2]] then
                    pattern = opts.shortcuts[prompt_split[2]]
                else
                    -- Automatically interpret as file extension if it doesn't already have a wildcard
                    if not prompt_split[2]:match("[*{}]") then
                        pattern = "*." .. prompt_split[2]
                    else
                        pattern = prompt_split[2]
                    end
                end

                table.insert(args, string.format(opts.pattern, pattern))
            end

            if opts.search_dirs then
                vim.list_extend(args, opts.search_dirs)
            end

            return flatten {
                args,
                { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
            }
        end,
        entry_maker = make_entry.gen_from_vimgrep(opts),
        cwd = opts.cwd,
    }

    local sorter = sorters.Sorter:new {
        scoring_function = function()
            return 1
        end,
        highlighter = function(_, prompt, display)
            local fzy = opts.fzy_mod or require "telescope.algos.fzy"
            local pieces = vim.split(prompt, "  ")
            return fzy.positions(pieces[1], display)
        end,
    }

    pickers
        .new(opts, {
            debounce = 100,
            prompt_title = "Live Grep (with shortcuts)",
            finder = custom_grep,
            previewer = conf.grep_previewer(opts),
            sorter = sorter,
        })
        :find()
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
map("n", "<leader>pg", function()
        live_multigrep({
            cwd = vim.fn.getcwd(),
            search_dirs = project_search_dirs(),
        })
    end,
    { desc = "Live multigrep - double space separates file type (Telescope)" })

-- Keymaps for project-specific searches
map("n", "<leader>pf", function()
        builtin.find_files({
            cwd = vim.fn.getcwd(),
            search_dirs = project_search_dirs(),
        })
    end,
    { desc = "Find files (Telescope)" })

-- Find all files
map("n", "<leader>pa", function()
        require("telescope.builtin").find_files({
            cwd = vim.fn.getcwd(),
            hidden = true,
            no_ignore = true,
            no_ignore_parent = true,
            search_dirs = project_search_dirs(),
        })
    end,
    { desc = "Find ALL files using Telescope" })

-- Find buffers
map("n", "<leader>pb", require("telescope.builtin").buffers,
    { desc = "Find buffers (Telescope)" })

-- Local file search
map("n", "<leader>pl", require("telescope.builtin").current_buffer_fuzzy_find,
    { desc = "Local buffer fuzzy find (Telescope)" })

--------------------------------------------------------------------------------
-- Custom telescope searches
-- grep for word under cursor
map("n", "<LEADER>ps",
    function()
        local word = vim.fn.expand("<cword>");
        require("telescope.builtin").live_grep({
            cwd = vim.fn.getcwd(),
            default_text = word,
            search_dirs = project_search_dirs(),
        })
    end)

-- Grep function call/declare/signature/assign fptr "<cword>(...)" for word under cursor
-- mostly just for C/C++ since lua can have functions as part of of a struct, like vim.g.myFunction = function()
-- BUT, lua LSP works and is nice. So use go-to-definition hah
map("n", "<LEADER>pd",
    function()
        local word = vim.fn.expand("<cword>");
        -- INFO: this pattern also finds two-line function def/dec where return type is on separate line
        -- INFO: It can exclude them by modifying third or parameter to search for commented lines without anything in front, maybe
        -- local pattern = [[(\s?,?\w\s*=\s*|^\s+|.*[/\-#*]{1,2}\s*)]] .. word .. [[[\(.*\)]?]];
        local pattern = word .. [[\s*\(]]
        require("telescope.builtin").live_grep({
            cwd = vim.fn.getcwd(),
            default_text = pattern,
            search_dirs = project_search_dirs(),
        })
    end)

-- Grep function definition/declaration with two line type "[\w+\s+] <cword>(.*)" as well for the word under cursor
map("n", "<LEADER>pD",
    function()
        local word = vim.fn.expand("<cword>");
        -- INFO: this pattern skips two-line function def/dec where return type is on separate line
        -- INFO: It can be made to include them by chaning the last + to *. This then also finds some commented function calls
        -- since they look like commented two line (line commented) function declarations/definitions
        local pattern = [[(((^(\s*)[/\-#*]{1,2}\s*|^)(\w+\s+)+)|^)]] .. word .. [[\(.*\)\s*;*({?(.*)*}?)*]];
        require("telescope.builtin").live_grep({
            cwd = vim.fn.getcwd(),
            default_text = pattern,
            additional_args = function()
                return { "-z", "--pcre2" }
            end,
            search_dirs = project_search_dirs(),
        })
    end)

-- Grep MACRO use signature "<#define/#if/...> <cword>" for word under cursor
map("n", "<LEADER>pm",
    function()
        local word = vim.fn.expand("<cword>");
        local pattern = [[#\w+\s]] .. word;
        require("telescope.builtin").live_grep({
            cwd = vim.fn.getcwd(),
            default_text = pattern,
            search_dirs = project_search_dirs(),
        })
    end)

-- Grep MACRO definition "#define <cword>" for word under cursor
map("n", "<LEADER>pM",
    function()
        local word = vim.fn.expand("<cword>");
        local pattern = "#define " .. word;
        require("telescope.builtin").live_grep({
            cwd = vim.fn.getcwd(),
            default_text = pattern,
            search_dirs = project_search_dirs(),
        })
    end)
