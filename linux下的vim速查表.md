---
title: "linux vim 速查表"
date: "2020-01-22"
categories: 
    - "技术"
tags: 
    - "linux"
    - "vim"
toc: false
original: false
---

Vim is great, but learning to drive it is a long term process. This is my cheat sheet for vanilla installations.
vim 非常棒, 但是学习去如何使用它是一个很长的过程, 这是我的 vim 速查手册.

## 移动

### 基本动作
向左移动: h
向下移动: j
向上移动: k
向右移动: l

#### 例子
向左移动4个字符: 4h
向下两行: 2j
向上三行: 3k
向右移动6个字符: 6l

### 字符移动
下一个单词: w
上一个单词: b
下一个全: W
Previous whole-word: B
End of the current word: e
examples
Next 2 normal-words: 2w
Previous 2 normal-words: 4b
Next 2 whole-words: 3W
Previous 3 whole-words: 3B

fast movements
Beginning of the file: gg
End of the file: G
Jump to line number: {Line number}G; {Line number}gg
Next paragraph: }
Previous paragraph: {
examples
Jump to line number #123: 123G
Jump to line number #123: 123gg
Next 3rd paragraph: 3}
Previous 3rd paragraph: 3{
inline search
Jump to next character in line: f
Jump to previous character in line: F
Jump to next character in line, cursor 1 char before occurrence: t
Jump to previous character in line, cursor 1 char after occurrence: T
Repeat last jump to character (f): ;
Repeat last jump to character (f) backward: ,
examples
Search the 2nd ‘p’ forward in line: f2p
Search the 2nd ‘p’ backwards in line: F2p
visual mode
Toggle going between first and last characters of selection in visual mode: o
Toggle going between first and last characters of selection on current line in visual mode: O
change list
Navigate to previous change: g;
Navigate to next change: g,
Listing previous changes: :changes
jumps
Navigate to previous jump: <c-O>
Navigate to next jump: <c-I>
Listing previous jumps: :jumps
editing
basics
Insert: i
Append: a
Delete: x
Delete: d{Motion}
Undo changes: u
Change: c{Motion}
Paste after: p
Paste before: P
Yanking: y{Motion}
examples
Delete word: dw
Delete word backwards: db
Delete 2 lines: 2dd
Delete closest tag: di<
Change 3 lines: 3dd
Change text within closest double quotes in line: ci»
Yanking 1 char: yl
Yanking 3 chars: 3yl
Yanking 1 line: Y
Yanking 2 lines: 2Y
advanced stuff
Insert text at the beginning of the current line: I
Insert text at the end of the current line: A
search and replace
search
Simple search: /
Simple Close backwards: ?
Jump to next occurence of word under cursor: *
Jump to previous occurence of word under cursor: #
Jump to matching curly brace, parantheses or bracket under the cursor: %
Hide search highlights: :noh
examples
Regular expressions search for finding any character followed by a vowel: //.[aeiou]
Delete everything up to a search ‘fire’ term: d/fire
replace
Replace first ‘Amber’ with ‘Ember’ in line: :s/Amber/Ember
Replace all ‘Amber’ with ‘Ember’ in line: :s/Amber/Ember/g
Replace all ‘Amber’ with ‘Ember’ in file: :%s/Amber/Ember/g
Replace a character: r
Enable replace mode: R
examples
Replace all ‘router’ with ‘dispatcher’ in method in visual mode with confirmation: v%:‘<, >’s/router/dispatcher/gc
Replace using last search: :%s//replaceText/g
Searching for text starting with a non-space, but the non-space excluded: /[^ ]\zs(
delete
Delete first line that matches expression: :s/expression/d
examples
Delete all lines except that matches expression: :g!/expression/d
Delete all lines except that matches expression (with shortcut): :v/expression/d
advanced stuff
Very magic mode (Most usual expression engine): \v
macros
Record empty command list into macro into register A: qaq
Replay macro from register A: @a
examples
Record macro into register a, delete tag around text in line and go to next line: qadf>f<d$jq
Replaying last macro 240 times: 240@a
advanced movements
jumping to positions
Jump half a screen down: <c-d>
Jump half a screen up: <c-u>
Jump full screen forward: <c-f>
Jump full screen backwards: <c-b>
Jump top of the current screen: H
Jump middle of the current screen: M
Jump last line of the current screen: L
moving the screen
Move current line to top of the screen: zt
Move current line to bottom of the screen: zb
Move current line to middle of the screen: zz
navigating wrapped lines
Go down a visual line (in wrapped lines): gj
Go to the beginning of the current visual line (in wrapped lines): g0
markers
Mark a line into register B: mb
Go to registered marker B: ‘b
Go back to point where you jumped to marker from: “
command line
List files from current directory :!ls
Write date into current file: :read !date
Using selection of Visual mode as input for script: (-c: compile, -s: standard input, -p: in place) :‘<,‘>!coffee -c -s -p
buffers
pure buffer commands
List buffers: :ls
Next buffer: :bn
Previous buffer: :bp
Go to buffer #12: :b12
Delete current buffer: :bd
Delete buffer #12: :bd12
New buffer: :enew
Switch between current and last buffer: <c-^>
handling files
Writing buffer to disk: :w
Force writing buffer to disk: :w!
Writing all buffers to disk: :wa
Writing buffer to disk as filename: :w filename
Save file as filename: :saveas filename
Set file type: :set ft=filetype
new comment on the top of our 4 buffers
Create macro in register A: qa
Jump to top of the file: G
Add new line at top: O
Add comment: # My first comment
Save file: :w
Next buffer: :bn
Run macro: @a
Run macro 2 more times: 2@
windows and tabs
windows
split windows
Open (file in) horizontal split :split [filename]; :sp [filename]
Open (file in) vertical split: :vpspit [filename]; :vsp [filename]
Open buffer in horizontal split window: :sb3
Open buffer in vertical split window: :vert sb3
moving around
Navigate to window to the left: <c-w>h
Navigate to window to the bottom: <c-w>j
Navigate to window to the top: <c-w>k
Navigate to window to the right: <c-w>l
Move the current window to the left: <c-w>H
Move the current window to the bottom: <c-w>J
Move the current window window to the top: <c-w>K
Move the current window to the right: <c-w>L
resizing
Make the current window 1 row higher: <c-w>+
Make the current window 1 row shorter: <c-w>-
Make the current window 1 column wider: <c-w>>
Make the current window 1 column narrower: <c-w><
examples
5 rows higher: <c-w>5+
5 rows shorter: <c-w>5-
5 columns wider: <c-w>5>
5 columns narrower: <c-w>5<
Make windows on current tab as equal as possible: <c-w>=
miscellaneous
Close all windows except the currently active one: :on
tabs
Open file on new tab: tabedit filename; :tabe filename
Next tab: gt
Previous tab: gT
Move to tab #13: 13gt
Close the current tab page and all its windows: :tabc
Close all tabs except the currently active one: :tabo
Move current tab to the end: :tabmove
Move current tab to the beginning: :tabmove 0
Move current tab to be the second tab: :tabmove 1
indents and folds
indents
Indent current line: >>
Unindent current line: <<
Indent current lines: 3>>
Unndent current lines: 3<<
Indent in insert mode: <c-T>
Unindent in insert mode: <c-D>
Indent selected lines in visual mode 6 times: 6>
Unindent selected lines in visual mode 6 times: 6<
mappings
basics
Creating a new mapping:

:map ,rs :!bundle exec rspec<cr>

,rs will execute !bundle exec rspec now.

text objects
object types
Words: w
Paragraph: p
Sentence: s
Tag: t
Curly braces: {
Brackets: [
Parantheses: (
Double quotes: «
Quotes: ‘
Backticks: `
selecting types
Inside: i
Around: a
examples
Change content of first Double quotes on line: ci»
Delete current paragraph plus the following empyt lines: dap
registers
List registers: :registers; :reg, :registers
Read current line into register A: «ayy
Append the current line to a register A: «Ayy
Delete text, but save it to register A: «add
Paste the contents of register A: «ap
Paste the contents of register A above current line: «aP
Paste last yanked text: «0p
Unnamed register: «
Numbered registeres: 0-9
Small delete register: -
Filename register: %
Search register: /
advanced register usage
Execute a line as a macro via the unnamed register: 0y$@»
Delete a row, then a second one, then paste the first one: dd»_ddp
Insert «4» after the cursor with the expression register: »=2*2p
actions in insert mode
Vim-style backspace: <c-h>
Deleting word backwards: <c-w>
Delete line backwards from current position: <c-u>
Insert literal character: <c-u>
Insert unicode character: <c-u><Unicode Character Id>
Leaving insert mode for one command: <c-o>
Insert stuff from register A: <c-r>A
Using the expression register: <c-r>=r{Expression}
Insert something at the beginning of the current line: I
Autoindent: =
random actions and motions
Perform the last action again: .
Undo: u
Redo: <c-r>
Open a file under the cursor: gf
Join current line with the following one by a space: J
Look up manual for command/program under the cursor: K
Increment number under cursor: <c-a>
Decrement number under cursor: <c-x>
Enforces spaces or tabs (depending on expandtab setting): :retab!
Reveal current directory: :pwd
Change current directory: :cd
Insert newText in 3 consequtive rows at once: <c-V>2jInewText<Esc>
Shortcut for copy: :t
examples
Increment all the itemnum attributes in an XML file: :g/itemnum/normal 20^A
Copy line #9 to next line standing on line #16: :9Gyy:16Gp, :9Gyy<c-o>p, :9yankp, :9yp, :9copy16, :9t16, :9t., -7t.
Copy 3 lines from #9 to next line standing on line #16: :9,11t.
explorer (netrw)
netrw module usually comes with vim.

window
Open Explorer in current window at current working directory: :e.
Open Explorer in split window at current working directory: :sp.
Open Explorer in vertical split window at current working directory: :vs.
Open Explorer at directory of current file: :Explorer
Open Explorer in vertical split window at directory of current file: :Vex
manipulating file system
Create a new file: %
Create a new directory: d
Rename a file/directory under the cursor: R
Delete the file/directory under the cursor: D
spell checking
Spell checking is built in into vim.

enabling
Enabling spellcheking: :set spell
Setting British English spelling: :spellang=en_gb
Accepting all English spellings (default): :spellang=en
Setting language for window: :windo set spellang=en
Setting language for buffer: :bufdo set spellang=en
navigation
Next misspelling: ]s
Previous misspelling: [s
Spelling suggestions: z=
Adding word to known words: zg
Removing word from known words: zw
Undoing adding word to known words: zug
Undoing removing word to known words: zuw
command window
Open command history from Normal mode: q:
Open command history from Command mode: Ctrl+F
Open search history for forward search: q/
Open search history for backward search: q?
settings
pasting
Enable pasting without automatic indentation: :set paste
Disable pasting without automatic indentation: :set nopaste
searching
Show matches while typing: :set incsearch
Highlight search results: :set hlsearch
Disable highlighting search results: :set nohlsearch

> 作者：peter
> 链接：https://peteraba.com/blog/my-vanilla-vim-cheatsheet/
