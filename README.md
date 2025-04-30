<img alt="logo" style="float: center;right: 0px" src="https://github.com/user-attachments/assets/fe240bc6-5149-4350-bf5c-5a51ea0bd7e4" width="100" div align=right>
<p></p>


**nvim.command-hide**

The plugin allows you to hide and show comments, and saves them to a specified folder.

#### Why install?

> [!NOTE]
> This is test version, if error and bug, click [issues](https://github.com/jiangxue-analysis/nvim.comment-hide/issues).

You are use [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua

return {
  "jiangxue-analysis/nvim.comment-hide",
  name = "comment-hide",
  lazy = false,
  config = function()
    require("comment-hide").setup()
    vim.keymap.set("n", "<leader>vs", "<cmd>CommentHideSave<CR>", { desc = "Comment: Save (strip comments)" })
    vim.keymap.set("n", "<leader>vr", "<cmd>CommentHideRestore<CR>", { desc = "Comment: Restore from backup" })
  end,
}
```

If you not user [lazy.nvim](https://github.com/folke/lazy.nvim)? God be with you~

#### Why use?

1. **:CommentHideSave**: Create `.annotations/` storage code comments and **Delete the current file comment** move comments to `.annotations`.
2. **:CommentHideRestore**: Restore comments from `.annotations/` to the current file.

If you add the `.annotations/` directory to the `.gitignore` file, anyone without this directory will **be unable to restore your comments**.

#### Public comments

> <img width="130" src="https://github.com/user-attachments/assets/20cd1f83-4fdc-45f4-bb6b-23506c56414c" />
>
> After executing `:CommentHideSave`, **please do not make any changes**, as this will disrupt the line numbers and prevent `:CommentHideRestore` from restoring the comments. 👊🐱🔥

```js
0 /* >>>                                                               
1   This will not be hidden and will be 2 visible to everyone          
2 */                                                                   
3                                                                      
4 const x = 42; // This is a comment                                   
5 /* This is a multi-line                                              
6    comment */                                                        
7 // Another comment                                                   
```

run `:CommentHideRestore`:

```js
1 /* >>>                                                           
2   This will not be hidden and will be 3 visible to everyone      
3 */                                                               
4                                                                  
5 const x = 42;                                                    
```

The `/* */` block remains because comment-hide allows preserving comments using `>>>`. Only block-style `/* */` comments support this feature.

These comments are stored in the `.annotations/` folder at the root directory. You can locate the JSON file by following the current file name.

```json
{"comments":[{"text":"\/\/ This is a comment"},{"text":"\/\/ Another comment"},{"multi":true,"text":"\/* This is a multi-line\n\/* This is a multi-line\n   comment *\/"}],"originalContent":"\/* >>>\n  This will not be hidden and will be visible to everyone\n*\/\n\nconst x = 42; \/\/ This is a comment\n\/* This is a multi-line\n   comment *\/\n\/\/ Another comment","filePath":"Code\/project\/iusx\/test\/hhha.js"}
```

To restore comments, run `:CommentHideRestore`, and the plugin will reinsert comments based on line numbers and positions:

```js
0 /* >>>                                                               
1   This will not be hidden and will be 2 visible to everyone          
2 */                                                                   
3                                                                      
4 const x = 42; // This is a comment                                   
5 /* This is a multi-line                                              
6    comment */                                                        
7 // Another comment                                                   
```

#### Next?

- [ ] : Restore all comments
- [ ] : Hide all file comments to the `.annotations/` directory
- [x] : Fix space placeholders after `:CommentHideSave`.
- [x] : Fix the absolute positioning issue.
- [x] : Customize hiding and showing, for example, comment blocks containing `>>>` will not be hidden

#### Support language

```js
java - lua - rlang - cpp - go - python - ruby - rust - javascript - html - scss - css - typescript - python - tsx -jsx - vue
---
maybe more?
```

#### Support test

```js

```
