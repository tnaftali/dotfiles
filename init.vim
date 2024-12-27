" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
" tmux
Plug 'christoomey/vim-tmux-navigator' " tmux integration
Plug 'preservim/vimux'

" vim utils
Plug 'tpope/vim-commentary' " comment/uncomment lines with gcc or gc in visual mode
Plug 'Yggdroot/indentLine'
Plug 'ntpeters/vim-better-whitespace'
Plug 'vim-test/vim-test'
Plug 'MunifTanjim/nui.nvim'
Plug 'VonHeikemen/fine-cmdline.nvim'
Plug 'mbbill/undotree'
Plug 'rhysd/conflict-marker.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'rking/ag.vim'
Plug 'karb94/neoscroll.nvim'

" Copilot
Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }

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

" Avante plugin using Claude
" Deps
Plug 'stevearc/dressing.nvim'

" Optional deps
Plug 'hrsh7th/nvim-cmp'
Plug 'HakonHarnes/img-clip.nvim'
Plug 'zbirenbaum/copilot.lua'

Plug 'yetone/avante.nvim', { 'branch': 'main', 'do': 'make' }

" Old plugins
" Plug 'kien/ctrlp.vim' " fuzzy find files
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
" Plug 'sindrets/diffview.nvim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" If you have vim >=8.0 or Neovim >= 0.1.5
if (has("termguicolors"))
  set termguicolors
endif

syntax on

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
set clipboard+=unnamedplus
" Faster redrawing
set ttyfast
set foldmethod=indent
set path=.,,**
set splitbelow
set splitright
set foldlevel=99

let &t_ZH="\e[3m"
let &t_ZR="\e[23m"

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

" Set space as Leader key
let mapleader = "\<Space>"

" Plugins

let g:closetag_filenames = '*.html,*.html.*'
let g:closetag_xhtml_filenames = '*.html,*.html.*'

" let g:coc_disable_startup_warning = 1

let g:test#preserve_screen = 1
let test#strategy = "neovim"
" let test#strategy = "vimux"
let test#elixir#exunit#executable = 'source .env && MIX_ENV=test mix test --color'
let g:test#neovim#start_normal = 1 " If using neovim strategy
let g:test#neovim_sticky#kill_previous = 1  " Try to abort previous run
let g:test#preserve_screen = 0  " Clear screen from previous run
let test#neovim_sticky#reopen_window = 1 " Reopen terminal split if not visible

let g:coc_node_path = '/Users/tobi/.nvm/versions/node/v16.16.0/bin/node'

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)

" Insert autocomplete selection instead of enter
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

nmap <space>ex <Cmd>CocCommand explorer<CR>
nmap <C-_> <Cmd>CocCommand explorer<CR>
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

" Disable the default highlight group
let g:conflict_marker_highlight_group = ''

" Include text after begin and end markers
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'

highlight ConflictMarkerBegin guifg=#e06c75
highlight ConflictMarkerOurs guibg=#2e5049
highlight ConflictMarkerSeparator guifg=#e06c75
highlight ConflictMarkerTheirs guibg=#344f69
highlight ConflictMarkerEnd guifg=#e06c75

" Use preset argument to open it
nmap <space>ed <Cmd>CocCommand explorer --preset .vim<CR>
nmap <space>ef <Cmd>CocCommand explorer --preset floating<CR>
nmap <space>ec <Cmd>CocCommand explorer --preset cocConfig<CR>
nmap <space>eb <Cmd>CocCommand explorer --preset buffer<CR>

" List all presets
nmap <space>el <Cmd>CocList explPresets<CR>

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
" Set keymap for opening Telescope find_files with <C-p>
nnoremap <silent> <C-p> :lua require('telescope.builtin').find_files()<CR>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fg :lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>

nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Set keymap for resuming Telescope
nnoremap <silent> <leader>fr :lua require('telescope.builtin').resume()<CR>

" fine-cmdline
" nnoremap <CR> <cmd>FineCmdline<CR>
" nnoremap <S-CR> <cmd>FineCmdline<CR>
nnoremap : <cmd>FineCmdline<CR>

" Bind M to grep word under cursor
" nnoremap M :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
" nnoremap <silent> K :call <SID>show_documentation()<CR>

" Run unit tests
nnoremap <leader>tt :TestNearest<Enter>
nnoremap <leader>tf :TestFile<Enter>

nnoremap <leader><space> :nohlsearch<CR>

" setup mapping to call :LazyGit
nnoremap <leader>gg :LazyGit<CR>

" setup mapping to Copilot panel
nnoremap <leader>cp :Copilot panel<CR>
nnoremap <leader>cc :CopilotChat <CR>

" Replace 'cce' with 'CopilotChatExplain'
iabbrev cce CopilotChatExplain
iabbrev cco CopilotChatOptimize

" Replace 'cce' with 'CopilotChatExplain' in command mode
cabbrev cce CopilotChatExplain
cabbrev cco CopilotChatOptimize
cabbrev ccd CopilotChatDocs

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

" Indent with tab and shift tab and keep selection after indent
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

vnoremap >> >gv
vnoremap << <gv

" Use FontAwesome icons as signs
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '<'

" Maintain tmux zoom mode when navigating between vim panes
let g:tmux_navigator_disable_when_zoomed = 1

" Edit config files
map <leader>en :e! ~/.config/nvim/init.vim<cr> " edit ~/.config/nvim/init.vim
map <leader>ez :e! ~/dotfiles/.zshrc<cr> " edit ~/.zshrc
map <leader>et :e! ~/dotfiles/.tmux.conf<cr> " edit ~/.tmux.conf

" Resize pane
nnoremap <silent> <leader>r+ :vertical resize +10<CR>
nnoremap <silent> <leader>r- :vertical resize -10<CR>

" Highlight last inserted text
nnoremap gV `[v`]

" Remove all trailing whitespace by pressing F5
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

let @o=""

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
" Focus on the tab on the left
nnoremap H gT
" Focus on the tab on the right
nnoremap L gt

map q: <Nop>
nnoremap Q <nop>

" Python
autocmd Filetype python setlocal ts=2 sw=2 sts=2

" Elixir syntax highlight
autocmd BufNewFile,BufRead *.ex,*.exs set filetype=elixir syntax=elixir
autocmd BufNewFile,BufRead *.eex,*.leex,*.heex set syntax=eelixir
autocmd FileType elixir setlocal commentstring=#\ %s
autocmd BufRead,BufNewFile *test.exs set filetype=elixir

" Javascript
autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd FileType javascript setlocal equalprg=js-beautify\ --stdin

" Keep all folds open when a file is opened
augroup OpenAllFoldsOnFileOpen
  autocmd!
  autocmd BufRead * normal zR
augroup END

" JSON
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

" treesiter config
lua << EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "elixir", "lua", "vim", "vimdoc", "query", "javascript", "elm" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,
    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

" Copilot chat config
lua << EOF
require("CopilotChat").setup {
  debug = true, -- Enable debugging
  -- See Configuration section for rest
}
EOF

lua << EOF
  vim.keymap.set("n", "<leader>ccq", function()
    local input = vim.fn.input("Quick Chat: ")
    if input ~= "" then
      require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
    end
  end, { desc = "CopilotChat - Quick chat" })
EOF

" catpuccin theme
lua << EOF
require("catppuccin").setup({
  flavour = "auto", -- latte, frappe, macchiato, mocha
  background = { -- :h background
    light = "latte",
    dark = "mocha",
  },
  transparent_background = false, -- disables setting the background color.
  show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
  term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
  dim_inactive = {
    enabled = false, -- dims the background color of inactive window
    shade = "dark",
    percentage = 0.15, -- percentage of the shade to apply to the inactive window
  },
  coc_nvim = true,
  no_italic = false, -- Force no italic
  no_bold = false, -- Force no bold
  no_underline = false, -- Force no underline
  styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
    comments = { "italic" }, -- Change the style of comments
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
    -- miscs = {}, -- Uncomment to turn off hard-coded styles
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
    -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
  },
})

-- Setup must be called before loading
vim.cmd.colorscheme "catppuccin"
EOF

" lualine config
lua << END
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
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
END

lua << EOF
-- Require and setup minintro.nvim
require('minintro').setup()
EOF

lua << EOF
require('neoscroll').setup({
  mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb'}
})
EOF

lua << EOF
require('avante_lib').load()
require('avante').setup()
EOF

