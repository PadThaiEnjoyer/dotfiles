return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			-- Add this to the dependencies list in the file above
			{
				"mfussenegger/nvim-dap-python",
				ft = "python",
				dependencies = { "mfussenegger/nvim-dap" },
				config = function()
					-- This points to the debugpy installed by Mason
					local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
					require("dap-python").setup(path)
				end,
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- Automatically open/close UI when debugging starts/ends
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			vim.fn.sign_define(
				"DapBreakpoint",
				{ text = "🛑", texthl = "DapBreakpoint", linehl = "DapBreakpointLine", numhl = "" }
			)
			vim.fn.sign_define(
				"DapStopped",
				{ text = "▶️", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" }
			)
			vim.fn.sign_define(
				"DapBreakpointCondition",
				{ text = "❓", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
			)
			-- Add these lines:
			-- This ensures the colors are applied even after a theme change
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75", bold = true })
					vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5c07b", bold = true })
					vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bold = true })
					vim.api.nvim_set_hl(0, "DapBreakpointLine", { bg = "#312b2b" }) -- red/brown
					vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e3b30", bold = true })
				end,
			})

			vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "*" })

			-- Manually trigger it once on startup
			vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "*" })
			-- Basic Keybinds
			vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<Leader>di", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<Leader>do", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<Leader>dB", function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Set Conditional Breakpoint" })
			vim.keymap.set("n", "<Leader>dh", function()
				require("dapui").eval()
			end, { desc = "Debug: UI Hover/Eval" })
			-- Close the UI windows
			vim.keymap.set("n", "<Leader>du", function()
				require("dapui").toggle()
			end, { desc = "Debug: Toggle UI" })

			-- Exit the debugger entirely and close UI
			vim.keymap.set("n", "<Leader>de", function()
				require("dap").terminate()
				require("dapui").close()
			end, { desc = "Debug: Exit/Terminate" })
		end,
	},
}
