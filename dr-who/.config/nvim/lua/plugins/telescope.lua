return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8', -- Use a stable release
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          preview = {
            treesitter = false, -- This disables the buggy highlight function
          },
        },
      })
      local builtin = require('telescope.builtin')
      
      -- Basic Keymaps to get you started
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    end
  }
}
