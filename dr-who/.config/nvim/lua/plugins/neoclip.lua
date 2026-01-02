return {
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      {'kkharji/sqlite.lua', module = 'sqlite'}, -- Optional: for persistent history across restarts
      {'nvim-telescope/telescope.nvim'},
    },
    config = function()
      require('neoclip').setup({
        history = 1000,
        enable_persistent_history = false, -- Set to true if you installed sqlite.lua
        continuation_editing = true,
        db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
      })
      -- Load the telescope extension
      require('telescope').load_extension('neoclip')
      -- Keybind to open the history
      vim.keymap.set('n', '<leader>p', '<cmd>Telescope neoclip<cr>', { desc = "Open Clipboard History" })
    end,
  }
}
