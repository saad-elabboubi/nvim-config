local map = vim.keymap.set

local function find_project_root()
	local cwd = vim.fn.getcwd()
	local markers = { "package.json", "backend/pyproject.toml", ".git" }
	for _, marker in ipairs(markers) do
		local found = vim.fs.find(marker, { upward = true, path = cwd })[1]
		if found then
			return vim.fs.dirname(found)
		end
	end
	return cwd
end

local function terminal_command(command)
	vim.cmd("botright 16split")
	vim.cmd("terminal " .. command)
	vim.cmd("startinsert")
end

local function run_at_root(shell_command)
	local root = find_project_root()
	terminal_command("cd " .. vim.fn.shellescape(root) .. " && " .. shell_command)
end

vim.api.nvim_create_user_command("MistralBackendCheck", function()
	run_at_root(
		"cd backend && uv run ruff check --fix . && uv run ruff format . && uv run basedpyright . && uv run python -c 'from main import app; print(app.title)'"
	)
end, { desc = "Run backend ruff, basedpyright, and smoke check" })

vim.api.nvim_create_user_command("MistralFrontendCheck", function()
	run_at_root("npm run lint && npx tsc --noEmit")
end, { desc = "Run frontend lint and TypeScript check" })

vim.api.nvim_create_user_command("MistralAllChecks", function()
	run_at_root(
		"cd backend && uv run ruff check --fix . && uv run ruff format . && uv run basedpyright . && uv run python -c 'from main import app; print(app.title)' && cd .. && npm run lint && npx tsc --noEmit"
	)
end, { desc = "Run backend and frontend verification" })

vim.api.nvim_create_user_command("MistralDev", function()
	run_at_root("npm run dev")
end, { desc = "Run frontend dev server" })

map("n", "<leader>pb", "<cmd>MistralBackendCheck<CR>", { desc = "Backend checks" })
map("n", "<leader>pf", "<cmd>MistralFrontendCheck<CR>", { desc = "Frontend checks" })
map("n", "<leader>pa", "<cmd>MistralAllChecks<CR>", { desc = "All project checks" })
map("n", "<leader>pd", "<cmd>MistralDev<CR>", { desc = "Frontend dev server" })
