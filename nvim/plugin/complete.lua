-- Help: https://github.com/hrsh7th/nvim-cmp/blob/main/doc/cmp.txt
local cmp = require 'cmp'
local select_opts = { behavior = cmp.SelectBehavior.Select }
local luasnip = require 'luasnip'
local lspkind = require 'lspkind'
local map = require('utils').map

local has_words_before = function()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and not vim.api.nvim_get_current_line():sub(col, col):match("%s")
end

cmp.setup({
    enabled = function()
        -- Disable cmp in prompt buffers (default behaviour, but I overrided it :|)
        if vim.bo.buftype == 'prompt' then
            return false
        end

        -- Disable cmp on too big files - laggy
        if vim.api.nvim_buf_line_count(0) > 5000 then
            return false
        end

        -- disable completion in comments
        local context = require 'cmp.config.context'
        -- keep command mode completion enabled when cursor is in a comment
        if vim.api.nvim_get_mode().mode ~= 'c' then
            return not context.in_treesitter_capture("comment")
                and not context.in_syntax_group("Comment")
        end

        return true
    end,

    -- Experiment: disable autocomplete, so it has to be triggered with <c-k> (toggle) - like VSCode <c-space>
    completion = {
        autocomplete = { -- list of events when autocomplete triggers automatically
            cmp.TriggerEvent.TextChanged,
            cmp.TriggerEvent.InsertEnter,
        },
    },

    -- Enable LSP snippets
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = ({
        -- My tab implementation differs from up/down arrows
        -- Here the item is previewed whereas up/down just selects
        -- Same with luasnip
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
        ['<C-n>'] = cmp.config.disable,
        ['<C-p>'] = cmp.config.disable,
        ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
        ['<Down>'] = cmp.mapping.select_next_item(select_opts),
        ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
        -- ['<C-k>'] = cmp.mapping.complete(),
        ["<C-k>"] = cmp.mapping({
            i = function()
                if cmp.visible() then
                    cmp.abort()
                else
                    cmp.complete()
                end
            end,
            c = function()
                if cmp.visible() then
                    cmp.close()
                else
                    cmp.complete()
                end
            end,
        }),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        })
    }),
    -- Installed sources
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp',    keyword_length = 1 },
        { name = 'luasnip',     keyword_length = 2 },
        { name = 'buffer',      keyword_length = 3 },
        { name = 'spell',       option = { keep_all_entries = false }, },
        { name = 'emoji' },
        { name = 'buffer-lines' },
        { name = 'treesitter' },
        { name = 'omni' },
        { name = 'nvim_lua' },
    },
    -- Show: abbreviation, symbol + kind, menu
    -- In other words: short completion stirng, completion type icon and stirng, source of completion
    formatting = {
        fields = { "abbr", "kind", "menu" },
        format = lspkind.cmp_format {
            mode = "text_symbol",
            maxwidth = 70,
            before = function(entry, vim_item)
                local shorten_abbr = string.sub(vim_item.abbr, 1, 30)
                if shorten_abbr ~= vim_item.abbr then vim_item.abbr = shorten_abbr .. "..." end
                vim_item.kind = string.format("%s %s", lspkind.symbol_map[vim_item.kind], vim_item.kind)
                vim_item.menu = ({
                    buffer = "[BUF]",
                    nvim_lsp = "[LSP]",
                    luasnip = "[SNP]",
                    nvim_lua = "[API]",
                    latex_symbols = "[LTX]",
                    path = "[PTH]",
                    spell = "[SPL]",
                    omni = "[OMN]",
                    treesitter = "[TRS]"
                })[entry.source.name] or "???"
                return vim_item
            end,
        },
        expendable_indicator = true,
    },
    window = {
        documentation = cmp.config.window.bordered(),
        completion = cmp.config.window.bordered()
    },
    experimental = {
        ghost_text = false,
    },
    view = {
        entries = {
            { name = 'custom', selection_order = 'near_cursor' }
        }
    }
})

-- Enable `buffer` and `buffer-lines` for `/` and `?` in the command-line
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        {
            name = "buffer",
            option = { keyword_pattern = [[\k\+]] }
        },
        { name = "buffer-lines" }
    }
})

cmp.setup.cmdline({ ':' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "cmdline" }
    }, {
        { name = 'path' }
    }),
    view = {
        entries = {
            { name = 'wildmenu', separator = '|' }
        }
    }
})

local border = {
    { "╭", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╮", "FloatBorder" },
    { "│", "FloatBorder" },
    { "╯", "FloatBorder" },
    { "─", "FloatBorder" },
    { "╰", "FloatBorder" },
    { "│", "FloatBorder" },
}

-- To instead override globally
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Add border around LspInfo
require('lspconfig.ui.windows').default_options.border = 'single'

-- LSP servers
-- This shit is added to every server and it made it so
-- when you accept a suggestion like a function, it fills the signature and enters - finally
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- C/C++
vim.lsp.enable('clangd', false)
vim.lsp.config('clangd',
    {
        cmd = {
            'clangd',
            '--all-scopes-completion',
            '--background-index',
            '--clang-tidy',
            '--compile-commands-dir=build',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--header-insertion-decorators',
            '--header-insertion=never',
        },
        root_markers = { '.clangd', 'compile_commands.json' },
        filetypes = { "c", "cpp", "h", "hpp" },
        -- root_dir = root_dir,
    })

local clangdLspState = false
map('n', '<F11>', function()
        local ft = vim.bo.filetype
        if vim.tbl_contains({ "c", "cpp", "h", "hpp" }, ft) then
            if clangdLspState == false then
                clangdLspState = true
                vim.lsp.enable('clangd')
                vim.notify("Clangd enabled")
            else
                clangdLspState = false
                vim.lsp.disable('clangd')
                vim.notify("Clangd disabled")
            end
            vim.notify("clangd started for " .. ft)
        else
            vim.notify("clangd not started: unsupported filetype " .. ft, vim.log.levels.WARN)
        end
    end,
    { desc = "Toggle LSP for Clangd on/off (default off)" })

-- Nix LSP
vim.lsp.enable('nil_ls')
vim.lsp.config('nil_ls',
    {
        autostart = true,
        capabilities = capabilities,
        filetypes = { 'nix' },
        settings = {
            ['nil'] = {
                formatting = {
                    command = { "nixfmt" },
                }
            }

        }
    })

-- latex lsp
vim.lsp.enable('texlab')
vim.lsp.config('texlab',
    {
        autostart = true,
        capabilities = capabilities,
    })

-- Python LSP
vim.lsp.enable('pylsp')
vim.lsp.config('pylsp',
    {
        autostart = true,
        capabilities = capabilities,
    })

-- lua LSP
vim.lsp.enable('lua_ls')
vim.lsp.config('lua_ls',
    {
        autostart = true,
        capabilities = capabilities,
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { 'vim' }, -- Recognize 'vim' as a global variable
                },
                workspace = {
                    library = {
                        vim.fn.stdpath("config") .. "/lua",  -- Only your config files
                        vim.fn.stdpath("data") .. "/plugin", -- If using lazy.nvim, include its plugins
                    },
                    checkThirdParty = false,                 -- Prevents unnecessary warnings
                    maxPreload = 1000,                       -- Limits the number of preloaded files
                    preloadFileSize = 200,                   -- Limits the size of preloaded files (in KB)
                },
                telemetry = {
                    enable = false, -- Disable telemetry for extra speed
                },
            },
        },
    })

-- lsp signature - function signature
require "lsp_signature".setup({
    hint_enable = false,
    toggle_key = '<C-s>',          -- toggle signalture
    select_signature_key = '<C-l>' -- switch signatures
})


-- Keybingins
-- Only declare them when attached to the buffer (if any are used globaly, I guess they get overriden
vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function()
        -- Displays hover information about the symbol under the cursor
        map('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<cr>')

        -- Jump to the definition
        map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

        -- Jump to declaration
        map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

        -- Lists all the implementations for the symbol under the cursor
        map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

        -- Jumps to the definition of the type symbol
        map('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

        -- Lists all the references
        map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

        -- Displays a function's signature information
        map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

        -- Renames all references to the symbol under the cursor
        map('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

        -- Selects a code action available at the current cursor position
        map('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')

        -- Show diagnostics in a floating window
        map('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

        -- Move to the previous diagnostic
        map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

        -- Move to the next diagnostic
        map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
    end
})
