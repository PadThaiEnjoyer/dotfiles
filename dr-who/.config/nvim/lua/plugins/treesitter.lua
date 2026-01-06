return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- This pcall (protected call) prevents the entire editor from crashing
      -- if the module isn't found on the very first boot.
      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if not status_ok then return end

      configs.setup({
        ensure_installed = { 
          "lua", "vim", "vimdoc", "query", "bash", "markdown", 
          "markdown_inline", "python", "qmljs", "javascript", 
          "json", "zsh", "cpp", "yaml", "toml", "ini", "css" 
        },
        auto_install = true,
        highlight = { 
          enable = true, 
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },
}
