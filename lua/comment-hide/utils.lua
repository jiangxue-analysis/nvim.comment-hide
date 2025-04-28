local M = {}

local comment_patterns = {

	["c"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["cpp"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["cs"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["css"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["go"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["java"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["javascript"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["javascriptreact"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["typescript"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["typescriptreact"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["lua"] = {
		{ single = "--" },
		{ multi_start = "--[[", multi_end = "]]" },
	},
	["python"] = {
		{ single = "#" },
		{ multi_start = '"""', multi_end = '"""' },
		{ multi_start = "'''", multi_end = "'''" },
	},
	["ruby"] = {
		{ single = "#" },
		{ multi_start = "=begin", multi_end = "=end" },
	},
	["r"] = {
		{ single = "#" },
	},
	["rust"] = {
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["sh"] = {
		{ single = "#" },
	},
	["html"] = {
		{ multi_start = "<!--", multi_end = "-->" },
	},
	["markdown"] = {
		{ multi_start = "<!--", multi_end = "-->" },
	},
	["php"] = {
		{ single = "//" },
		{ single = "#" },
		{ multi_start = "/*", multi_end = "*/" },
	},
	["vue"] = {
		{ multi_start = "<!--", multi_end = "-->" },
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
		{ single = "#" },
	},
	["svelte"] = {
		{ multi_start = "<!--", multi_end = "-->" },
		{ single = "//" },
		{ multi_start = "/*", multi_end = "*/" },
	},
}

function M.extract_comments(content, filetype)
	local comments = {}
	local uncommented = content
	local patterns = comment_patterns[filetype] or {}

	local protected = {}
	uncommented = uncommented:gsub("/%*%s*>>>.-[^%*/]-*/", function(match)
		table.insert(protected, match)
		return "PROTECTED_" .. #protected .. "_"
	end)

	for _, pattern in ipairs(patterns) do
		if pattern.multi_start and pattern.multi_end then
			local multi_comments = {}
			uncommented = uncommented:gsub(
				pattern.multi_start:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
					.. ".-"
					.. pattern.multi_end:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"),
				function(match)
					if match:find(">>>") then
						return match
					end
					table.insert(multi_comments, match)
					return "MULTI_COMMENT_" .. #multi_comments .. "_"
				end
			)

			for i, comment in ipairs(multi_comments) do
				table.insert(comments, { text = comment, multi = true })
				uncommented = uncommented:gsub("MULTI_COMMENT_" .. i .. "_", "")
			end
		end

		if pattern.single then
			local lines = vim.split(uncommented, "\n")
			local new_lines = {}

			for _, line in ipairs(lines) do
				local in_string_double = false
				local in_string_single = false
				local in_regex = false
				local in_template = false
				local new_line = ""
				local i = 1

				while i <= #line do
					local char = line:sub(i, i)
					local next_char = line:sub(i + 1, i + 1)

					if
						char == '"'
						and not in_string_single
						and not in_template
						and (i == 1 or line:sub(i - 1, i - 1) ~= "\\")
					then
						in_string_double = not in_string_double
						new_line = new_line .. char
					elseif
						char == "'"
						and not in_string_double
						and not in_template
						and (i == 1 or line:sub(i - 1, i - 1) ~= "\\")
					then
						in_string_single = not in_string_single
						new_line = new_line .. char
					elseif
						char == "`"
						and not in_string_double
						and not in_string_single
						and (i == 1 or line:sub(i - 1, i - 1) ~= "\\")
					then
						in_template = not in_template
						new_line = new_line .. char
					elseif
						(
							filetype == "javascript"
							or filetype == "typescript"
							or filetype == "javascriptreact"
							or filetype == "typescriptreact"
							or filetype == "vue"
							or filetype == "svelte"
						)
						and char == "/"
						and not in_string_double
						and not in_string_single
						and not in_template
						and not in_regex
						and next_char ~= "/"
						and next_char ~= "*"
					then
						in_regex = true
						new_line = new_line .. char
					elseif in_regex and char == "/" and (i == 1 or line:sub(i - 1, i - 1) ~= "\\") then
						in_regex = false
						new_line = new_line .. char
					elseif
						line:sub(i, i + #pattern.single - 1) == pattern.single
						and not in_string_double
						and not in_string_single
						and not in_template
						and not in_regex
					then
						table.insert(comments, { text = line:sub(i) })
						break
					else
						new_line = new_line .. char
					end
					i = i + 1
				end

				table.insert(new_lines, new_line)
			end

			uncommented = table.concat(new_lines, "\n")
		end
	end

	for i, match in ipairs(protected) do
		uncommented = uncommented:gsub("PROTECTED_" .. i .. "_", match)
	end

	local lines = vim.split(uncommented, "\n")
	local cleaned_lines = {}
	local last_was_empty = false

	for _, line in ipairs(lines) do
		local trimmed = line:match("^%s*(.-)%s*$")
		if trimmed ~= "" then
			table.insert(cleaned_lines, line)
			last_was_empty = false
		elseif not last_was_empty then
			table.insert(cleaned_lines, "")
			last_was_empty = true
		end
	end

	while #cleaned_lines > 0 and cleaned_lines[1]:match("^%s*$") do
		table.remove(cleaned_lines, 1)
	end
	while #cleaned_lines > 0 and cleaned_lines[#cleaned_lines]:match("^%s*$") do
		table.remove(cleaned_lines)
	end

	return comments, table.concat(cleaned_lines, "\n")
end

return M
