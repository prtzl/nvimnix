local map = require('utils').map

-- Spell check setup - default off, use :set spell to turn on
vim.opt.spell = false
vim.opt.spelllang = { 'en_us' }

local toggleSpell = function()
    local isEnabled = vim.opt.spell
    if isEnabled then
        vim.opt.spell = false
        print("Spell disabled!")
    else
        vim.opt.spell = true
        print("Spell enabled!")
    end
end

map("n", "<F9>", function() toggleSpell() end,
    { desc = "Toggle spelling function on/off (default off)" })
map("i", "<F9>", function() toggleSpell() end,
    { desc = "Toggle spelling function on/off (default off)" })
