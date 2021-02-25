## Phase 1 - Basic Commands

- hjkl: navigation
- wb: word forward and back
- yy: yank
- p: paste
- d: delete
- u/ctrl+r: undo/redo
- v: visual mode
- V: visual line mode
- esc/ctrl+c: normal mode

## Phase 2 - Editing Speed

- o: insert below
- O: insert above
- P: paste above
- a: insert after
- I: insert beginning of line
- A: insert end of line
- /: search, n, N
- ****: search word in cursor, * or n, # or N
- #: seach word in cursor backwards, */n, #N

## Phase 3 - Horizontal Navigation

- f: jump up character, ; to cycle, , to cycle backwards
- t: jump up to character, ; to cycle, , to cycle backwards (dt <char>: delete up to <char>)
- F: backwards jump up character, ; to cycle, , to cycle backwards
- T: backwards jump up to character, ; to cycle, , to cycle backwards
- x: delete char in cursor
- s: delete char in cursor and insert mode
- S: delete line and insert mode
- c: delete and insert mode
- C: delete rest of line and insert mode
- D: delete rest of line

## Phase 4 - Vertical Navigation

- gg/G: go to top/bottom
- :<line>: go to line
- <number_of_lines>jk: go up or down <number_of_lines>
- {}: move up or down a paragraph
- ctrl+u, ctrl+d: move up or down a page
- zz: center current line
- %: jump to matching closing bracket/parenthesis
- <command>+i+<open_and_close_char/w/p>: apply operation to match between open and close char
- <command>+a+<open_and_close_char/w/p>: apply operation to match between open and close char (including brackets)

## Phase 5 - Full on Vim

- ctrl+^: jump betweeen last two files
- ctrl+o: move backwards history
- ctrl+i: move forward history
- m+<key>: set local mark
- m+<capital_key>: set global mark
- ctrl+w+s/:sp: horizontal split
- ctrl+w+v/:vsp: vertical split
- ctrl+w+o: close all buffers except current
- ctrl+w+r: rotate buffers
- J: move line below to current line with a space in between
- U/u: uppercase/lowecase selected
- m+<key>: mark location, access it with '+<key>
- command %s/<query>/replace/gc: search and replace whole file
- command /s/<query>/replace/gc: search and replace selection

## Folding
- za: toggle folding
- zR: open all folds
- zM: close all folds
- zo: open current fold
- zc: close current fold

- h <query>: get help on <query>
