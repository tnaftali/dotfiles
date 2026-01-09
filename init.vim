"============================================================================
" NEOVIM CONFIGURATION
" ============================================================================

" ============================================================================
" PLUGINS
" ============================================================================

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Window navigation
" Plug 'christoomey/vim-tmux-navigator' " disabled - using native vim mappings
" Plug 'preservim/vimux' " tmux-only, disabled

" vim utils
" Plug 'tpope/vim-commentary' " replaced by Comment.nvim
" Plug 'Yggdroot/indentLine' " replaced by indent-blankline.nvim
Plug 'numToStr/Comment.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'vim-test/vim-test'
Plug 'MunifTanjim/nui.nvim'
" Plug 'VonHeikemen/fine-cmdline.nvim'
" Plug 'mbbill/undotree'
Plug 'rhysd/conflict-marker.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'nvim-lualine/lualine.nvim'
" Plug 'rking/ag.vim' " redundant with telescope live_grep
Plug 'karb94/neoscroll.nvim'

" LSP
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" mix format for elixir files
Plug 'mhinz/vim-mix-format'

" git
Plug 'tpope/vim-fugitive' " the ultimate git helper
" Plug 'airblade/vim-gitgutter' " replaced by gitsigns.nvim
Plug 'lewis6991/gitsigns.nvim'
Plug 'kdheepak/lazygit.nvim'

" Themes
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

" Splash screen
Plug 'eoh-bse/minintro.nvim'

" Tab bar icons
Plug 'sangdol/mintabline.vim'
Plug 'nvim-tree/nvim-web-devicons'

Plug 'elixir-editors/vim-elixir'

" AI autocomplete
Plug 'supermaven-inc/supermaven-nvim'

" UI enhancements
Plug 'folke/which-key.nvim'
Plug 'folke/noice.nvim'
Plug 'windwp/nvim-autopairs'

" Optional deps
" Plug 'hrsh7th/nvim-cmp' " unused - using COC for completions

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

" COC Node path (uses system node from PATH)
" let g:coc_node_path = '/Users/tobi/.nvm/versions/node/v20.18.1/bin/node'

" vim-test configuration
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

" GitGutter signs (disabled - using gitsigns.nvim)
" let g:gitgutter_sign_added = '+'
" let g:gitgutter_sign_modified = '>'
" let g:gitgutter_sign_removed = '-'
" let g:gitgutter_sign_removed_first_line = '^'
" let g:gitgutter_sign_modified_removed = '<'

" Tmux navigator (disabled - not using plugin)
" let g:tmux_navigator_disable_when_zoomed = 1

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

" Window navigation (Ctrl+hjkl)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

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
local ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if ok then
  treesitter.setup {
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
end

-- Catppuccin theme configuration
local ok, catppuccin = pcall(require, "catppuccin")
if ok then
  catppuccin.setup({
    flavour = "auto",
    transparent_background = true,
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
  vim.cmd.colorscheme "catppuccin"
end

-- Lualine configuration
local ok, lualine = pcall(require, 'lualine')
if ok then
  lualine.setup {
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
end

-- Minintro setup
local ok, minintro = pcall(require, 'minintro')
if ok then minintro.setup() end

-- Neoscroll setup
local ok, neoscroll = pcall(require, 'neoscroll')
if ok then
  neoscroll.setup({
    mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb'}
  })
end

-- Supermaven AI autocomplete
local ok, supermaven = pcall(require, "supermaven-nvim")
if ok then
  supermaven.setup({
    keymaps = {
      accept_suggestion = "<Tab>",
      clear_suggestion = "<C-]>",
      accept_word = "<C-j>",
    },
    color = {
      suggestion_color = "#585858",
    },
    log_level = "off",
  })
end

-- Which-key
local ok, which_key = pcall(require, "which-key")
if ok then
  which_key.setup({
    delay = 300,
    icons = {
      mappings = false,
    },
  })
end

-- Comment.nvim
local ok, comment = pcall(require, "Comment")
if ok then
  comment.setup()
end

-- nvim-autopairs
local ok, autopairs = pcall(require, "nvim-autopairs")
if ok then
  autopairs.setup({
    check_ts = true,
  })
end

-- gitsigns.nvim
local ok, gitsigns = pcall(require, "gitsigns")
if ok then
  gitsigns.setup({
    signs = {
      add          = { text = '+' },
      change       = { text = '>' },
      delete       = { text = '-' },
      topdelete    = { text = '^' },
      changedelete = { text = '<' },
    },
    current_line_blame = false,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end
      -- Navigation
      map('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, {expr=true})
      map('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, {expr=true})
    end
  })
end

-- indent-blankline
local ok, ibl = pcall(require, "ibl")
if ok then
  ibl.setup({
    indent = {
      char = "│",
    },
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
    },
  })
end

-- noice.nvim
local ok, noice = pcall(require, "noice")
if ok then
  noice.setup({
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
    },
  })
end
EOF
