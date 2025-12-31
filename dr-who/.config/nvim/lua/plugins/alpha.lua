return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Set the ASCII header (You can find more online!)
		dashboard.section.header.val = {
			[[                               __                ]],
			[[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
			[[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
			[[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
			[[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
			[[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
		}

		-- Define your menu buttons
		dashboard.section.buttons.val = {
			dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
			dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
			dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
			dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
			dashboard.button("q", "  Quit", ":qa<CR>"),
		}

		alpha.setup(dashboard.config)
	end,
}
