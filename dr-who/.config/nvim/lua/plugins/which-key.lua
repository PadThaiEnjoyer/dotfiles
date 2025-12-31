return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- Loads only when needed to keep startup fast
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300 -- The delay (in ms) before the popup appears
    end,
    opts = {
      -- Your configuration goes here, or leave empty for default settings
    },
  },
}
