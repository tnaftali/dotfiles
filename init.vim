"============================================================================
" NEOVIM CONFIGURATION
" ============================================================================

" ============================================================================
" PLUGINS
" ============================================================================

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Core utilities
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-tree/nvim-web-devicons'

" Editor enhancements
Plug 'numToStr/Comment.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'windwp/nvim-autopairs'
Plug 'karb94/neoscroll.nvim'
Plug 'rhysd/conflict-marker.vim'

" Navigation & Search
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'

" LSP & Syntax
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Testing
Plug 'vim-test/vim-test'

" Git
Plug 'tpope/vim-fugitive'
Plug 'lewis6991/gitsigns.nvim'
Plug 'kdheepak/lazygit.nvim'
Plug 'sindrets/diffview.nvim'

" Language specific
Plug 'elixir-editors/vim-elixir'
Plug 'mhinz/vim-mix-format'
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }

" UI
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'sangdol/mintabline.vim'
Plug 'eoh-bse/minintro.nvim'
Plug 'folke/which-key.nvim'
Plug 'folke/noice.nvim'

" AI autocomplete
Plug 'supermaven-inc/supermaven-nvim'

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
set expandtab
set re=1
set number
set cursorline
set showmatch
set noswapfile
set nobackup
set nowrap
set listchars=tab:•\ ,trail:•,extends:»,precedes:«
set list
set smartindent

" Searching
set ignorecase
set smartcase

" System integration
set clipboard+=unnamedplus

" Performance
set updatetime=50

" Folding
set foldmethod=indent
set foldlevel=99

" Splits
set path=.,,**
set splitbelow
set splitright

" Transparent background
highlight Normal guibg=none
highlight NonText guibg=none

" ============================================================================
" PLUGIN CONFIGURATIONS
" ============================================================================

" Set space as Leader key
let mapleader = "\<Space>"

" vim-better-whitespace
let g:strip_whitespace_on_save = 1
let g:strip_whitespace_confirm = 0

" vim-test configuration
let test#strategy = "neovim"
let test#elixir#exunit#executable = 'source .env && MIX_ENV=test mix test --color'
let g:test#neovim#start_normal = 1
let g:test#neovim_sticky#kill_previous = 1
let g:test#preserve_screen = 0
let test#neovim_sticky#reopen_window = 1

" Conflict marker configuration
let g:conflict_marker_highlight_group = ''
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'
highlight ConflictMarkerBegin guifg=#e06c75
highlight ConflictMarkerOurs guibg=#2e5049
highlight ConflictMarkerSeparator guifg=#e06c75
highlight ConflictMarkerTheirs guibg=#344f69
highlight ConflictMarkerEnd guifg=#e06c75

" Markdown preview configuration
let g:mkdp_auto_close = 0
let g:mkdp_refresh_slow = 0
let g:mkdp_browser = ''

" ============================================================================
" KEY MAPPINGS
" ============================================================================

" COC mappings
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" Neo-tree mappings
nnoremap <leader>e :Neotree toggle<CR>
nnoremap <C-_> :Neotree toggle<CR>
nnoremap <leader>er :Neotree reveal<CR>
nnoremap <leader>gs :Neotree git_status<CR>
nnoremap <leader>eb :Neotree buffers<CR>

" Telescope mappings
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <leader>fg :lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fr <cmd>Telescope resume<cr>

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

" Diffview mappings
nnoremap <leader>do :DiffviewOpen<CR>
nnoremap <leader>dc :DiffviewClose<CR>
nnoremap <leader>dh :DiffviewFileHistory %<CR>

" Edit config files
nnoremap <leader>en <cmd>edit ~/.config/nvim/init.vim<cr>
nnoremap <leader>ez <cmd>edit ~/dotfiles/.zshrc<cr>
nnoremap <leader>eg <cmd>edit ~/.config/ghostty/config<cr>

" Markdown preview toggle (inline)
nnoremap <leader>mp :RenderMarkdown toggle<CR>

" Markdown preview (browser)
nnoremap <leader>md :MarkdownPreview<CR>
nnoremap <leader>ms :MarkdownPreviewStop<CR>

" Resize panes
nnoremap <silent> <leader>r+ :vertical resize +10<CR>
nnoremap <silent> <leader>r- :vertical resize -10<CR>

" Indent in visual mode and keep selection
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Better navigation
nnoremap Y y$
nnoremap n nzzzv
nnoremap N Nzzzv
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
tmap <C-o> <C-\><C-n>

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

" Select last pasted text
nnoremap gV `[v`]

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

" Elixir (vim-elixir handles most of this, but ensure test files are detected)
autocmd BufRead,BufNewFile *test.exs set filetype=elixir

" Javascript settings
autocmd FileType javascript setlocal equalprg=js-beautify\ --stdin

" Keep all folds open when a file is opened
augroup OpenAllFoldsOnFileOpen
  autocmd!
  autocmd BufRead * normal zR
augroup END

" JSON settings
augroup json_settings
  autocmd!
  autocmd BufNewFile,BufRead *.json setfiletype json
  autocmd FileType json setlocal conceallevel=0 autoindent expandtab
  autocmd FileType json setlocal shiftwidth=2 softtabstop=2 tabstop=2
  autocmd FileType json setlocal foldmethod=syntax formatoptions=tcq2l
augroup END

" Highlight yanked text
augroup highlight_yank
  autocmd!
  autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

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
    background = { light = "latte", dark = "mocha" },
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
    },
    integrations = {
      coc_nvim = true,
      gitsigns = true,
      neotree = true,
      treesitter = true,
      mini = { enabled = true },
    },
  })
  vim.cmd.colorscheme "catppuccin"
end

-- Lualine configuration
local ok, lualine = pcall(require, 'lualine')
if ok then
  lualine.setup {
    options = {
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
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
      lualine_c = {{'filename', path = 1 }},
      lualine_x = {'location'},
    },
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

-- neo-tree.nvim
local ok, neotree = pcall(require, "neo-tree")
if ok then
  neotree.setup({
    close_if_last_window = true,
    window = {
      width = 35,
      mappings = {
        ["<space>"] = "none",
        ["s"] = "open_split",
        ["v"] = "open_vsplit",
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = { ".git", "node_modules", "_build", "deps" },
      },
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    git_status = {
      window = { position = "float" },
    },
  })
end

-- render-markdown.nvim
local ok, render_markdown = pcall(require, "render-markdown")
if ok then
  render_markdown.setup({
    headings = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
  })
end

-- diffview.nvim
local ok, diffview = pcall(require, "diffview")
if ok then
  diffview.setup({
    use_icons = true,
    view = {
      merge_tool = {
        layout = "diff3_mixed",
      },
    },
  })
end
EOF
