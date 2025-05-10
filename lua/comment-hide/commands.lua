local utils = require("comment-hide.utils")

local M = {}

local function get_project_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local project_root = vim.fn.finddir(".git", vim.fn.fnamemodify(current_file, ":p:h") .. ";")
  return project_root ~= "" and vim.fn.fnamemodify(project_root, ":h") or vim.fn.getcwd()
end

local function get_comment_store_path()
  return get_project_root() .. "/.annotations"
end

local function ensure_in_gitignore()
  if not M.config or not M.config.gitignore then
    return
  end

  local gitignore_path = get_project_root() .. "/.gitignore"
  local target_entry = ".annotations"

  if vim.fn.filereadable(gitignore_path) == 1 then
    for _, line in ipairs(vim.fn.readfile(gitignore_path)) do
      if line:match("^%s*" .. vim.pesc(target_entry) .. "%s*$") then
        return
      end
    end
  end

  local file = io.open(gitignore_path, "a")
  if file then
    file:write((vim.fn.getfsize(gitignore_path) > 0 and "\n" or "") .. target_entry .. "\n")
    file:close()
    vim.notify("Added '" .. target_entry .. "' to .gitignore", vim.log.levels.INFO)
  else
    vim.notify("Failed to update .gitignore file", vim.log.levels.WARN)
  end
end

local function save_comments()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  local project_root = get_project_root()

  local comment_store_path = get_comment_store_path()
  local relative_path = filepath:gsub(project_root .. "/", "")

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
    timestamp = os.date("%Y-%m-%d %H:%M:%S"),
  }

  vim.fn.writefile({ vim.json.encode(comment_data) }, comment_file_path)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(uncommented_code, "\n"))

  vim.notify("Comments removed. Backup at: " .. comment_file_path, vim.log.levels.INFO)
end

local function restore_comments()
  local buf = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(buf)
  local project_root = get_project_root()

  local comment_store_path = get_comment_store_path()
  local relative_path = filepath:gsub(project_root .. "/", "")
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

function M.setup(opts)
  if M.config then return end

  M.config = vim.tbl_deep_extend("force", {
    gitignore = false,
  }, opts or {})

  vim.api.nvim_create_user_command("CommentHideSave", function()
    if M.config.gitignore then
      ensure_in_gitignore()
    end
    save_comments()
  end, { desc = "Save and strip comments" })

  vim.api.nvim_create_user_command("CommentHideRestore", restore_comments, {
    desc = "Restore original content with comments",
  })
end

return M
