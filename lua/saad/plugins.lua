local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "macchiato",
			transparent_background = false,
			integrations = {
				gitsigns = true,
				telescope = true,
				treesitter = true,
				which_key = true,
			},
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			delay = 400,
			preset = "modern",
			spec = {
				{ "<leader>b", group = "buffers" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "debug" },
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>p", group = "project" },
				{ "<leader>s", group = "splits" },
				{ "<leader>t", group = "terminal" },
				{ "<leader>x", group = "diagnostics" },
			},
		},
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-mini/mini.icons" },
		opts = {
			options = {
				component_separators = "",
				section_separators = "",
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					function()
						if vim.bo.filetype == "oil" then
							local ok, oil = pcall(require, "oil")
							local dir = ok and oil.get_current_dir() or nil
							if dir then
								return "Oil  " .. vim.fn.fnamemodify(dir, ":~")
							end
							return "Oil"
						end

						local name = vim.fn.expand("%:t")
						return name ~= "" and name or "[Scratch]"
					end,
				},
				lualine_x = { "encoding", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					function()
						if vim.bo.filetype == "oil" then
							return "Oil"
						end
						return vim.fn.expand("%:t")
					end,
				},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			extensions = { "quickfix", "trouble", "lazy" },
		},
	},

	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
		keys = {
			{ "<C-h>", "<cmd>TmuxNavigateLeft<CR>", desc = "Move left" },
			{ "<C-j>", "<cmd>TmuxNavigateDown<CR>", desc = "Move down" },
			{ "<C-k>", "<cmd>TmuxNavigateUp<CR>", desc = "Move up" },
			{ "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Move right" },
			{ "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", desc = "Move previous" },
		},
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			require("nvim-treesitter")
				.install({
					"bash",
					"c",
					"cmake",
					"cpp",
					"css",
					"html",
					"javascript",
					"json",
					"lua",
					"markdown",
					"python",
					"toml",
					"tsx",
					"typescript",
					"vim",
					"yaml",
				})
				:wait(300000)
		end,
		config = function()
			require("nvim-treesitter").setup()

			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"bash",
					"c",
					"cmake",
					"cpp",
					"css",
					"html",
					"javascript",
					"javascriptreact",
					"json",
					"lua",
					"markdown",
					"python",
					"objc",
					"objcpp",
					"sh",
					"toml",
					"tsx",
					"typescript",
					"typescriptreact",
					"vim",
					"yaml",
				},
				callback = function()
					pcall(vim.treesitter.start)
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},

	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp", "objc", "objcpp", "cuda" },
		opts = {},
	},

	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files hidden=true<CR>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep text" },
			{ "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
			{ "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
			{ "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
			{ "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<CR>", desc = "Buffer diagnostics" },
			{ "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Find word under cursor" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		opts = {
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
					},
				},
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			pcall(telescope.load_extension, "fzf")
		end,
	},

	{
		"nvim-mini/mini.icons",
		lazy = false,
		opts = {
			-- iTerm has a font-fallback quirk: glyphs in U+E5xx-U+E6xx and U+F4xx
			-- render as `?` even when the font has them. Workaround: override
			-- the affected files/dirs to use Material Design Icons (U+F02xx-U+F09xx)
			-- which render reliably.
			file = {
				["README.md"] = { glyph = "󰍔", hl = "MiniIconsBlue" }, -- markdown
				["pyproject.toml"] = { glyph = "󰒓", hl = "MiniIconsOrange" }, -- cog
				["uv.lock"] = { glyph = "󰌾", hl = "MiniIconsGrey" }, -- lock
				["your_program.sh"] = { glyph = "󰆍", hl = "MiniIconsGreen" }, -- console
				["codecrafters.yml"] = { glyph = "󰧺", hl = "MiniIconsYellow" }, -- text_box
			},
			extension = {
				tsx = { glyph = "󰛦", hl = "MiniIconsBlue" }, -- MDI typescript
				jsx = { glyph = "󰌞", hl = "MiniIconsYellow" }, -- MDI javascript
			},
			directory = {
				[".git"] = { glyph = "󰊢", hl = "MiniIconsOrange" }, -- MDI git
			},
		},
		config = function(_, opts)
			require("mini.icons").setup(opts)
			-- Single icon source: route nvim-web-devicons API through mini.icons.
			MiniIcons.mock_nvim_web_devicons()
		end,
	},
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		keys = {
			{ "-", "<cmd>Oil<CR>", desc = "Open parent directory" },
			{ "<leader>e", "<cmd>Oil<CR>", desc = "Directory editor" },
		},
		dependencies = {
			"nvim-mini/mini.icons",
		},
		opts = {
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = false,
			columns = {
				"icon",
			},
			win_options = {
				signcolumn = "no",
				foldcolumn = "0",
				number = false,
				relativenumber = false,
				cursorline = true,
				winbar = "%!v:lua.SaadOilWinbar()",
			},
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name)
					return name == "__pycache__"
				end,
			},
			keymaps = {
				["q"] = "actions.close",
				["<C-h>"] = false,
				["<C-l>"] = false,
			},
		},
		config = function(_, opts)
			_G.SaadOilWinbar = function()
				local ok, oil = pcall(require, "oil")
				if not ok then
					return "Oil"
				end

				local dir = oil.get_current_dir()
				if not dir then
					return "Oil"
				end

				return "  Oil  " .. vim.fn.fnamemodify(dir, ":~")
			end

			require("oil").setup(opts)

			vim.api.nvim_set_hl(0, "OilDir", { fg = "#8aadf4", bold = true })
			vim.api.nvim_set_hl(0, "OilDirIcon", { fg = "#8aadf4" })
			vim.api.nvim_set_hl(0, "OilFile", { fg = "#cad3f5" })
			vim.api.nvim_set_hl(0, "OilLink", { fg = "#8bd5ca", italic = true })
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local function bmap(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				bmap("n", "]h", gs.next_hunk, "Next git hunk")
				bmap("n", "[h", gs.prev_hunk, "Previous git hunk")
				bmap("n", "<leader>gh", gs.preview_hunk, "Preview hunk")
				bmap("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
				bmap("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
				bmap("n", "<leader>gb", gs.blame_line, "Blame line")
			end,
		},
	},

	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
		},
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Workspace diagnostics" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols" },
		},
	},

	{
		"mfussenegger/nvim-dap",
		keys = {
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "Debug continue",
			},
			{
				"<F10>",
				function()
					require("dap").step_over()
				end,
				desc = "Debug step over",
			},
			{
				"<F11>",
				function()
					require("dap").step_into()
				end,
				desc = "Debug step into",
			},
			{
				"<F12>",
				function()
					require("dap").step_out()
				end,
				desc = "Debug step out",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Conditional breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Debug continue",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Debug REPL",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Debug terminate",
			},
		},
		config = function()
			local dap = require("dap")
			local codelldb = vim.fn.exepath("codelldb")

			if codelldb ~= "" then
				dap.adapters.codelldb = {
					type = "server",
					port = "${port}",
					executable = {
						command = codelldb,
						args = { "--port", "${port}" },
					},
				}

				dap.configurations.cpp = {
					{
						name = "Debug C/C++ executable",
						type = "codelldb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopOnEntry = false,
					},
				}
				dap.configurations.c = dap.configurations.cpp
			end
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle debug UI",
			},
		},
		opts = {},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},

	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<leader>tt", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
			{ "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", desc = "Floating terminal" },
		},
		opts = {
			direction = "horizontal",
			size = 14,
			shade_terminals = false,
		},
	},

	{
		"ThePrimeagen/vim-be-good",
		cmd = "VimBeGood",
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "BufReadPost",
		init = function()
			vim.g.no_python_maps = true
		end,
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@function.outer"] = "V",
						["@class.outer"] = "V",
					},
					include_surrounding_whitespace = true,
				},
				move = {
					set_jumps = true,
				},
			})

			local map = vim.keymap.set
			local select = require("nvim-treesitter-textobjects.select")
			local move = require("nvim-treesitter-textobjects.move")

			map({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end, { desc = "Around function" })
			map({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end, { desc = "Inside function" })
			map({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end, { desc = "Around class" })
			map({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end, { desc = "Inside class" })

			map({ "n", "x", "o" }, "]m", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function" })
			map({ "n", "x", "o" }, "[m", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, { desc = "Previous function" })
			map({ "n", "x", "o" }, "]M", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, { desc = "Next function end" })
			map({ "n", "x", "o" }, "[M", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Previous function end" })
		end,
	},

	{
		"shortcuts/no-neck-pain.nvim",
		cmd = { "NoNeckPain", "NoNeckPainToggleLeftSide", "NoNeckPainToggleRightSide" },
		keys = {
			{ "<leader>z", "<cmd>NoNeckPain<CR>", desc = "Toggle centered layout" },
		},
		opts = {
			width = 100, -- buffer width (chars). raise to 120 if you want wider.
			autocmds = {
				enableOnVimEnter = false,
				enableOnTabEnter = false,
			},
		},
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash jump",
			},
		},
		opts = {
			labels = "asdfghjklqwertyuiopzxcvbnm",
			label = {
				after = true,
				before = false,
				style = "overlay",
			},
			highlight = {
				backdrop = true,
			},
			search = {
				multi_window = true,
			},
			modes = {
				char = {
					enabled = false,
				},
			},
		},
		config = function(_, opts)
			require("flash").setup(opts)
			vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#24273a", bg = "#eed49f", bold = true })
			vim.api.nvim_set_hl(0, "FlashMatch", { fg = "#8bd5ca", bold = true })
			vim.api.nvim_set_hl(0, "FlashCurrent", { fg = "#24273a", bg = "#a6da95", bold = true })
			vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = "#6e738d" })
		end,
	},

	{
		"sphamba/smear-cursor.nvim",
		event = "VeryLazy",
		keys = {
			{
				"<leader>tc",
				function()
					require("smear_cursor").toggle()
				end,
				desc = "Toggle cursor smear",
			},
		},
		opts = {
			cursor_color = "#eed49f",
			smear_between_buffers = true,
			smear_between_neighbor_lines = true,
			scroll_buffer_space = true,
			smear_insert_mode = true,
			stiffness = 0.8,
			trailing_stiffness = 0.6,
			stiffness_insert_mode = 0.7,
			trailing_stiffness_insert_mode = 0.7,
			damping = 0.95,
			damping_insert_mode = 0.95,
			distance_stop_animating = 0.5,
		},
	},

	{
		"saghen/blink.cmp",
		version = "*",
		event = { "InsertEnter", "CmdlineEnter" },
		opts = {
			keymap = {
				preset = "none",
				["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-y>"] = { "accept" },
				-- show function arguments on demand
				["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				list = { selection = { preselect = false, auto_insert = false } },
				menu = {
					draw = {
						treesitter = { "lsp" },
					},
					direction_priority = { "s" },
				},
				documentation = {
					auto_show = false, -- no docs panel by default
				},
				accept = { auto_brackets = { enabled = true } },
				ghost_text = { enabled = false },
			},
			signature = {
				enabled = true,
				trigger = {
					enabled = false,
					show_on_trigger_character = false,
					show_on_insert_on_trigger_character = false,
					show_on_accept = false,
					show_on_accept_on_trigger_character = false,
				},
				window = {
					border = "rounded",
					max_width = 90,
					max_height = 3,
					direction_priority = { "s" },
					show_documentation = false,
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = {
						transform_items = function(_, items)
							local kinds = require("blink.cmp.types").CompletionItemKind
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
							local is_member_access = before_cursor:match("%.[%w_]*$") ~= nil

							local score_offsets = is_member_access
									and {
										[kinds.Property] = 8,
										[kinds.Field] = 8,
										[kinds.Method] = 6,
										[kinds.Function] = 5,
									}
								or {
									[kinds.Class] = 4,
									[kinds.Struct] = 4,
									[kinds.Interface] = 4,
									[kinds.Enum] = 3,
									[kinds.Function] = 3,
									[kinds.Method] = 2,
									[kinds.Module] = 2,
									[kinds.TypeParameter] = 2,
									[kinds.Variable] = 1,
								}

							for _, item in ipairs(items) do
								item.score_offset = (item.score_offset or 0) + (score_offsets[item.kind] or 0)
								if item.label and item.label:match("^__.*__$") then
									item.score_offset = item.score_offset - 30
								end
							end

							return items
						end,
					},
				},
			},
			cmdline = {
				keymap = {
					preset = "none",
					["<Tab>"] = { "show", "select_next", "fallback" },
					["<S-Tab>"] = { "select_prev", "fallback" },
					["<C-y>"] = { "accept" },
					["<C-e>"] = { "hide", "fallback" },
					["<CR>"] = { "fallback" },
				},
				completion = {
					list = { selection = { preselect = false, auto_insert = false } },
					menu = { auto_show = false },
				},
			},
		},
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
			fast_wrap = {},
		},
	},

	{
		"mason-org/mason.nvim",
		cmd = "Mason",
		opts = {
			ui = {
				border = "rounded",
			},
		},
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {
				"basedpyright",
				"codelldb",
				"eslint-lsp",
				"lua-language-server",
				"prettier",
				"ruff",
				"stylua",
				"taplo",
				"typescript-language-server",
			},
			auto_update = false,
			run_on_start = true,
			start_delay = 3000,
		},
	},

	{
		"neovim/nvim-lspconfig",
		lazy = false,
	},

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "Format file",
			},
		},
		opts = {
			format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
			formatters_by_ft = {
				c = { "clang_format" },
				cpp = { "clang_format" },
				python = { "ruff_fix", "ruff_format" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				lua = { "stylua" },
				json = { "prettier" },
				markdown = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
			},
		},
	},
}, {
	change_detection = {
		notify = false,
	},
	checker = {
		enabled = true,
		notify = false,
	},
})
