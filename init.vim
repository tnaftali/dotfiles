" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'kien/ctrlp.vim' " fuzzy find files
Plug 'benmills/vimux'
Plug 'tpope/vim-fugitive' " the ultimate git helper
Plug 'tpope/vim-commentary' " comment/uncomment lines with gcc or gc in visual mode
Plug 'elixir-editors/vim-elixir'
Plug 'rking/ag.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'christoomey/vim-tmux-navigator'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-mix-format'
Plug 'ntpeters/vim-better-whitespace'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'vim-test/vim-test'
Plug 'jacoborus/tender.vim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" If you have vim >=8.0 or Neovim >= 0.1.5
if (has("termguicolors"))
 set termguicolors
endif

syntax on
colorscheme tender

set encoding=UTF-8
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab " Tabs are spaces
set re=1 " Use older version of RegEx for not lagging due to syntax highlight
set number " Show line numbers
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

let g:closetag_filenames = '*.html,*.html.*'
let g:closetag_xhtml_filenames = '*.html,*.html.*'

" let g:coc_disable_startup_warning = 1

let g:test#preserve_screen = 1
let test#strategy = "neovim"
let test#elixir#exunit#executable = 'source .env && MIX_ENV=test mix test --color'

let g:coc_node_path = '/Users/tobi/.nvm/versions/node/v16.16.0/bin/node'

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
" inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

nmap <space>ex <Cmd>CocCommand explorer<CR>
nmap <Leader>er <Cmd>call CocAction('runCommand', 'explorer.doAction', 'closest', ['reveal:0'], [['relative', 0, 'file']])<CR>

let g:coc_explorer_global_presets = {
\   '.vim': {
\     'root-uri': '~/.vim',
\   },
\   'cocConfig': {
\      'root-uri': '~/.config/coc',
\   },
\   'tab': {
\     'position': 'tab',
\     'quit-on-open': v:true,
\   },
\   'tab:$': {
\     'position': 'tab:$',
\     'quit-on-open': v:true,
\   },
\   'floating': {
\     'position': 'floating',
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingTop': {
\     'position': 'floating',
\     'floating-position': 'center-top',
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingLeftside': {
\     'position': 'floating',
\     'floating-position': 'left-center',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingRightside': {
\     'position': 'floating',
\     'floating-position': 'right-center',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'simplify': {
\     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
\   },
\   'buffer': {
\     'sources': [{'name': 'buffer', 'expand': v:true}]
\   },
\ }

" Use preset argument to open it
nmap <space>ed <Cmd>CocCommand explorer --preset .vim<CR>
nmap <space>ef <Cmd>CocCommand explorer --preset floating<CR>
nmap <space>ec <Cmd>CocCommand explorer --preset cocConfig<CR>
nmap <space>eb <Cmd>CocCommand explorer --preset buffer<CR>

" List all presets
nmap <space>el <Cmd>CocList explPresets<CR>

" bind M to grep word under cursor
nnoremap M :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

nnoremap <silent> K :call <SID>show_documentation()<CR>

nnoremap <leader>tt :TestNearest<Enter>
nnoremap <leader>tf :TestFile<Enter>

nnoremap <leader><space> :nohlsearch<CR>

cabbrev W w
cabbrev Q q
cabbrev Wa wa
cabbrev WA wa
cabbrev Qa qa
cabbrev QA qa
cabbrev diffv DiffviewOpen
cabbrev mf MixFormat

command Format :%!js-beautify -s 2

if has('nvim')
  tmap <C-o> <C-\><C-n>
endif

" indent with tab and shift tab and keep selection after indent
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

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

" Sane Ignore For ctrlp
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$|vendor\|\.hg$\|\.svn$\|\.yardoc\|public\/images\|public\/system\|data\|log\|tmp$|_build\|deps\|node_modules\|static\|cover\',
  \ 'file': '\.exe$\|\.so$\|\.dat$'
  \ }

if exists("g:ctrlp_user_command")
  unlet g:ctrlp_user_command
endif
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/vendor,*/deps/*,*/_build/*,*/node_modules/*,*/static/*,*/cover/*

" air-line
let g:airline_powerline_fonts = 1

" set airline theme
let g:airline_theme='tender'

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
map <leader>ee :e! ~/Projects/core/.local.env<cr> "

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
" nnoremap J mzJ`z
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

" Better tab experience
map <leader>tn :tabnew<cr>
map <leader>t<Tab> :tabnext<cr>
map <leader>t<S-Tab> :tabprevious<cr>
map <leader>tm :tabmove
map <leader>tc :tabclose<cr>
map <leader>to :tabonly<cr>
map <leader>H :tabmove -<CR>
map <leader>L :tabmove +<CR>

" Move current tab into the specified direction.
"
" @param direction -1 for left, 1 for right.
function! TabMove(direction)
    " get number of tab pages.
    let ntp=tabpagenr("$")
    " move tab, if necessary.
    if ntp > 1
        " get number of current tab page.
        let ctpn=tabpagenr()
        " move left.
        if a:direction < 0
            let index=((ctpn-1+ntp-1)%ntp)
        else
            let index=(ctpn%ntp)
        endif

        " move tab page.
        execute "tabmove ".index
    endif
endfunction

" Add keyboard shortcuts

nnoremap H gT
nnoremap L gt

map q: <Nop>
nnoremap Q <nop>

" Python
autocmd Filetype python setlocal ts=2 sw=2 sts=2

" Elixir syntax highlight
autocmd BufNewFile,BufRead *.ex,*.exs set filetype=elixir syntax=elixir
autocmd BufNewFile,BufRead *.eex,*.leex,*.heex set syntax=eelixir
autocmd FileType elixir setlocal commentstring=#\ %s

" Javascript
autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd FileType javascript setlocal equalprg=js-beautify\ --stdin

" Keep all folds open when a file is opened
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
