return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- requires a nerd font
      "MunifTanjim/nui.nvim",
    },
    opts = {
      close_if_last_window = true, -- This is the magic line
      filesystem = {
        follow_current_file = {
          enabled = true, -- This makes the tree jump to the file you are editing
        },
        enable_git_status = true,
        event_handlers = {
          {
            event = "neo_tree_window_after_open",
            handler = function()
                require("neo-tree.sources.manager").refresh("filesystem")
            end
            },
        },
        -- This allows the tree to change its root as you move around
        use_libuv_file_watcher = true, 
        -- Pressing 'H' in the tree will toggle hidden files (like .dotfiles)
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },


    config = function(_, opts)

      require("neo-tree").setup(opts)  
      -- This sets up the keybind to toggle the tree
      vim.keymap.set('n', '<C-n>', ':Neotree filesystem toggle left<CR>', { desc = 'Open Files Sidebar'})
      
    end
  }
}
