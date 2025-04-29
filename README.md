<img alt="logo" style="float: center;right: 0px" src="https://github.com/user-attachments/assets/fe240bc6-5149-4350-bf5c-5a51ea0bd7e4" width="100" div align=right>
<p></p>


**nvim.command-hide**

The plugin allows you to hide and show comments, and saves them to a specified folder.

#### Why use?

1. **:CommentHideSave**: Create `.annotations/` storage code comments and **Delete the current file comment** move comments to `.annotations`.
2. **CommentHideRestore**: Restore comments from `.annotations/` to the current file.

If you add the `.annotations/` directory to the `.gitignore` file, anyone without this directory will **be unable to restore your comments**.

#### Public comments

> <img width="130" src="https://github.com/user-attachments/assets/20cd1f83-4fdc-45f4-bb6b-23506c56414c" />
>
> After executing `CommentHideSave`, **please do not make any changes**, as this will disrupt the line numbers and prevent `Restore Comments` from restoring the comments. 👊🐱🔥

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

run `Save Comments`:

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
{
  "originalContent": "/* >>>\n  This will not be hidden and will be visible to everyone\n*/\n\nconst x = 42; // This is a comment\n/* This is a multi-line\n   comment */\n// Another comment",
  "comments": [
    {
      "text": "// This is a comment",
      "line": 4,
      "start": 83,
      "end": 103
    },
    {
      "text": "/* This is a multi-line\n   comment */",
      "line": 5,
      "start": 104,
      "end": 141
    },
    {
      "text": "// Another comment",
      "line": 7,
      "start": 142,
      "end": 160
    }
  ],
  "filePath": "test/hhha.js"
}
```

To restore comments, run `Restore Comments`, and the plugin will reinsert comments based on line numbers and positions:

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

[-]: Restore all comments

[-]: Hide all file comments to the `.annotations/` directory

[√]: Fix space placeholders after `Save Comments`.

[-]: Fix the absolute positioning issue.

[√]: Customize hiding and showing, for example, comment blocks containing `>>>` will not be hidden
- only support `/* */` comments style

#### Support language

```js
java - rlang - cpp - go - python - ruby - rust - javascript - html - scss - css - typescript - python - tsx -jsx - vue
---
maybe more?
```

#### Support comments style

```js
// Hello

# Hello

/*
  Hello
*/

<!-- Hello -->

---

[Why no support ''' ?]
I am lazy

---

[example:]

{
  // image
}
{
  /* {isValidImageIcon
      ? <img src={imageUrl} className="w-full h-full rounded-full" alt="answer icon" />
      : (icon && icon !== '') ? <em-emoji id={icon} /> : <em-emoji id='🤖' />
    } */
}

[run `save comments`:]

{

}
{

}

```
