return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Requires icons just like Neo-tree
    config = function()
      require('lualine').setup({
        options = {
          theme = 'dracula', -- You can change this to 'auto' or your favorite theme
          icons_enabled = true,
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
        },
      })
    end
  }
}
