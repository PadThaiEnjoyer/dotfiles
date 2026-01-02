return {
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty for defaults
			})
		end,
	},
}
