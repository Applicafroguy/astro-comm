local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

local comment_lines = function(lines)
	local commented_lines = {}

	for _, line in ipairs(lines) do
		table.insert(commented_lines, "<!-- " .. line .. " -->")
	end

	return commented_lines
end

local function is_commented(line)
	return string.match(line, "^%s*<!--") ~= nil
end

local function uncomment_lines(lines)
	local uncommented_lines = {}

	for _, line in ipairs(lines) do
		local uncommented_line = string.gsub(line, "^%s*<!--%s*(.-)%s*-->%s*$", "%1"):gsub("^%s*-%s*", "")
		table.insert(uncommented_lines, uncommented_line)
	end

	return uncommented_lines
end

local function uncomment_selection()
	local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
end

local function uncomment_current_line()
	local line = vim.api.nvim_get_current_line()
end

M.comment_selection = function()
	local start_line, start_col = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local end_line, end_col = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	if next(lines) ~= nil then
		if is_commented(lines[1]) and is_commented(lines[#lines]) then
			local uncommented_lines = uncomment_lines(lines)
			vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, uncommented_lines)
		else
			local commented_lines = comment_lines(lines)
			vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, commented_lines)
		end
	else
		print("Not in Visual Mode.")
	end
end

M.comment_current_line = function()
	local line = vim.api.nvim_get_current_line()

	if is_commented(line) then
		local uncommented_line = string.gsub(line, "^%s*<!--%s*(.-)%s*-->%s*$", "%1"):gsub("^%s*-%s*", "")
		vim.api.nvim_set_current_line(uncommented_line)
	else
		vim.api.nvim_set_current_line("<!-- " .. line .. " -->")
	end
end

M.setup = function()
	vim.cmd("command! ToggleComment lua require('astro-comm').comment_current_line()")
	vim.cmd("command! ToggleCommentSelection lua require('astro-comm').comment_selection()")

	vim.api.nvim_set_keymap("v", "<leader>w", "<cmd>ToggleCommentSelection <CR>", { noremap = true })
	vim.api.nvim_set_keymap("n", "<leader>w", "<cmd>ToggleComment<CR>", { noremap = true })
end

return M
