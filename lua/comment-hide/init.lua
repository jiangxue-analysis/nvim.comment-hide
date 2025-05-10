local M = {}

local default_config = {
  gitignore = false
}

M.config = nil

local function setup(opts)
  M.config = vim.tbl_deep_extend("force", {}, default_config, opts or {})
  require("comment-hide.commands").setup(M.config)
end

M.setup = setup

return M
