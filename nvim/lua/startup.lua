-- Load project-local config by searching upward for '.nvim.lua'
local loaded_project_configs = {}

local function load_project_config()
    local dir = vim.fn.getcwd() -- current working directory
    local home = vim.loop.os_homedir()

    while dir and dir ~= "/" and dir ~= home do
        local config_path = dir .. "/.nvim.lua"

        if vim.fn.filereadable(config_path) == 1 then
            if not loaded_project_configs[config_path] then
                loaded_project_configs[config_path] = true
                vim.cmd("luafile " .. config_path)
                vim.notify("[project-config] Loaded " .. config_path, vim.log.levels.INFO)
            end
            return
        end

        -- go up one directory
        dir = vim.fn.fnamemodify(dir, ":h")
    end
end

-- Load on startup
load_project_config()

-- Load whenever cwd changes
vim.api.nvim_create_autocmd("DirChanged", {
    callback = load_project_config,
})
