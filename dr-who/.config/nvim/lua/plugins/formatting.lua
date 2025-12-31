return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "isort", "black" }, -- Runs isort then black
				bash = { "shfmt" },
				rust = { "rustfmt" },
			},
			format_on_save = {
				lsp_fallback = true, -- Use LSP formatting if conform doesn't have a tool
				async = false,
				timeout_ms = 500,
			},
		})

		-- Manual format keybind
		vim.keymap.set({ "n", "v" }, "<leader>gf", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			})
		end, { desc = "Format file or range (visual)" })
	end,
}
