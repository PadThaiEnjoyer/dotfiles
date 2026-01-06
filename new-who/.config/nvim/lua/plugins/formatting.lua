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
			formatters = {
				stylua = {
					-- Tell Stylua to use the current buffer's indentation
					args = {
						"--indent-type",
						"Spaces",
						"--indent-width",
						function()
							return tostring(vim.bo.shiftwidth)
						end,
						"-",
					},
				},
				ruff_format = {
					-- Ruff is similar; we force it to look at Neovim's detected width
					args = {
						"format",
						"--stdin-filename",
						"$FILENAME",
						"--indent-width",
						function()
							return tostring(vim.bo.shiftwidth)
						end,
						"-",
					},
				},
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
