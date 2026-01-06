require("vim-options")

require("config.lazy")

-- Path to your script
local set_rgb = "/home/tudor/.local/bin/set-rgb"

local function update_kbd_color()
    -- Get the current mode
    local mode = vim.api.nvim_get_mode().mode

    -- Map modes to Hex colors (Matching Lualine style)
    local mode_colors = {
        ['n']      = "FF00FF", -- Normal: Purple
        ['i']      = "00FF00", -- Insert: Green
        ['v']      = "FFFF00", -- Visual: Yellow
        ['V']      = "FFFF00", -- Visual Line: Yellow
        ['\22']    = "FFFF00", -- Visual Block: Yellow
        ['c']      = "FF7f00", -- Command: Orange
        ['R']      = "FF0000", -- Replace: Red
        ['t']      = "FF00FF", -- Terminal: Purp
    }

    -- Get color for current mode or default to White
    local hex = mode_colors[mode] or "D8DEE9"

    -- Execute the script in the background (&) so Neovim doesn't lag
    os.execute(set_rgb .. " " .. hex .. " &")
end

-- Create the Autocommand
vim.api.nvim_create_autocmd("ModeChanged", {
    callback = function()
        update_kbd_color()
    end,
})

-- Optional: Reset keyboard to white when you close Neovim
vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
        os.execute("/home/tudor/.local/bin/set-rgb &")
    end,
})

-- Execute when Neovim loses focus (switching to another app)
vim.api.nvim_create_autocmd("FocusLost", {
    pattern = "*",
    callback = function()
        os.execute("~/.local/bin/set-rgb &")
    end,
})

-- Execute when leaving a buffer or tab (staying in Neovim but moving around)
vim.api.nvim_create_autocmd("WinLeave", {
    pattern = "*",
    callback = function()
        os.execute("~/.local/bin/set-rgb &")
    end,
})


-- When focus is gained, re-apply the color for the current mode
vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
        update_kbd_color()
    end,
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        update_kbd_color()
    end,
})
