---@diagnostic disable: undefined-global
return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				-- Add the servers you want installed here
				ensure_installed = { "lua_ls", "bashls", "pyright", "rust_analyzer" },
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, {
				offsetEncoding = { "utf-16" },
			})
			-- This tells Neovim how to handle the "Live comments" (Diagnostics)
			vim.diagnostic.config({
				virtual_text = {
					prefix = "", -- This appears before the error message
					spacing = 4, -- Adds space between your code and the message
				},
				update_in_insert = true, -- Shows errors as you type
				severity_sort = true, -- Puts high-priority errors first
			})

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT", -- Neovim uses LuaJIT
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							-- This tells the server where the Neovim runtime files are
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})
			-- The new way to enable servers in Neovim 0.11+
			vim.lsp.config("pyright", { capabilities = capabilities })
			vim.lsp.config("bashls", { capabilities = capabilities })
			vim.lsp.enable("lua_ls")
			vim.lsp.enable("bashls")
			vim.lsp.enable("pyright")

			-- Global Keybinds (These still work the same)
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf }
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover Info", buffer = args.buf })
					vim.keymap.set(
						"n",
						"gd",
						require("telescope.builtin").lsp_definitions,
						{ desc = "Telescope Definition" }
					)
					vim.keymap.set(
						{ "n", "v" },
						"<leader>ca",
						vim.lsp.buf.code_action,
						{ desc = "Code Action", buffer = args.buf }
					)
				end,
			})
		end,
	},
}
