local map = vim.keymap.set

local function switch_source_header(bufnr)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })
	local client = clients[1]
	if not client then
		vim.notify("clangd is not attached", vim.log.levels.WARN)
		return
	end

	client.request("textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(bufnr) }, function(err, result)
		vim.schedule(function()
			if err then
				vim.notify(err.message or "Unable to switch source/header", vim.log.levels.ERROR)
				return
			end

			if not result then
				vim.notify("No matching source/header found", vim.log.levels.INFO)
				return
			end

			vim.cmd.edit(vim.uri_to_fname(result))
		end)
	end, bufnr)
end

local function substitute_word_in_file(old_name, new_name)
	local pattern = "\\<" .. vim.fn.escape(old_name, "\\/") .. "\\>"
	local replacement = vim.fn.escape(new_name, "\\/&")
	vim.cmd("%s/" .. pattern .. "/" .. replacement .. "/gc")
end

local function smart_rename()
	local bufnr = vim.api.nvim_get_current_buf()
	local old_name = vim.fn.expand("<cword>")
	if old_name == "" then
		vim.notify("No word under cursor to rename", vim.log.levels.WARN)
		return
	end

	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/rename" })
	local client = clients[1]
	for _, candidate in ipairs(clients) do
		if candidate.name ~= "ruff" and candidate.name ~= "eslint" then
			client = candidate
			break
		end
	end

	vim.ui.input({ prompt = "Rename to: ", default = old_name }, function(new_name)
		if not new_name or new_name == "" or new_name == old_name then
			return
		end

		if not client then
			substitute_word_in_file(old_name, new_name)
			return
		end

		local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
		params.newName = new_name

		client.request("textDocument/rename", params, function(err, result)
			vim.schedule(function()
				local has_changes = result
					and (
						(result.changes and next(result.changes) ~= nil)
						or (result.documentChanges and #result.documentChanges > 0)
					)

				if err or not has_changes then
					vim.notify("LSP rename failed; using whole-word file replace", vim.log.levels.WARN)
					substitute_word_in_file(old_name, new_name)
					return
				end

				vim.lsp.util.apply_workspace_edit(result, client.offset_encoding or "utf-16")
			end)
		end, bufnr)
	end)
end

vim.diagnostic.config({
	virtual_text = { source = "if_many", spacing = 2 },
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP keymaps",
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local opts = { buffer = event.buf }
		map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
		map("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
		map("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
		map("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
		map("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
		map("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
		map("n", "<leader>rn", smart_rename, vim.tbl_extend("force", opts, { desc = "Smart rename" }))
		map("n", "<leader>cd", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Line diagnostics" }))
		map("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
		map("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))

		if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
			map("n", "<leader>ci", function()
				local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
				vim.lsp.inlay_hint.enable(not enabled, { bufnr = event.buf })
			end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))
		end

		if client and client.name == "clangd" then
			map("n", "<leader>ch", function()
				switch_source_header(event.buf)
			end, vim.tbl_extend("force", opts, { desc = "Switch source/header" }))
			map(
				"n",
				"<leader>cs",
				"<cmd>ClangdSymbolInfo<CR>",
				vim.tbl_extend("force", opts, { desc = "C++ symbol info" })
			)
			map(
				"n",
				"<leader>ct",
				"<cmd>ClangdTypeHierarchy<CR>",
				vim.tbl_extend("force", opts, { desc = "C++ type hierarchy" })
			)
			map(
				"n",
				"<leader>cm",
				"<cmd>ClangdMemoryUsage<CR>",
				vim.tbl_extend("force", opts, { desc = "clangd memory usage" })
			)
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
	capabilities = blink.get_lsp_capabilities(capabilities)
end

local clangd = "/opt/homebrew/opt/llvm/bin/clangd"
if vim.fn.executable(clangd) == 0 then
	clangd = "clangd"
end

vim.lsp.config("clangd", {
	capabilities = capabilities,
	cmd = {
		clangd,
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--header-insertion=iwyu",
		"--pch-storage=memory",
	},
	init_options = {
		clangdFileStatus = true,
		completeUnimported = true,
		usePlaceholders = true,
	},
})

vim.lsp.config("basedpyright", {
	capabilities = capabilities,
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "standard",
				autoImportCompletions = true,
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},
})

vim.lsp.config("ruff", {
	capabilities = capabilities,
})

vim.lsp.config("ts_ls", {
	capabilities = capabilities,
})

vim.lsp.config("eslint", {
	capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
			},
		},
	},
})

vim.lsp.config("taplo", {
	capabilities = capabilities,
})

vim.lsp.enable({ "basedpyright", "ruff", "ts_ls", "eslint", "lua_ls", "taplo", "clangd" })
