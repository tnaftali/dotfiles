"============================================================================
" NEOVIM CONFIGURATION
" ============================================================================

" ============================================================================
" PLUGINS
" ============================================================================

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" tmux
Plug 'christoomey/vim-tmux-navigator' " tmux integration
Plug 'preservim/vimux'

" vim utils
Plug 'tpope/vim-commentary' " comment/uncomment lines with gcc or gc in visual mode
Plug 'Yggdroot/indentLine'
Plug 'ntpeters/vim-better-whitespace'
Plug 'vim-test/vim-test'
Plug 'MunifTanjim/nui.nvim'
" Plug 'VonHeikemen/fine-cmdline.nvim'
Plug 'mbbill/undotree'
Plug 'rhysd/conflict-marker.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'rking/ag.vim'
Plug 'karb94/neoscroll.nvim'

" LSP
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" mix format for elixir files
Plug 'mhinz/vim-mix-format'

" git
Plug 'tpope/vim-fugitive' " the ultimate git helper
Plug 'airblade/vim-gitgutter'
Plug 'kdheepak/lazygit.nvim'

" Themes
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Splash screen
Plug 'eoh-bse/minintro.nvim'

" Tab bar icons
Plug 'sangdol/mintabline.vim'
Plug 'nvim-tree/nvim-web-devicons'

Plug 'elixir-editors/vim-elixir'

" Optional deps
Plug 'hrsh7th/nvim-cmp'
Plug 'HakonHarnes/img-clip.nvim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" ============================================================================
" BASIC VIM SETTINGS
" ============================================================================

" Enable true colors and syntax
if (has("termguicolors"))
  set termguicolors
endif

syntax on

" Core settings
set encoding=UTF-8
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab " Tabs are spaces
set re=1 " Use older version of RegEx for not lagging due to syntax highlight
set number " Show line numbers
set cursorline " Highlight current line
set lazyredraw " Redraw only when we need to
set showmatch " Highlight matching [{()}]
set smartcase
set noswapfile
set nobackup
set nowrap
set listchars=tab:•\ ,trail:•,extends:»,precedes:« " Unprintable chars mapping
set list " Display unprintable characters f12 - switches
set smartindent

" Searching
set ignorecase " Case insensitive searching
set smartcase " Case-sensitive if expresson contains a capital letter
set nolazyredraw " Don't redraw while executing macros

" System integration
set clipboard+=unnamedplus

" Performance
set ttyfast
set updatetime=50

" Folding
set foldmethod=indent
set foldlevel=99

" Paths and splits
set path=.,,**
set splitbelow
set splitright

" Terminal and display
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

" Transparent Neovim
highlight Normal ctermbg=none
highlight NonText ctermbg=none
highlight Normal guibg=none
highlight NonText guibg=none

" ============================================================================
" PLUGIN CONFIGURATIONS
" ============================================================================

" Set space as Leader key
let mapleader = "\<Space>"

" Close tag configuration
let g:closetag_filenames = '*.html,*.html.*'
let g:closetag_xhtml_filenames = '*.html,*.html.*'

" COC Node path
let g:coc_node_path = '/Users/tobi/.nvm/versions/node/v20.18.1/bin/node'

" vim-test configuration
let g:test#preserve_screen = 1
let test#strategy = "neovim"
let test#elixir#exunit#executable = 'source .env && MIX_ENV=test mix test --color'
let g:test#neovim#start_normal = 1 " If using neovim strategy
let g:test#neovim_sticky#kill_previous = 1  " Try to abort previous run
let g:test#preserve_screen = 0  " Clear screen from previous run
let test#neovim_sticky#reopen_window = 1 " Reopen terminal split if not visible

" COC Explorer presets
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

" Conflict marker configuration
let g:conflict_marker_highlight_group = ''
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'

highlight ConflictMarkerBegin guifg=#e06c75
highlight ConflictMarkerOurs guibg=#2e5049
highlight ConflictMarkerSeparator guifg=#e06c75
highlight ConflictMarkerTheirs guibg=#344f69
highlight ConflictMarkerEnd guifg=#e06c75

" GitGutter signs
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '<'

" Tmux navigator
let g:tmux_navigator_disable_when_zoomed = 1

" ============================================================================
" KEY MAPPINGS
" ============================================================================

" COC mappings
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" COC Explorer mappings
nmap <space>ex <Cmd>CocCommand explorer<CR>
nmap <C-_> <Cmd>CocCommand explorer<CR>
nmap <Leader>er <Cmd>call CocAction('runCommand', 'explorer.doAction', 'closest', ['reveal:0'], [['relative', 0, 'file']])<CR>
nmap <space>ed <Cmd>CocCommand explorer --preset .vim<CR>
nmap <space>ef <Cmd>CocCommand explorer --preset floating<CR>
nmap <space>ec <Cmd>CocCommand explorer --preset cocConfig<CR>
nmap <space>eb <Cmd>CocCommand explorer --preset buffer<CR>
nmap <space>el <Cmd>CocList explPresets<CR>

" Telescope mappings
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <silent> <C-p> :lua require('telescope.builtin').find_files()<CR>
nnoremap <leader>fg :lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <silent> <leader>fr :lua require('telescope.builtin').resume()<CR>

" Fine cmdline
" nnoremap <leader>: <cmd>FineCmdline<CR>

" Test mappings
nnoremap <leader>tt :TestNearest<Enter>
nnoremap <leader>tf :TestFile<Enter>

" General mappings
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <leader>gg :LazyGit<CR>

" Edit config files
map <leader>en <cmd>edit ~/.config/nvim/init.vim<cr> " edit ~/.config/nvim/init.vim
map <leader>ez <cmd>e! ~/dotfiles/.zshrc<cr> " edit ~/.zshrc
map <leader>et <cmd>e! ~/dotfiles/.tmux.conf<cr> " edit ~/.tmux.conf
map <leader>eg <cmd>e! ~/.config/ghostty/config<cr> " edit ~/.config/ghostty/config

" Resize panes
nnoremap <silent> <leader>r+ :vertical resize +10<CR>
nnoremap <silent> <leader>r- :vertical resize -10<CR>

nnoremap <leader>oa :Ollama

" Indent with tab and keep selection
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
vnoremap >> >gv
vnoremap << <gv

" Better navigation
nnoremap Y y$
nnoremap n nzzzv
nnoremap N Nzzzv
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

" Terminal mappings
if has('nvim')
  tmap <C-o> <C-\><C-n>
endif

" Tab management
nnoremap <leader>tn :tabnew<cr>
nnoremap <leader>t<Tab> :tabnext<cr>
nnoremap <leader>t<S-Tab> :tabprevious<cr>
nnoremap <leader>tm :tabmove
nnoremap <leader>tc :tabclose<cr>
nnoremap <leader>to :tabonly<cr>
nnoremap <leader>H :tabmove -<CR>
nnoremap <leader>L :tabmove +<CR>
nnoremap H gT
nnoremap L gt

" Utility mappings
nnoremap gV `[v`]
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>
let @o=""

" Disable problematic mappings
map q: <Nop>
nnoremap Q <nop>

" ============================================================================
" AUTOCOMMANDS
" ============================================================================

" Automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Python settings
autocmd Filetype python setlocal ts=2 sw=2 sts=2

" Elixir syntax highlight
autocmd BufNewFile,BufRead *.ex,*.exs set filetype=elixir syntax=elixir
autocmd BufNewFile,BufRead *.eex,*.leex,*.heex set syntax=eelixir
autocmd FileType elixir setlocal commentstring=#\ %s
autocmd BufRead,BufNewFile *test.exs set filetype=elixir

" Javascript settings
autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd FileType javascript setlocal equalprg=js-beautify\ --stdin

" Keep all folds open when a file is opened
augroup OpenAllFoldsOnFileOpen
  autocmd!
  autocmd BufRead * normal zR
augroup END

" JSON settings
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

" Highlight yanked text
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

" Auto trim whitespace
autocmd BufWritePre * :call TrimWhitespace()

" ============================================================================
" FUNCTIONS
" ============================================================================

" Move current tab into the specified direction
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

" Trim whitespace function
fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

" ============================================================================
" COMMANDS
" ============================================================================

" Command abbreviations
cabbrev W w
cabbrev Q q
cabbrev Wa wa
cabbrev WA wa
cabbrev Qa qa
cabbrev QA qa
cabbrev diffv DiffviewOpen
cabbrev mf MixFormat

" Custom commands
command Format :%!js-beautify -s 2

" ============================================================================
" LUA CONFIGURATIONS
" ============================================================================

lua << EOF
-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "elixir", "lua", "vim", "vimdoc", "query", "javascript", "elm" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = false,
  },
}

-- Catppuccin theme configuration
require("catppuccin").setup({
  flavour = "auto",
  transparent_background = true, -- disables setting the background color.
  background = {
    light = "latte",
    dark = "mocha",
  },
  show_end_of_buffer = false,
  term_colors = false,
  dim_inactive = {
    enabled = false,
    shade = "dark",
    percentage = 0.15,
  },
  coc_nvim = true,
  no_italic = false,
  no_bold = false,
  no_underline = false,
  styles = {
    comments = { "italic" },
    conditionals = { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  },
  color_overrides = {},
  custom_highlights = {},
  default_integrations = true,
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
    notify = false,
    mini = {
        enabled = true,
        indentscope_color = "",
    },
  },
})

-- Setup must be called before loading
vim.cmd.colorscheme "catppuccin"

-- Lualine configuration
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {{'filename', path = 1 }},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {{'filename', path = 1 }},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- Minintro setup
require('minintro').setup()

-- Neoscroll setup
require('neoscroll').setup({
  mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb'}
})
EOF
