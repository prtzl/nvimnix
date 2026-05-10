local dap = require("dap")

local arm_gdb = vim.fn.exepath("arm-none-eabi-gdb")
local arm_toolchain_path = vim.fn.fnamemodify(arm_gdb, ":h")

local M = {}
M.cached_device = nil
M.build_system = nil
M.build_dir = nil

local function get_device()
    local device = vim.fn.input({
        prompt = "Device: ",
        default = M.cached_device or "",
    })

    if not device or device == "" then
        vim.notify("Device is required", vim.log.levels.ERROR)
        return require("dap").ABORT
    end

    M.cached_device = device
    return device
end

-------------------------------- DAP settings --------------------------------
require('dap-cortex-debug').setup {
    debug = false, -- log debug messages
    -- path to cortex-debug extension, supports vim.fn.glob
    extension_path = os.getenv("CORTEX_DEBUG_PATH") .. '/share/vscode/extensions/marus25.cortex-debug',
    lib_extension = nil, -- shared libraries extension, tries auto-detecting, e.g. 'so' on unix
    node_path = 'node',  -- path to node.js executable
    dapui_rtt = false,   -- register nvim-dap-ui RTT element
    dap_vscode_filetypes = { 'c', 'cpp' },
    -- rtt = {
    --     buftype = 'Terminal', -- 'Terminal' or 'BufTerminal' for terminal buffer vs normal buffer
    -- },
}

dap.adapters.armgdb = {
    type = "executable",
    command = arm_gdb,
    args = { "--interpreter=mi2" }
}

dap.configurations.c = {
    {
        name = "STM32 J-Link",
        type = "armgdb",
        request = "launch",
        program = function()
            local path = vim.fn.input({
                prompt = 'Path to executable: ',
                default = vim.fn.getcwd() .. '/',
                completion = 'file',
            })

            return (path and path ~= '') and path or dap.ABORT
        end,
        cwd = "${workspaceFolder}",

        initCommands = {
            "target remote localhost:2331",
            "monitor reset",
            "load",
        },
    },
    {
        name = 'Cortex Debug Jlink',
        type = 'cortex-debug',
        request = 'launch',

        servertype = 'jlink',
        serverpath = vim.fn.exepath("JLinkGDBServerCLExe"),

        gdbPath = arm_gdb,
        toolchainPath = arm_toolchain_path,
        toolchainPrefix = 'arm-none-eabi',
        gdbTarget = 'localhost:2331',

        device = get_device,

        runToEntryPoint = 'main',
        swoConfig = { enabled = false },
        showDevDebugOutput = false,
        cwd = '${workspaceFolder}',

        executable = function()
            local build_dir = vim.fn.input({
                prompt = "Build folder: ",
                default = "build",
                completion = "dir",
            })

            if build_dir == nil or build_dir == "" then
                build_dir = "build"
            end

            local elfs = vim.fn.glob(build_dir .. "/*.elf", false, true)

            if #elfs == 0 then
                vim.notify("No ELF files found in " .. build_dir, vim.log.levels.ERROR)
                return dap.ABORT
            end

            -- FIX 5: normalize paths (important for debugger stability)
            for i, path in ipairs(elfs) do
                elfs[i] = vim.fn.fnamemodify(path, ":p")
            end

            if #elfs == 1 then
                return elfs[1]
            end

            local choices = vim.deepcopy(elfs)
            table.insert(choices, 1, "Select ELF file:")

            local choice = vim.fn.inputlist(choices)

            if choice <= 0 or choice > #elfs then
                return dap.ABORT
            end

            return elfs[choice]
        end,
    }
}
dap.configurations.cpp = dap.configurations.c

-------------------------------- DAP UI --------------------------------
local dapui = require("dapui")
dapui.setup({
    layouts = {
        -- LEFT: Debug state
        {
            position = "left",
            size = 40,
            elements = {
                { id = "scopes",      size = 0.35 },
                { id = "breakpoints", size = 0.15 },
                { id = "stacks",      size = 0.25 },
                { id = "watches",     size = 0.25 },
            },
        },

        -- BOTTOM: Console / logs
        {
            position = "bottom",
            size = 12,
            elements = {
                { id = "repl",    size = 0.4 },
                { id = "console", size = 0.6 },
            },
        },
    },
})

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

-------------------------------- DAP KEYBINDINGS --------------------------------
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
vim.keymap.set("n", "<F6>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F7>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F8>", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>dl", dap.run_to_cursor, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "Toggle DAP UI" })

local function run_in_terminal(cmd)
    local Terminal = require("toggleterm.terminal").Terminal

    local term = Terminal:new({
        cmd = cmd,
        direction = "float",
        close_on_exit = false,
        on_open = function(t)
            vim.api.nvim_buf_set_keymap(t.bufnr, "n", "<Esc>", "<cmd>close<CR>", { noremap = true, silent = true })
        end,
    })

    term:toggle()
end

vim.keymap.set("n", "<C-b>", function()
    -- 1. build system (cached)
    if not M.build_system then
        local choice = vim.fn.input({
            prompt = "Build system (cmake/meson): ",
            default = "cmake",
        })

        if choice == "" then choice = "cmake" end

        if choice ~= "cmake" and choice ~= "meson" then
            vim.notify("Invalid build system", vim.log.levels.ERROR)
            return
        end

        M.build_system = choice
    end

    -- 2. build dir (cached)
    if not M.build_dir then
        local dir = vim.fn.input({
            prompt = "Build directory: ",
            default = "build",
        })

        if dir == "" then dir = "build" end
        M.build_dir = dir
    end

    -- 3. build command
    local cmd

    if M.build_system == "cmake" then
        cmd = "cmake --build " .. M.build_dir .. " -j"
    elseif M.build_system == "meson" then
        cmd = "meson compile -C " .. M.build_dir
    end

    vim.notify("Building (" .. M.build_system .. ") in " .. M.build_dir)

    run_in_terminal(cmd)
end, { desc = "Build project (cmake/meson)" })
