return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = {
				"lua", "vim", "vimdoc", "query",
				"javascript", "typescript",
				"java", "kotlin", "groovy", "properties",
				"html", "xml",
				"markdown", "markdown_inline",
				"json", "yaml",
				"proto",
				"bash", "nu",
				"git_config", "gitignore",
				"asm",
				"dockerfile",
			},
			auto_install = true,
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<Enter>", -- set to `false` to disable one of the mappings
					node_incremental = "<Enter>",
					scope_incremental = "grc",
					node_decremental = "<Backspace>",
				},
			},
		})
	end
}
