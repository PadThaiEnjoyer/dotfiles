return {
  {
    "karb94/neoscroll.nvim",
    config = function()
      require('neoscroll').setup({
        -- Default mappings:
        -- <C-u>, <C-d>, <C-b>, <C-f>, <C-y>, <C-e>, zt, zz, zb
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin
        cursor_scroll_step = 1,      -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = "quadratic" -- Default easing function (others: cubic, quartic, quintic, circular, sine)
      })
    end
  }
}
