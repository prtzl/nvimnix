local mru_buffers = {}
local current_index = 1
local cycling = false

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function vim.g.print_buffers()
    print("Mru buffers: ", dump(mru_buffers), "cureeeetn index: ", current_index)
end

-- Remove invalid buffers from MRU (to be safe)
local function clean_mru()
    local new_mru = {}
    for _, bufnr in ipairs(mru_buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" then
            table.insert(new_mru, bufnr)
        end
    end
    mru_buffers = new_mru
    if current_index > #mru_buffers then
        current_index = #mru_buffers
    end
    if current_index < 1 then
        current_index = 1
    end
end

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if cycling then return end
        local bufnr = vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buftype ~= "" then
            return
        end
        for i, b in ipairs(mru_buffers) do
            if b == bufnr then
                table.remove(mru_buffers, i)
                break
            end
        end
        table.insert(mru_buffers, 1, bufnr)
        current_index = 1
    end,
})

function vim.g.cycle_mru(forward)
    clean_mru()
    if #mru_buffers < 2 then return end

    current_index = current_index + (forward and 1 or -1)
    if current_index > #mru_buffers then
        current_index = 1
    elseif current_index < 1 then
        current_index = #mru_buffers
    end

    local buf_to_go = mru_buffers[current_index]
    if not buf_to_go or not vim.api.nvim_buf_is_loaded(buf_to_go) then
        print("Error: Invalid buffer at index:", current_index, "buffer id:", buf_to_go)
        return
    end

    cycling = true
    vim.api.nvim_set_current_buf(buf_to_go)
    cycling = false
end
