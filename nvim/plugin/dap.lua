local dap = require("dap")

-- HELPERS FOR GETTING DEVICE NAME AND EXECUTABLE (DIR) and caching choices
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

local function getExecutable()
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
end

local function getExe()
    local elf = vim.fn.input({
        prompt = "Executable path:",
        default = "",
        completion = "dir",
    })

    if #elf == 0 then
        vim.notify("No ELF provided", vim.log.levels.ERROR)
        return dap.ABORT
    end

    return elf
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

-- INFO: expand workspaceFolder and workspaceRoot with cwd for cortex-debug launch.json
local vscode = require("dap.ext.vscode")
local function expand_vars(obj)
    if type(obj) == "table" then
        local res = {}
        for k, v in pairs(obj) do
            res[k] = expand_vars(v)
        end
        return res
    elseif type(obj) == "string" then
        local cwd = vim.fn.getcwd()

        obj = obj:gsub("${workspaceFolder}", cwd)
        obj = obj:gsub("${workspaceRoot}", cwd)

        return obj
    end

    return obj
end

local orig = vscode.load_launchjs
vscode.load_launchjs = function(path, type_to_filetypes)
    orig(path, type_to_filetypes)

    for _, configs in pairs(dap.configurations) do
        for i, config in ipairs(configs) do
            configs[i] = expand_vars(config)
        end
    end
end

-- ARM GDB ADAPTER
local cwd = vim.fn.getcwd()
local arm_gdb_exe = "arm-none-eabi-gdb"

local arm_gdb_from_env = os.getenv("ARM_GDB_PATH")
local arm_gdb_from_file = nil
local arm_gdb_path_file = cwd .. "/.arm_gdb_path"

-- check if env var is dir path or not, assume executable
if arm_gdb_from_env then
    if vim.fn.isdirectory(arm_gdb_from_env) then
        arm_gdb_from_env = arm_gdb_from_env .. "/" .. arm_gdb_exe
    end
end

-- read .arm_gdb_path and figure out if string is bin dir or assume executable
local fd = io.open(arm_gdb_path_file, "r")
if fd then
    local line = fd:read("*l")
    fd:close()

    if line and line ~= "" then
        -- Trim whitespace
        line = line:gsub("^%s+", ""):gsub("%s+$", "")

        -- If it's a directory, append executable name
        if vim.fn.isdirectory(line) then
            arm_gdb_from_file = line .. "/" .. arm_gdb_exe
        else
            arm_gdb_from_file = line
        end
    end
end

-- define arm executable in order: env var -> dotfile -> full path -> just exe name
local arm_gdb =
    arm_gdb_from_env
    or arm_gdb_from_file
    or vim.fn.exepath(arm_gdb_exe)
    or arm_gdb_exe
local arm_toolchain_path = vim.fn.fnamemodify(arm_gdb, ":h")

print("Armm GDB:", arm_gdb)
print("ARM GDB TOOLCHAIN:", arm_toolchain_path)

dap.adapters.armgdb = {
    id = "gdb",
    type = "executable",
    command = arm_gdb,
    args = { "--quiet", "--interpreter=dap" },
}

-- NATIVE GDB ADAPTER
dap.adapters.gdb = {
    id = "gdb",
    type = "executable",
    command = vim.fn.exepath("gdb"),
    args = { "--quiet", "--interpreter=dap" },
}

-- DAP CONFIGURATIONS
dap.configurations.c = {
    {
        name = "cortex-debug generic (launch)",
        type = "cortex-debug",
        cwd = "${workspaceFolder}",

        request = "launch",

        servertype = "jlink",
        serverpath = vim.fn.exepath("JLinkGDBServerCLExe"),

        device = get_device,
        executable = getExecutable,

        runToEntryPoint = "main",

        gdbPath = arm_gdb,
        toolchainPath = arm_toolchain_path,
        toolchainPrefix = "arm-none-eabi",
    },
    {
        name = "Cortex Debug stlink",
        type = "cortex-debug",
        cwd = "${workspaceFolder}",
        request = "launch",

        servertype = "stutil",

        device = get_device,
        executable = getExecutable,
        runToEntryPoint = "main",

        gdbPath = arm_gdb,
        toolchainPath = arm_toolchain_path,
        toolchainPrefix = "arm-none-eabi",
    },
    {
        name = "arm-none-eabi-gdb (attach)",
        type = "armgdb",
        program = getExecutable,

        request = "attach",

        -- launch settings?
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        stopAtBeginningOfMainSubprogram = true,
        args = {
            "target remote localhost:2331",
            "load",
            "break main",
            "continue",
        },

        -- attach settings?
        target = "localhost:2331",
    },
    {
        name = "arm-none-eabi-gdb (launch)",
        type = "armgdb",
        program = getExecutable,

        request = "launch",

        -- launch settings?
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        stopAtBeginningOfMainSubprogram = true,
        args = {
            "target remote localhost:2331",
            "load",
            "break main",
            "continue",
        },

        -- attach settings?
        target = "localhost:2331",
    },
    {
        name = "gdb native (launch)",
        type = "gdb",
        program = getExe,

        request = "launch",

        -- launch settings?
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        stopAtBeginningOfMainSubprogram = true,
        args = {},
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
                { id = "repl", size = 1.0 },
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

-------------------------------- DAP VIRTUAL TEXT --------------------------------
local dapvt = require("nvim-dap-virtual-text")
dapvt.setup({})

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

-------------------------------- BUILD HELPER KEYBINDINGS --------------------------------
local Terminal = require("toggleterm.terminal").Terminal
local tt = require("toggleterm.terminal")

local function run_in_terminal(cmd)
    local term = tt.get(1)

    if not term then
        term = Terminal:new({
            count = 1,
            direction = "float",
            close_on_exit = false,
            start_in_insert = true,
        })
    end

    term:open()

    vim.schedule(function()
        local bufnr = term.bufnr
        local job_id = vim.b.terminal_job_id

        if bufnr and vim.api.nvim_buf_is_valid(bufnr) and job_id then
            vim.api.nvim_set_current_buf(bufnr)

            -- 1. clear terminal (real reset of visible output)
            vim.api.nvim_chan_send(job_id, "clear\n")

            -- 2. run build
            vim.api.nvim_chan_send(job_id, cmd .. "\n")
        end
    end)
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
