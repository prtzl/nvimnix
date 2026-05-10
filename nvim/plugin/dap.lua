local dap = require("dap")

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
    command = "/nix/store/lyw5x085828mzih76llii47bnn7da5f8-gcc-arm-embedded-14.2.rel1/bin/arm-none-eabi-gdb",
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
        serverpath = 'JLinkGDBServerCLExe',
        gdbPath = 'arm-none-eabi-gdb',
        toolchainPath = 'nix/store/lyw5x085828mzih76llii47bnn7da5f8-gcc-arm-embedded-14.2.rel1/bin',
        toolchainPrefix = 'arm-none-eabi',
        device = 'STM32F407VG',          -- 👈 ADD THIS (example, must match your chip)
        runToEntryPoint = 'main',
        swoConfig = { enabled = false }, -- not yet supported
        showDevDebugOutput = false,
        gdbTarget = 'localhost:2331',
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
        -- configFiles = { '${workspaceFolder}/build/openocd/connect.cfg' },
        -- rttConfig = {
        --     address = 'auto',
        --     decoders = {
        --         {
        --             label = 'RTT:0',
        --             port = 0,
        --             type = 'console'
        --         }
        --     },
        --     enabled = true
        -- },
    }
}

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

vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Continue" })
vim.keymap.set("n", "<F6>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F7>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F8>", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>dl", dap.run_to_cursor, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "Toggle DAP UI" })
