--[[ return { ]]
--[[ { ]]
--[[     dir = "/Users/rhyme/Code/project/Jiangxue/nvim.comment-hide", ]]
--[[     name = "comment-hide", ]]
--[[     dev = true, ]]
--[[     config = function() ]]
--[[       require("comment-hide").setup() ]]
--[[     end, ]]
--[[   } ]]
--[[ } ]]

return {
  --[[ "jiangxue-analysis/nvim.comment-hide", ]]
  dir = "/users/uwu/Code/project/jiangxue/nvim.comment-hide",
  name = "comment-hide",
  lazy = false,
  config = function()
    require("comment-hide").setup({
      gitignore = true,
    })
    vim.keymap.set("n", "<leader>vs", "<cmd>CommentHideSave<CR>", { desc = "Comment: Save (strip comments)" })
    vim.keymap.set("n", "<leader>vr", "<cmd>CommentHideRestore<CR>", { desc = "Comment: Restore from backup" })
  end,
}
