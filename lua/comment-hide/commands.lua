local utils = require("comment-hide.utils")

local M = {}

local function get_comment_store_path()
  local current_file = vim.api.nvim_buf_get_name(0)
  local project_root = vim.fn.finddir('.git', vim.fn.fnamemodify(current_file, ':p:h') .. ';')
  
  if project_root ~= '' then
    project_root = vim.fn.fnamemodify(project_root, ':h')
  else
    project_root = vim.fn.getcwd()
  end
  
  return project_root .. '/.annotations'
end

local function save_comments()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  
  local comment_store_path = get_comment_store_path()
  local relative_path = filepath:gsub(vim.fn.getcwd() .. "/", "")

  if vim.fn.isdirectory(comment_store_path) == 0 then
    vim.fn.mkdir(comment_store_path, "p")
  end

  local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

  local comments, uncommented_code = utils.extract_comments(content, filetype)

  local comment_file_path = comment_store_path .. "/" .. relative_path .. ".json"
  vim.fn.mkdir(vim.fn.fnamemodify(comment_file_path, ":h"), "p")

  local comment_data = {
    originalContent = content,
    comments = comments,
    filePath = relative_path,
  }

  vim.fn.writefile({vim.json.encode(comment_data)}, comment_file_path)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(uncommented_code, "\n"))

  vim.notify("Comments removed. Backup at: " .. comment_file_path, vim.log.levels.INFO)
end

local function restore_comments()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  
  local comment_store_path = get_comment_store_path()
  local relative_path = filepath:gsub(vim.fn.getcwd() .. "/", "")

  local comment_file_path = comment_store_path .. "/" .. relative_path .. ".json"

  if vim.fn.filereadable(comment_file_path) == 0 then
    vim.notify("No saved comments found at: " .. comment_file_path, vim.log.levels.ERROR)
    return
  end

  local ok, comment_data = pcall(vim.json.decode, table.concat(vim.fn.readfile(comment_file_path), "\n"))
  if not ok then
    vim.notify("Failed to parse comment file", vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(comment_data.originalContent, "\n"))
  vim.notify("Restored comments from: " .. comment_file_path, vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_user_command("CommentHideSave", save_comments, {})
  vim.api.nvim_create_user_command("CommentHideRestore", restore_comments, {})
end

return M
