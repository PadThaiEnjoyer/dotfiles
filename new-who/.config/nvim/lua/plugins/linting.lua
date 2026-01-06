return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			lua = { "luacheck" },
			python = { "ruff" }, -- Ruff is faster than flake8
			bash = { "shellcheck" },
		}

		vim.api.nvim_create_user_command("LintInfo", function()
			local ft = vim.bo.filetype
			local l = lint.linters_by_ft[ft]
			print("Linters for " .. ft .. ": " .. (l and table.concat(l, ", ") or "None"))
		end, {})

		-- Run linting on save
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
