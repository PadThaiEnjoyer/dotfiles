return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- Loads only when needed to keep startup fast
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300 -- The delay (in ms) before the popup appears
    end,
    opts = {
      icons = {
      mappings = true, -- set to false to hide icons
      keys = {
        Up = "▲ ",
        Down = "▼ ",
        Left = "◀ ",
        Right = "▶ ",
        C = "CTRL ", -- Custom label for Control
        M = "ALT ",  -- Custom label for Alt/Meta
        S = "SHIFT ", -- Custom label for Shift
        CR = "RETURN ",
        Esc = "ESC ",
        ScrollWheelDown = "󱕐 ",
        ScrollWheelUp = "󱕑 ",
        NL = "ENTER ",
        BS = "BACKSPACE ",
        Space = "SPACE ",
        Tab = "TAB ",
        },
      -- Your configuration goes here, or leave empty for default settings
      },
    },
  }
}
