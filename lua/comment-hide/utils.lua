local M = {}

function M.extract_comments(content, filetype)
  local comments = {}
  local uncommented = content
  
  local is_ruby = filetype == "ruby" or filetype == "rb"

  local protected = {}
  uncommented = uncommented:gsub("/%*%s*>>>.-[^%*/]-*/", function(match)
    table.insert(protected, match)
    return "PROTECTED_" .. #protected .. "_"
  end)

  if is_ruby then
    local ruby_multiline_comments = {}
    uncommented = uncommented:gsub("=begin.-=end", function(match)
      table.insert(ruby_multiline_comments, match)
      return "RUBY_MULTILINE_" .. #ruby_multiline_comments .. "_"
    end)

    local lines = vim.split(uncommented, "\n")
    local new_lines = {}
    
    for _, line in ipairs(lines) do
      local in_string_double = false
      local in_string_single = false
      local in_regex = false
      local in_q_string = false  
      local new_line = ""
      local i = 1
      while i <= #line do
        if line:sub(i, i) == '"' and (i == 1 or line:sub(i-1, i-1) ~= "\\") then
          in_string_double = not in_string_double
          new_line = new_line .. line:sub(i, i)
        elseif line:sub(i, i) == "'" and (i == 1 or line:sub(i-1, i-1) ~= "\\") then
          in_string_single = not in_string_single
          new_line = new_line .. line:sub(i, i)
        elseif line:sub(i, i) == "/" and not in_string_double and not in_string_single then
          in_regex = not in_regex
          new_line = new_line .. line:sub(i, i)
        elseif line:sub(i, i) == "#" and not in_string_double and not in_string_single and not in_regex and not in_q_string then
          table.insert(comments, {text = line:sub(i)})
          break
        elseif line:sub(i, i) == "{" and line:sub(i-2, i-1) == "%q" then
          in_q_string = true
          new_line = new_line .. line:sub(i, i)
        elseif line:sub(i, i) == "}" and in_q_string then
          in_q_string = false
          new_line = new_line .. line:sub(i, i)
        else
          new_line = new_line .. line:sub(i, i)
        end
        i = i + 1
      end
      table.insert(new_lines, new_line)
    end

    uncommented = table.concat(new_lines, "\n")

    for i, match in ipairs(ruby_multiline_comments) do
      uncommented = uncommented:gsub("RUBY_MULTILINE_" .. i .. "_", match)
    end
  else
    for comment in uncommented:gmatch("//.-\n") do
      table.insert(comments, {text = comment})
      uncommented = uncommented:gsub("%f[^\n]"..comment:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"), "")
    end
    for comment in uncommented:gmatch("//[^%c]*") do
      table.insert(comments, {text = comment})
      uncommented = uncommented:gsub(comment:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"), "")
    end

    for comment in uncommented:gmatch("/%*.-[^%*/]-*/") do
      if not string.match(comment, "/%*%s*>>>") then
        table.insert(comments, {text = comment})
        uncommented = uncommented:gsub(comment:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1"), "")
      end
    end
  end

  for i, match in ipairs(protected) do
    uncommented = uncommented:gsub("PROTECTED_" .. i .. "_", match)
  end

  lines = vim.split(uncommented, "\n")
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
