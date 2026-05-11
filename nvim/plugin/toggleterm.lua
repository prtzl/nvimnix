require("toggleterm").setup({
    start_in_insert = true,
    insert_mappings = false,
    close_on_exit = false,

    size = 20,
    open_mapping = [[<c-]>]],
    direction = "float",

    float_opts = {
        border = "curved",
        width = math.floor(vim.o.columns * 0.95),
        height = math.floor(vim.o.lines * 0.9),
    },
})
