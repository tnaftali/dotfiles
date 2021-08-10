" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'kien/ctrlp.vim' " fuzzy find files
Plug 'scrooloose/nerdtree' " file drawer, open with :NERDTreeToggle
Plug 'benmills/vimux'
Plug 'tpope/vim-fugitive' " the ultimate git helper
Plug 'tpope/vim-commentary' " comment/uncomment lines with gcc or gc in visual mode
Plug 'elixir-editors/vim-elixir'
Plug 'rking/ag.vim'
Plug 'pangloss/vim-javascript'
Plug 'jelera/vim-javascript-syntax'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'christoomey/vim-tmux-navigator'
Plug 'jacoborus/tender.vim'
Plug 'airblade/vim-gitgutter'
Plug 'patstockwell/vim-monokai-tasty'
Plug 'crusoexia/vim-monokai'
Plug 'slashmili/alchemist.vim'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'vim-test/vim-test'
Plug 'stefandtw/quickfix-reflector.vim'
Plug 'mhinz/vim-mix-format'
Plug 'ntpeters/vim-better-whitespace'
" Plug 'psliwka/vim-smoothie'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" If you have vim >=8.0 or Neovim >= 0.1.5
if (has("termguicolors"))
 set termguicolors
endif

colorscheme monokai

set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab " Tabs are spaces
set re=1 " Use older version of RegEx for not lagging due to syntax highlight
set number " Show line numbers
" set relativenumber
set cursorline          " highlight current line
set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]
set smartcase
set noswapfile
set nobackup
set nowrap
set listchars=tab:•\ ,trail:•,extends:»,precedes:« " Unprintable chars mapping
set list          " Display unprintable characters f12 - switches
set smartindent
" Searching
set ignorecase " case insensitive searching
set smartcase " case-sensitive if expresson contains a capital letter
set nolazyredraw " don't redraw while executing macros
set clipboard+=unnamedplus
set ttyfast " faster redrawing
set foldmethod=indent
set path=.,,**
set splitbelow
set splitright
set foldlevel=99

" Transparent Neovim
highlight Normal ctermbg=none
highlight NonText ctermbg=none
highlight Normal guibg=none
highlight NonText guibg=none

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50
" set iskeyword-=_

" Automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Leader key to space
let mapleader = "\<Space>"

" Plugins

" project replace word
nnoremap <leader>prw :CocSearch <C-R>=expand("<cword>")<CR><CR>
let g:coc_disable_startup_warning = 1

let g:test#preserve_screen = 1
let test#strategy = "neovim"
let test#elixir#exunit#executable = 'source .env && mix test'

nmap <leader>pf :CtrlP<CR>

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)

" bind K to grep word under cursor
nnoremap M :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

nnoremap <silent> K :call <SID>show_documentation()<CR>

nnoremap <leader>nt :NERDTreeToggle<Enter>
nnoremap <silent> <leader>pv :NERDTreeFind<CR>

nnoremap <leader>tn :TestNearest<Enter>
nnoremap <leader>tf :TestFile<Enter>

nnoremap <leader><space> :nohlsearch<CR>

command! W write
command! Q quit

if has('nvim')
  tmap <C-o> <C-\><C-n>
endif

" " keep selection after indent
" :vnoremap < <gv
" :vnoremap > >gv

" indent with tab and shift tab and keep selection after indent
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

let g:NERDTreeQuitOnOpen=0 " close NERDTree after a file is opened
let NERDTreeShowHidden=1 " show hidden files in NERDTree

" CtrlP settings
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_working_path_mode = 0

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" air-line
let g:airline_powerline_fonts = 1

" set airline theme
let g:airline_theme='monokai_tasty'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

" Use fontawesome icons as signs
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '<'

" Maintain tmux zoom mode when navigating between vim panes
let g:tmux_navigator_disable_when_zoomed = 1

" edit config files
map <leader>ev :e! ~/dotfiles/.vimrc<cr> " edit ~/.vimrc
map <leader>en :e! ~/.config/nvim/init.vim<cr> " edit ~/.config/nvim/init.vim
map <leader>ez :e! ~/dotfiles/.zshrc<cr> " edit ~/.zshrc
map <leader>et :e! ~/dotfiles/.tmux.conf<cr> " edit ~/.tmux.conf
map <leader>ec :e! ~/dotfiles/vim.md<cr> "
map <leader>ek :e! ~/.config/kitty/kitty.conf<cr> "
map <leader>ei :e! ~/.config/i3/config<cr> "
map <leader>eo :e! ~/.config/i3blocks/i3blocks.conf<cr> "
map <leader>ee :e! ~/projects/betafolio/.env<cr> "

" resize pane
nnoremap <silent> <leader>r+ :vertical resize +10<CR>
nnoremap <silent> <leader>r- :vertical resize -10<CR>

" highlight last inserted text
nnoremap gV `[v`]

" remove all trailing whitespace by pressing F5
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Make Y behave like D & C
nnoremap Y y$

" Keep cursor centered while moving through file
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z
nnoremap <c-d> <c-d>zz
nnoremap <c-u> <c-u>zz
nnoremap { {zz
nnoremap } }zz

" Undo break points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap [ [<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" Jumplist mutations
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

" Moving text
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
inoremap <C-j> <esc>:m .+1<CR>==
inoremap <C-k> <esc>:m .-2<CR>==
nnoremap <leader>k :m .-2<CR>==
nnoremap <leader>j :m .+1<CR>==

" python
autocmd Filetype python setlocal ts=2 sw=2 sts=2

" elixir syntax highlight
autocmd BufNewFile,BufRead *.ex,*.exs set filetype=elixir syntax=elixir
autocmd BufNewFile,BufRead *.eex,*.leex set syntax=eelixir
autocmd FileType elixir setlocal commentstring=#\ %s

" keep all folds open when a file is opened
augroup OpenAllFoldsOnFileOpen
  autocmd!
  autocmd BufRead * normal zR
augroup END

augroup jsonshow
  au!
  au FileType json set conceallevel=0
  au FileType json let g:json_conceal="adgms"
  au FileType json hi Conceal guibg=White guifg=DarkMagenta
augroup END

au! BufRead,BufNewFile *.json set filetype=json

augroup json_autocmd
  autocmd!
  autocmd FileType json set autoindent
  autocmd FileType json set formatoptions=tcq2l
  autocmd FileType json set textwidth=78 shiftwidth=2
  autocmd FileType json set softtabstop=2 tabstop=8
  autocmd FileType json set expandtab
  autocmd FileType json set foldmethod=syntax
augroup END

fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

autocmd BufWritePre * :call TrimWhitespace()

" Differentiate active pane
augroup BgHighlight
  autocmd!
  autocmd WinEnter * set number
  autocmd WinLeave * set nonumber
augroup END

" Dim inactive windows using 'colorcolumn' setting
" This tends to slow down redrawing, but is very useful.
" Based on https://groups.google.com/d/msg/vim_use/IJU-Vk-QLJE/xz4hjPjCRBUJ
" XXX: this will only work with lines containing text (i.e. not '~')
" from
" if exists('+colorcolumn')
"   function! s:DimInactiveWindows()
"     for i in range(1, tabpagewinnr(tabpagenr(), '$'))
"       let l:range = ""
"       if i != winnr()
"         if &wrap
"          " HACK: when wrapping lines is enabled, we use the maximum number
"          " of columns getting highlighted. This might get calculated by
"          " looking for the longest visible line and using a multiple of
"          " winwidth().
"          let l:width=256 " max
"         else
"          let l:width=winwidth(i)
"         endif
"         let l:range = join(range(1, l:width), ',')
"       endif
"       call setwinvar(i, '&colorcolumn', l:range)
"     endfor
"   endfunction
"   augroup DimInactiveWindows
"     au!
"     au WinEnter * call s:DimInactiveWindows()
"     au WinEnter * set cursorline
"     au WinLeave * set nocursorline
"   augroup END
" endif
