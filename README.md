### nvim.command-hide

The plugin allows you to hide and show comments, and saves them to a specified folder.

![](demo.gif)

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
    require("comment-hide").setup({
      gitignore = true, -- Automatically add .annotations/ to .gitignore.
    })
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

#### Support language / framework

```js
// Support: Java, Lua, R, C++, Go, Python, Ruby, Rust,  
            JavaScript, HTML, SCSS, CSS, TypeScript,    
            TSX, JSX, Vue, Scala, Bash                        
---
maybe more?
```

For comment support, please refer to [comment_patterns](https://github.com/jiangxue-analysis/nvim.comment-hide/blob/main/lua/comment-hide/utils.lua), as each language has many different comment styles, so not all of them may be supported.

```
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
  ……
}
```

#### Example

```js
[RUST]
1 // COMMENT                        | 1 fn main() {                                                         
2 fn main() {                       | 2                                                                     
3     /*                            | 3     println!("// Hello, World!");                                   
4      * COMMENT                    | 4 }                                                                   
5      */                           | 5                                                                     
6     println!("// Hello, World!"); | 6 fn main() {                                                         
7 }                                 | 7                                                                     
8 // COMMENT                        | 8     println!("Hello, World! /* test */");                           
9                                   | 9 }                                                                   
10 fn main() {                                                                                              
11     /*                                                                                                   
12      * COMMENT                                                                                           
13      */                                                                                                  
14     println!("Hello, World! /* test */"); // TEST                                                        
15 }                                                                                                        



[SCSS]
1  /* Set default margin and font for the body */                           
2  body {                            | 1  body {                            
3    margin: 0;                      | 2    margin: 0;                      
4    font-family: Arial, sans-serif; | 3    font-family: Arial, sans-serif; 
5    background-color: #f5f5f5;      | 4    background-color: #f5f5f5;      
6    h1 {                            | 5    h1 {                            
7      color: #333; // TEST          | 6      color: #333;                  
8      text-align: center;           | 7      text-align: center;           
9      margin-top: 40px;             | 8      margin-top: 40px;             
10   }                               | 9    }                               
11 }                                 | 10 }                                 



[TS]
1  // This is a single-line comment                                                          
2  const commentRegex = /\/\/.*|\/\*[\s\S]*?\*\/|<!--[\s\S]*?-->|#.*$/gm;                    
3                                                                                            
4  /* Multi-line   | 1 const commentRegex = /\/\/.*|\/\*[\s\S]*?\*\/|<!--[\s\S]*?-->|#.*$/gm;
5     comment */   | 2                                                                       
6                  | 3 const regex = /\/\*[\s\S]*?\*\/|\/\/.*$/gm;                           
7                                                                                            
8  // String with // insideconst str = "This is a // string";                                
9  const regex = /\/\*[\s\S]*?\*\/|\/\/.*$/gm; // Regex with comment-like content            

[TSX]
1  {            | 1 {                                                                      
2    // image   | 2                                                                        
3  }            | 3 }                                                                      
4  {                                                                                       
5    /* {isValidImageIcon                                                                  
6        ? <img src={imageUrl} className="w-full h-full rounded-full" alt="answer icon" /> 
7        : (icon && icon !== '') ? <em-emoji id={icon} /> : <em-emoji id='🤖' />            
8      } */                                                                                
9  }                                                                                       
```
