" vim:foldmethod=marker

" Compatibility {{{
scriptencoding utf-8
set nocompatible
set encoding=utf-8
set timeoutlen=1000
set ttimeoutlen=0

" Fix certain terminals not getting recognized as 256-color capable
set t_Co=256

let g:is_unix = has('unix')
let g:is_win = has('win32')
let g:is_gui = has('gui_running')

" Disable termresponses on vim to prevent artifacts with kitty
" (doesn't seem to affect nvim)
" https://github.com/vim/vim/issues/3197#issuecomment-549086639
set t_RB= t_RF= t_RV= t_u7=

" Fixes scrolling issues with st
if !has('nvim')
  set ttymouse=sgr
endif

" Fix redrawing issues with kitty
" https://github.com/kovidgoyal/kitty/issues/108#issuecomment-320492663
let &t_ut = ''
" }}}

" Download vim-plug if not already installed {{{
if g:is_unix
  if has('nvim')
    if !filereadable(expand('~/.local/share/nvim/site/autoload/plug.vim'))
      silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall | source $MYVIMRC
    endif
  else
    if !filereadable(expand('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall | source $MYVIMRC
    endif
  endif
else
  if !filereadable(expand('~/vimfiles/autoload/plug.vim'))
    echom "Install vim-plug!"
  endif
endif
" }}}

" Plugins {{{
call plug#begin('~/.vim/plugged')
Plug 'tweekmonster/startuptime.vim'
Plug 'morhetz/gruvbox'
Plug 'sainnhe/gruvbox-material'
Plug 'shinchu/lightline-gruvbox.vim'
" Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'simeji/winresizer'
Plug 'editorconfig/editorconfig-vim'
Plug 'mg979/vim-visual-multi'
Plug 'itchyny/lightline.vim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'tversteeg/registers.nvim', { 'branch': 'main' }
Plug 'machakann/vim-highlightedyank'
Plug 'psliwka/vim-smoothie'
Plug 'nacro90/numb.nvim'
Plug 'airblade/vim-rooter'
Plug 'folke/todo-comments.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'ellisonleao/glow.nvim'
Plug 'wesQ3/vim-windowswap'
Plug 'numtostr/FTerm.nvim'
Plug 'kwkarlwang/bufresize.nvim'
" Automatically creates missing LSP diagnostics highlight groups
Plug 'folke/lsp-colors.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/playground'
" Plug 'nvim-treesitter/nvim-tree-docs'
Plug 'romgrk/nvim-treesitter-context'
Plug 'RRethy/nvim-treesitter-textsubjects'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'windwp/nvim-ts-autotag'
Plug 'p00f/nvim-ts-rainbow'
Plug 'SmiteshP/nvim-gps'
Plug 'theHamsta/nvim-treesitter-pairs'
Plug 'windwp/nvim-autopairs'
Plug 'kevinoid/vim-jsonc'
" Plug 'yuezk/vim-js'
" Plug 'maxmellon/vim-jsx-pretty'
Plug 'LnL7/vim-nix'
Plug 'xolox/vim-misc'
Plug 'tikhomirov/vim-glsl'
Plug 'kkoomen/vim-doge', { 'do': {-> doge#install() } }
Plug 'tpope/vim-commentary'
Plug 'AndrewRadev/tagalong.vim'
Plug 'lambdalisue/suda.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'PeterRincker/vim-argumentative'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-fold'
Plug 'chaoren/vim-wordmotion'
Plug 'gcmt/taboo.vim'
Plug 'mhinz/vim-startify'
Plug 'junegunn/fzf', { 'do': {-> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'pbogut/fzf-mru.vim'
" This replaces the gd/gr/gy/gi mappings from CoC
Plug 'antoinemadec/coc-fzf'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'romgrk/fzy-lua-native' " used by wilder
" Requires cmake, libboost-all-dev, python-dev and libicu-dev
" FIXME: install.sh exits with exitcode 1
Plug 'nixprime/cpsm', { 'do': './install.sh' } " used by wilder
Plug 'puremourning/vimspector'
Plug 'neoclide/coc.nvim', { 'do': 'yarn install --frozen-lockfile' }
Plug 'skywind3000/asynctasks.vim'
Plug 'skywind3000/asyncrun.vim'
" Plug 'honza/vim-snippets'
" This must be loaded last
Plug 'ryanoasis/vim-devicons'
call plug#end()
" }}}

" mkdir -p on save {{{
" https://stackoverflow.com/questions/4292733/vim-creating-parent-directories-on-save
fun! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let l:dir = fnamemodify(a:file, ':h')
    if !isdirectory(l:dir)
      call mkdir(l:dir, 'p')
    endif
  endif
endfun

augroup vimrc_Mkdirp
  autocmd!
  autocmd BufWritePre * call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END
" }}}

" Replace gx to open urls {{{
" https://web.archive.org/web/20200129052658/https://old.reddit.com/r/vim/comments/7j9znw/gx_failing_to_open_url_on_vim8/dr6e3ks/
fun! s:OpenUrl() abort
  " Open the current URL
  " - If line begins with "Plug" open the github page
  " of the plugin.

  let l:cl = getline('.')
  let l:url = escape(matchstr(l:cl, '[a-z]*:\/\/\/\?[^ >,;()]*'), '#%')
  if l:cl =~# 'Plug'
    let l:pn = l:cl[match(l:cl, "'", 0, 1) + 1 :
          \ match(l:cl, "'", 0, 2) - 1]
    let l:url = printf("https://github.com/%s", pn)
  endif
  if !empty(l:url)
    let l:url = substitute(l:url, "['\"]", '', 'g')
    let l:wmctrl = executable('wmctrl') && v:windowid isnot# 0 ?
      \ ' && wmctrl -ia ' . v:windowid : ''
    exe 'silent :!' . (g:is_unix ?
      \   'xdg-open ' . shellescape(l:url) :
      \   ' start "' . shellescape(l:url)) .
      \ l:wmctrl .
      \ (g:is_unix ? ' 2> /dev/null &' : '')
    if !g:is_gui | redraw! | endif
  endif
endfun

nnoremap <silent> gx :call <SID>OpenUrl()<CR>
" }}}

" General settings {{{
" Disable default vim backspace behavior
set backspace=indent,eol,start

" Always show the status line
set laststatus=2

" Reduce inactivity delay before writing to swapfile
" This also allows gitgutter/coc-git to update faster
set updatetime=100

" FixCursorHold.nvim
let g:cursorhold_updatetime = 100

" Disable virtualedit
set virtualedit=

" Don't show the mode below the status bar
set noshowmode

" Enable confirmation prompts when closing an unsaved buffer/file
set confirm

" Enable line wrapping
set wrap linebreak nolist
set breakat=" 	!@*-+;:,./?"

" Show line numbers
set number norelativenumber
set numberwidth=5

" Show some context around the cursor
set scrolloff=5
set sidescrolloff=1

" Set max command history
set history=10000

" Always show the signcolumn, otherwise it would shift the text each time the
" signcolumn is triggered
set signcolumn=yes:1
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  " set signcolumn=number
endif

" Cursor position (displayed in the bar)
set ruler

" Make undesirable characters more apparent
set list listchars=tab:→\ ,nbsp:␣,trail:·,extends:▶,precedes:◀

" Set the filling characters
set fillchars=eob:\ ,stl:\ ,stlnc:\ ,vert:\|,fold:·,diff:-

" Enable mouse interaction
set mouse=a

" Enable wildmenu
set wildmenu
set wildmode=full

" Highlight current line
set cursorline nocursorcolumn

" Unmap C-c to prevent the "Type :qa and press <Enter> to exit Nvim" message
" from showing up
" noremap <C-c> <nop>
fun! s:CtrlC()
  if coc#float#has_float()
    call coc#float#close_all()
    return
  endif
  execute("confirm q")
endfun
nnoremap <silent> <C-c> :call <SID>CtrlC()<CR>
"}}}

" Search and substitution {{{
" Search highlighting
set hlsearch
set incsearch

" Case-insensitive search
" unless there's a capital character
set ignorecase
set smartcase

" Disable search highlight after pressing ENTER
" https://stackoverflow.com/questions/657447/vim-clear-last-search-highlighting
nnoremap <silent> <CR> :noh<CR><CR>

" Live substitutions
if has('nvim')
  set inccommand=split
endif
" }}}

" shortmess {{{
" Shorten a bunch of messages
set shortmess=a

" Disable the vim intro message
set shortmess+=I

" Disable 'pattern not found' messages
set shortmess+=c

" Hide file info when editing a file
" set shortmess+=F
" }}}

" highlightedyank {{{
" Highlight yanks for quarter of a second
let g:highlightedyank_highlight_duration = 250
" }}}

" wordmotion {{{
let g:wordmotion_uppercase_spaces = [',', '=', '(', ')', '[', ']', '{', '}', '<', '>']
" }}}

" Sessions {{{
" Let Taboo save tab names with :mksession
set sessionoptions+=tabpages,globals

" Enable persistent undo history
let s:undodir = $HOME . "/.vim/undodir"
if !isdirectory(s:undodir)
  call mkdir(s:undodir, 'p')
endif
set undofile
execute "set undodir=" . s:undodir
" }}}

" Default indentation {{{
filetype plugin indent on
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab
set fileformats=unix,dos

" Syncs the vim continuation indentation with shiftwidth
let g:vim_indent_cont = &shiftwidth
" }}}

" Disable automatic continuation of multiline comments {{{
augroup vimrc_FormatOptions
  autocmd!
  autocmd FileType * set formatoptions-=ro
augroup END
" }}}

" Filetypes {{{
" TODO: get rid of vim-devicons and unify with coc-explorer icons
let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols = {
  \ '.ignore': "",
  \ '.editorconfig': "",
  \ }
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {
  \ 'fx': "",
  \ 'fxh': "",
  \ 'js': "",
  \ 'mjs': "",
  \ 'cjs': "",
  \ }
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {
  \ '^\.prettierrc.*': "",
  \ '^\.eslintrc.*': "",
  \ }

augroup vimrc_FileTypes
  autocmd! BufNewFile,BufRead *.fx set filetype=glsl
  autocmd! BufNewFile,BufRead *.fxh set filetype=glsl
  autocmd! BufNewFile,BufRead .ignore set filetype=conf
augroup END
" }}}

" General mappings {{{
" Stay in visual mode when indenting {{{
vnoremap < <gv
vnoremap > >gv
" }}}

" Make navigation with linewrap less jarring {{{
noremap <silent> j gj
noremap <silent> k gk
noremap <silent> <Down> gj
noremap <silent> <Up> gk
inoremap <silent> <Down> <C-o>gj
inoremap <silent> <Up> <C-o>gk
" }}}

" Window navigation & splitting {{{
set splitbelow splitright

nnoremap <silent> <C-Up> <C-w>k
nnoremap <silent> <C-Down> <C-w>j
nnoremap <silent> <C-Left> <C-w>h
nnoremap <silent> <C-Right> <C-w>l
nnoremap <silent> <S-Up> <C-w>k
nnoremap <silent> <S-Down> <C-w>j
nnoremap <silent> <S-Left> <C-w>h
nnoremap <silent> <S-Right> <C-w>l

nnoremap <silent> <Space><Up> <C-w>k
nnoremap <silent> <Space><Down> <C-w>j
nnoremap <silent> <Space><Left> <C-w>h
nnoremap <silent> <Space><Right> <C-w>l
" }}}

" Buffer Navigation {{{
" nnoremap <silent> <M-Up> :bnext<CR>
" nnoremap <silent> <M-Down> :bprev<CR>
nnoremap <silent> <M-Up> <nop>
nnoremap <silent> <M-Down> <nop>

" Unmap (ctrl-)alt-up/down to prevent accidents in insert mode
inoremap <silent> <M-Up> <nop>
inoremap <silent> <M-Down> <nop>
inoremap <silent> <M-S-Up> <nop>
inoremap <silent> <M-S-Down> <nop>
" Unmap ctrl-up/down in insert mode
inoremap <silent> <S-Up> <nop>
inoremap <silent> <S-Down> <nop>
" }}}

" Emacs-style navigation in insert mode {{{
" inoremap <C-a> <Home>
" inoremap <C-e> <End>
inoremap <C-a> <nop>
inoremap <C-e> <nop>
" }}}

" Makes it so that ctrl-right doesn't skip over to the next line
inoremap <S-Right> <C-o>e

" Tab navigation {{{
nnoremap <silent> th :tabfirst<CR>
nnoremap <silent> tl :tablast<CR>
nnoremap tt :tabedit<Space>
nnoremap te :edit<Space>
nnoremap tr :TabooRename<Space>
nnoremap <silent> tn :tabnew<CR>
" nnoremap <silent> <C-t> :tabnew<CR>
nnoremap <silent> ts :tab split<CR>
nnoremap <silent> <M-C-Right> :tabnext<CR>
nnoremap <silent> <M-C-Left> :tabprev<CR>
nnoremap <silent> <M-S-Right> :tabnext<CR>
nnoremap <silent> <M-S-Left> :tabprev<CR>
nnoremap <silent> <M-Right> :tabnext<CR>
nnoremap <silent> <M-Left> :tabprev<CR>
nnoremap <silent> td :windo :q<CR>

" Reorder tabs (requires manual remapping of keys through terminal emulator)
nnoremap <silent> <F24> :silent! tabmove +1<CR>
nnoremap <silent> <F23> :silent! tabmove -1<CR>
" }}}

" Close window
nnoremap <silent> <Space>q :confirm q<CR>
nnoremap <silent> <Space>Q :confirm qa<CR>
nnoremap <silent> <Space>bd :bdelete<CR>

" Unmap ex mode
nnoremap Q <Nop>

" Save
nnoremap <silent> <Space>ww :w<CR>

" Save (sudo)
nnoremap <silent> <Space>wW :SudaWrite<CR>

" Split line (symmetrical to J)
nnoremap K a<CR><Esc>

" Toggle paste mode
noremap <silent> <F2> :set paste!<CR>

" Toggle line wrapping
noremap <silent> <F1> :set wrap!<CR>

" Git {{{
nnoremap <silent> <Space>gg :G<CR>
nnoremap <silent> <Space>gc :G commit<CR>
nnoremap <silent> <Space>gb :G blame<CR>
nnoremap <silent> <Space>gd :Gdiffsplit<CR>
nnoremap <silent> <Space>gl :tabnew <bar> Gclog <bar> TabooRename git log<CR>
" }}}
" }}}

" EditorConfig {{{
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
" }}}

" visual-multi {{{
" Prevent vim-visual-multi from adding maps to the leader key,
" as those conflict with other mappings
let g:VM_default_mappings = 0

" Hide the "Exited Visual-Multi." message that won't go away after exiting VM
let g:VM_silent_exit = 1
" }}}

" Startify {{{
let g:startify_session_dir = '~/.vim/sessions'
let g:startify_lists = [
  \ { 'type': 'sessions',  'header': ['   Sessions']       },
  \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
  \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
  \ { 'type': 'commands',  'header': ['   Commands']       },
  \ ]
let g:startify_custom_header =
  \ startify#fortune#cowsay('', '═','║','╔','╗','╝','╚')
" }}}

" rooter {{{
let g:rooter_cd_cmd = 'tcd'

fun! s:RootStartifiedWindow()
  if !get(w:, 'startified', 0) | return | endif
  let w:startified = 0
  execute('Rooter')
endfun

augroup vimrc_StartifyRooterCompat
  autocmd!
  autocmd User Startified let w:startified = 1
  autocmd BufEnter * call <SID>RootStartifiedWindow()
augroup END
" }}}

" indent-blankline {{{
lua << EOF
require("indent_blankline").setup {
  use_treesitter = true,
  buftype_exclude = {"terminal"},
  filetype_exclude = {
    "startify",
    "help",
    "coc-explorer",
    "coctree",
    "fzf",
  },
}
EOF
" }}}

" numb {{{
lua <<EOF
require('numb').setup()
EOF
" }}}

" todo-comments {{{
augroup vimrc_TodoComments
  autocmd!
  autocmd User vimrc_ColorSchemePost call <SID>SetupTodoComments()
augroup END

fun! s:SetupTodoComments()
  lua << EOF
  require("todo-comments").setup {
    signs = true,
    signs_priority = 8,
    keywords = {
      FIX = {
        icon = " ", -- icon used for the sign, and in search results
        color = "error", -- can be a hex color, or a named color (see below)
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
        -- signs = false, -- configure signs for some keywords individually
      },
      TODO = { icon = " ", color = "info" },
      HACK = { icon = " ", color = "warning" },
      WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    }
  }
EOF
endfun

nnoremap <silent> <Space>dt :TodoLocList<CR>
" }}}

" Winresizer {{{
let g:winresizer_enable = 1
let g:winresizer_horiz_resize = 1
let g:winresizer_vert_resize = 1
let g:winresizer_start_key = '<C-q>'
let g:winresizer_keycode_left = "\<Left>"
let g:winresizer_keycode_up = "\<Up>"
let g:winresizer_keycode_right = "\<Right>"
let g:winresizer_keycode_down = "\<Down>"
" }}}

" bufresize {{{
lua <<EOF
require("bufresize").setup()
EOF
" }}}

" Folds {{{
" Start with everything unfolded
set foldlevelstart=99

fun! s:SetFoldSettings()
  set foldcolumn=0
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
  set foldignore=
  " set foldmethod=syntax
  " if &ft == 'vim'
  "   set foldmethod=marker
  " endif
endfun

augroup vimrc_VimFolds
  autocmd!
  autocmd FileType * call <SID>SetFoldSettings()
augroup END
" }}}

" Interactive replace {{{
nnoremap ;; :%s:::cg<Left><Left><Left><Left>
" WARN: this conflicts with nvim-treesitter-textsubjects
" xnoremap ;; :s:::cg<Left><Left><Left><Left>
" }}}

" Windowswap {{{
let g:windowswap_map_keys = 0
nnoremap <silent> <Space>ws :call WindowSwap#EasyWindowSwap()<CR>
" }}}

" asynctasks {{{
let g:asyncrun_open = 6
" }}}

" treesitter {{{
" Do nothing if we hit the inc. selection mapping in visual mode
xnoremap gnn <nop>

lua <<EOF
require'nvim-gps'.setup({
  icons = {
    ["class-name"] = ' ',      -- Classes and class-like objects
    ["function-name"] = ' ',   -- Functions
    ["method-name"] = ' ',     -- Methods (functions inside class-like objects)
    ["container-name"] = '⛶ ',  -- Containers (example: lua tables)
    ["tag-name"] = '炙'         -- Tags (example: html tags)
  },
  separator = ' > ',
})
require'nvim-autopairs'.setup({
  check_ts = true,
  disable_filetype = {
    "startify",
    "help",
    "coc-explorer",
    "coctree",
    "fzf",
  },
})
require'treesitter-context'.setup{
    -- Enable this plugin (Can be enabled/disabled later via commands)
    enable = true,
    -- Throttles plugin updates (may improve performance)
    throttle = true,
    -- How many lines the window should span. Values <= 0 mean no limit.
    max_lines = 0,
    -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
    patterns = {
        -- For all filetypes
        -- Note that setting an entry here replaces all other patterns for this entry.
        -- By setting the 'default' entry below, you can control which nodes you want to
        -- appear in the context window.
        default = {
            'class',
            'function',
            'method',
            -- 'for', -- These won't appear in the context
            -- 'while',
            -- 'if',
            -- 'switch',
            -- 'case',
        },
        -- Example for a specific filetype.
        -- If a pattern is missing, *open a PR* so everyone can benefit.
        --   rust = {
        --       'impl_item',
        --   },
    },
}
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    -- false will disable the whole extension
    enable = true,
    -- list of language that will be disabled
    disable = {},
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true
  },
  autotag = {
    enable = true,
    filetypes = { "html", "xml" },
  },
  context_commentstring = {
    enable = true,
  },
  rainbow = {
    enable = true,
    -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    extended_mode = true,
    -- Do not enable for files with more than n lines, int
    max_file_lines = nil,
    -- table of hex strings
    -- colors = {},
    -- table of colour name strings
    -- termcolors = {}
  },
  pairs = {
    enable = true,
    disable = {},
    -- e.g. {"CursorMoved"}, -- when to highlight the pairs, use {} to deactivate highlighting
    highlight_pair_events = {"CursorMoved"},
    -- whether to highlight also the part of the pair under cursor (or only the partner)
    highlight_self = false,
    -- whether to go to the end of the right partner or the beginning
    goto_right_end = false,
    -- What command to issue when we can't find a pair (e.g. "normal! %")
    fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')",
    keymaps = {
      goto_partner = "%",
    },
  },
  textsubjects = {
    enable = true,
    keymaps = {
      ['.'] = 'textsubjects-smart',
      [';'] = 'textsubjects-container-outer',
    },
  },
}
EOF
" }}}

" fterm {{{
nnoremap <silent> <Space>t :lua require('FTerm').toggle()<CR>
tnoremap <Esc> <C-\><C-n>
" }}}

" registers {{{
let g:registers_delay = 0
" }}}

" ReplaceWithRegister {{{
nnoremap r <nop>
nnoremap rc r
xnoremap rc r
nmap rr <Plug>ReplaceWithRegisterOperator
xmap rr <Plug>ReplaceWithRegisterVisual
nmap r^ <Plug>ReplaceWithRegisterLine
" }}}

" Custom textobjects {{{
" Argumentative {{{
let g:argumentative_no_mappings = 1
nmap ,b <Plug>Argumentative_Prev
nmap ,w <Plug>Argumentative_Next
xmap ,b <Plug>Argumentative_XPrev
xmap ,w <Plug>Argumentative_XNext
nmap ,< <Plug>Argumentative_MoveLeft
nmap ,> <Plug>Argumentative_MoveRight
xmap ia <Plug>Argumentative_InnerTextObject
xmap aa <Plug>Argumentative_OuterTextObject
omap ia <Plug>Argumentative_OpPendingInnerTextObject
omap aa <Plug>Argumentative_OpPendingOuterTextObject
" }}}

" Spaces {{{
call textobj#user#plugin('space', {
\   '-': {
\     '*sfile*': expand('<sfile>:p'),
\     'select-a': 'a<Space>', '*select-a-function*': 's:SelectSpaces_a',
\     'select': '<Space>', '*select-function*': 's:SelectSpaces_i',
\     'select-i': 'i<Space>', '*select-i-function*': 's:SelectSpaces_i',
\   }
\ })

omap aS <Plug>(textobj-space-a)
omap iS <Plug>(textobj-space-i)
omap S <Plug>(textobj-space-i)

fun! s:SelectSpaces_a()
  return s:SelectSpaces(0)
endfun

fun! s:SelectSpaces_i()
  return s:SelectSpaces(1)
endfun

fun! s:SelectSpaces(inner)
  let l:pattern = '[[:blank:]　]\+'
  if matchstr(getline('.'), '.', col('.') - 1) !~ l:pattern
    call search(l:pattern)
    if matchstr(getline('.'), '.', col('.') - 1) !~ l:pattern
      return
    endif
  endif

  call search(l:pattern,'bc')
  let l:start = getpos('.')
  call search(l:pattern, 'ce')
  let l:end = getpos('.')
  if a:inner && (l:end[2] - l:start[2]) > 1
    let l:end[2] -= 1
    return ['v', l:start, l:end]
  endif
  return ['v', l:start, l:end]
endfun
" }}}
" }}}

" Vimspector {{{
let g:vimspector_install_gadgets = [
  \ 'netcoredbg',
  \ 'vscode-node-debug2',
  \ ]

nmap <F5> <Plug>VimspectorContinue
" <F15>/<S-F3> = shift-f5 (depends on the terminfo)
nmap <F15> <Plug>VimspectorStop
nmap <S-F3> <Plug>VimspectorStop
" ctrl-shift-F5 doesn't work in the terminal
nmap <F4> <Plug>VimspectorRestart
nmap <F6> <Plug>VimspectorPause
nmap <F9> <Plug>VimspectorToggleBreakpoint
nmap <F10> <Plug>VimspectorStepOver
nmap <F11> <Plug>VimspectorStepInto
" shift-F11 doesn't work in the terminal
nmap <F12> <Plug>VimspectorStepOut
nmap <C-x> <Plug>VimspectorToggleBreakpoint

nmap <silent> <Space>dq :VimspectorReset<CR>
nmap <silent> <Space>de <Plug>VimspectorBalloonEval
vmap <silent> <Space>de <Plug>VimspectorBalloonEval

" Signs
fun! s:SetVimspectorColorschemePreferences()
  execute 'hi! vimspectorBP' .
    \ ' ctermbg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'cterm')
    \ ' guibg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'gui')
    \ ' ctermfg=' . synIDattr(synIDtrans(hlID('ErrorMsg')), 'fg', 'cterm')
    \ ' guifg=' . synIDattr(synIDtrans(hlID('ErrorMsg')), 'fg', 'gui')
  execute 'hi! vimspectorBPCond' .
    \ ' ctermbg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'cterm')
    \ ' guibg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'gui')
    \ ' ctermfg=' . synIDattr(synIDtrans(hlID('ErrorMsg')), 'fg', 'cterm')
    \ ' guifg=' . synIDattr(synIDtrans(hlID('ErrorMsg')), 'fg', 'gui')
  if get(g:, 'colors_name') == 'gruvbox'
    execute 'hi! vimspectorBPLog' .
      \ ' ctermbg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'cterm')
      \ ' guibg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'gui')
      \ ' ctermfg=' . synIDattr(synIDtrans(hlID('Underlined')), 'fg', 'cterm')
      \ ' guifg=' . synIDattr(synIDtrans(hlID('Underlined')), 'fg', 'gui')
      " \ ' cterm=underline gui=underline'
  elseif get(g:, 'colors_name') == 'gruvbox-material'
    execute 'hi! vimspectorBPLog' .
      \ ' ctermbg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'cterm')
      \ ' guibg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'gui')
      " \ ' cterm=underline gui=underline'
  endif
  execute 'hi! vimspectorBPDisabled' .
    \ ' ctermbg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'cterm')
    \ ' guibg=' . synIDattr(synIDtrans(hlID('SignColumn')), 'bg', 'gui')
    \ ' ctermfg=' . synIDattr(synIDtrans(hlID('LineNr')), 'fg', 'cterm')
    \ ' guifg=' . synIDattr(synIDtrans(hlID('LineNr')), 'fg', 'gui')

  " hi! vimspectorCursorLine ctermbg=236 guibg=#16162a
  " hi! vimspectorCursorLine ctermbg=236 guibg=#151d29
  " hi! vimspectorCursorLine ctermbg=236 guibg=#212429
  hi! vimspectorCursorLine ctermbg=236 guibg=#181e29
  execute 'hi! vimspectorCursorLineSpecial ctermbg=236 guibg=#181e29'
    \ ' ctermfg='. synIDattr(synIDtrans(hlID('Special')), 'fg', 'cterm')
    \ ' guifg='. synIDattr(synIDtrans(hlID('Special')), 'fg', 'gui')
endfun

augroup vimrc_VimspectorColorschemePreferences
  autocmd!
  autocmd ColorScheme * call <SID>SetVimspectorColorschemePreferences()
augroup END

sign define vimspectorBP            text=\ ● texthl=vimspectorBP
sign define vimspectorBPCond        text=\ ◆ texthl=vimspectorBPCond
sign define vimspectorBPLog         text=\ ◆ texthl=vimspectorBPLog
sign define vimspectorBPDisabled    text=\ ● texthl=vimspectorBPDisabled
sign define vimspectorPC            text=\ ▶ texthl=vimspectorCursorLine linehl=vimspectorCursorLine numhl=vimspectorCursorLine
sign define vimspectorPCBP          text=●▶  texthl=vimspectorCursorLine linehl=vimspectorCursorLine numhl=vimspectorCursorLine
sign define vimspectorCurrentThread text=▶   texthl=vimspectorCursorLine linehl=vimspectorCursorLine numhl=vimspectorCursorLine
sign define vimspectorCurrentFrame  text=▶   texthl=vimspectorCursorLineSpecial linehl=vimspectorCursorLine numhl=vimspectorCursorLine

" Make vimspector signs have priority over git signs
let g:vimspector_sign_priority = {
\   'vimspectorBP':         12,
\   'vimspectorBPCond':     12,
\   'vimspectorBPLog':      12,
\   'vimspectorBPDisabled': 12,
\   'vimspectorPC':         999,
\ }
" }}}

" FZF {{{
let $FZF_DEFAULT_COMMAND='rg --files --hidden -- '
" }}}

" Smoothie {{{
let g:smoothie_no_default_mappings = 1

" NOTE: this is remapped below in the CoC section
" map <C-d> <Plug>(SmoothieDownwards)
" map <C-u> <Plug>(SmoothieUpwards)
" map <PageDown> <Plug>(SmoothieForwards)
" map <PageUp> <Plug>(SmoothieBackwards)
" }}}

" DoGe {{{
let g:doge_enable_mappings = 0
let g:doge_buffer_mappings = 1
let g:doge_comment_interactive = 1
let g:doge_comment_jump_wrap = 1
let g:doge_mapping_comment_jump_forward = '<Tab>'
let g:doge_mapping_comment_jump_backward = '<S-Tab>'

let g:doge_javascript_settings = {
  \   'destructuring_props': 1,
  \   'omit_redundant_param_types': 1,
  \ }

nmap <silent> <Space>c <Plug>(doge-generate)
" }}}

" Completion popup navigation {{{
" This enables:
"   - registers.nvim navigation
"   - snippet jumping
"   - suggestion navigation
inoremap <silent> <expr> <Tab>
  \ &ft == 'registers'
  \   ? "\<Down>" :
  \ pumvisible()
  \   ? "\<C-n>" :
  \ coc#jumpable()
  \   ? "\<C-r>=coc#rpc#request('snippetNext', [])\<CR>" :
  \ <SID>CanSuggest()
  \   ? coc#refresh()
  \   : "\<Tab>"
snoremap <silent> <expr> <Tab>
  \ coc#jumpable()
  \   ? "\<C-g>:\<C-u>call coc#rpc#request('snippetNext', [])\<CR>"
  \   : "\<Tab>"
inoremap <silent> <expr> <S-Tab>
  \ &ft == 'registers'
  \   ? "\<Up>" :
  \ pumvisible()
  \   ? "\<C-p>" :
  \ coc#jumpable()
  \   ? "\<C-r>=coc#rpc#request('snippetPrev', [])\<CR>"
  \   : "\<C-h>"
snoremap <silent> <expr> <S-Tab>
  \ coc#jumpable()
  \   ? "\<C-g>:\<C-u>call coc#rpc#request('snippetPrev', [])\<CR>"
  \   : "\<S-Tab>"
inoremap <silent> <expr> <CR>
  \ pumvisible()
  \ ? "\<C-y>"
  \ : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"

fun! s:CanSuggest() abort
  let l:col = col('.') - 1
  if !l:col | return v:false | endif
  let l:c = getline('.')[col - 1]
  " Suppress suggestions when pressing TAB on:
  " - spaces (indentation)
  if l:c =~# '\s' | return v:false | endif
  " - backslash (shell/vim line continuation)
  if l:c =~# '\\' | return v:false | endif
  " Otherwise enable suggestions
  return v:true
endfun
" }}}

" CoC {{{
" WARN: coc-sh is nice but the LSP symbol resolution is slow/buggy
let g:coc_global_extensions = [
  \ 'coc-explorer',
  \ 'coc-git',
  \ 'coc-highlight',
  \ 'coc-tasks',
  \ 'coc-lists',
  \ 'coc-snippets',
  \ 'coc-css',
  \ 'coc-html',
  \ 'coc-json',
  \ 'coc-eslint',
  \ 'coc-tsserver',
  \ 'coc-prettier',
  \ 'coc-omnisharp',
  \ 'coc-pyright',
  \ 'coc-vimlsp',
  \ 'coc-sh',
  \ ]

" Prevents the cursor from disappearing when pressing ctrl-c in :CocList
" let g:coc_disable_transparent_cursor = 1

nnoremap <silent> <Bar> :CocCommand explorer --sources=buffer+<CR>
nnoremap <silent> \ :CocCommand explorer --sources=file+<CR>
nnoremap <silent> à :CocCommand explorer<CR>

" Close vim if coc-explorer/coc-tree is the last open window {{{
fun! s:CocAutoClose()
  let l:filetypes = ['coc-explorer', 'coctree']
  let l:wincount = winnr('$')
  let l:windows = map(range(1, l:wincount), {_,v -> {
    \   'id': v,
    \   'ft': getbufvar(winbufnr(v), '&ft'),
    \ } })
  call filter(l:windows, {_,v -> index(l:filetypes, v.ft) >= 0})
  " If the only windows left open are the filtered ones, close them all
  if l:wincount != len(l:windows) | return | endif
  " Close the windows from the highest id to the lowest, preventing the ids
  " from changing
  call reverse(l:windows)
  for w in l:windows
    execute('silent' . l:w.id .  'windo q')
  endfor
endfun

augroup vimrc_CocAutoClose
  autocmd!
  autocmd BufEnter * call s:CocAutoClose()
augroup END
" }}}

" coc-explorer mappings {{{
fun! s:CocExplorerMappings()
  let l:bufid = bufnr()
  fun! s:CocExplorerMappingsCb(_) closure
    if getbufvar(l:bufid, '&ft') != 'coc-explorer' | return | endif
    " if getbufvar(l:bufid, 'coc_explorer_mappings', 0) | return | endif
    " call setbufvar(l:bufid, 'coc_explorer_mappings', 1)

    " Prevent coc-explorer's mappings from conflicting with ours
    call nvim_buf_set_keymap(l:bufid,
      \ 'n', 'r', '<Plug>(coc-explorer-key-n-r)', {'nowait': v:true})
    call nvim_buf_set_keymap(l:bufid,
      \ 'n', 't', '<Plug>(coc-explorer-key-n-t)', {'nowait': v:true})
    call nvim_buf_set_keymap(l:bufid,
      \ 'n', '<C-t>', '<Plug>(coc-explorer-key-n-[C-t])', {'nowait': v:true})
  endfun
  call timer_start(0, function('<SID>CocExplorerMappingsCb'))
endfun

augroup vimrc_CocExplorerMappings
  autocmd!
  autocmd BufEnter,WinEnter * call <SID>CocExplorerMappings()
augroup END
" }}}

" coctree mappings {{{
fun! s:CocTreeMappings()
  let l:bufid = bufnr()
  fun! s:CocTreeMappingsCb(_) closure
    if getbufvar(l:bufid, '&ft') != 'coctree' | return | endif
    " if getbufvar(l:bufid, 'coc_tree_mappings', 0) | return | endif
    " call setbufvar(l:bufid, 'coc_tree_mappings', 1)

    call nvim_buf_set_keymap(l:bufid, 'n', '<C-c>', ':q<CR>', {'silent': v:true})
    silent! call nvim_buf_del_keymap(l:bufid, 'n', '<Space>')
  endfun
  " BUG: this needs a delay otherwise our mappings get overridden when CocTree
  " updates to a new document
  call timer_start(100, function('<SID>CocTreeMappingsCb'))
endfun

augroup vimrc_CocTreeMappings
  autocmd!
  autocmd BufEnter * call <SID>CocTreeMappings()
augroup END
" }}}

" Disable line wrapping for coctree {{{
augroup vimrc_CocTreeDisableWrap
  autocmd!
  autocmd FileType coctree set nowrap
augroup END
" }}}

" Hide status line for coc-explorer/coctree {{{
" FIXME: this is buggy. Ideally airline would have a user event to hook
" fun! s:CocDisableStatusLine()
"   let l:filetypes = ['coc-explorer', 'coctree']
"   let l:wincount = winnr('$')
"   let l:windows = map(range(1, l:wincount), {_,v -> {
"     \   'id': v,
"     \   'ft': getbufvar(winbufnr(v), '&ft'),
"     \ } })
"   call filter(l:windows, {_,v -> index(l:filetypes, v.ft) >= 0 })
"   fun! s:CocDisableStatusLineCb(_) closure
"     if l:wincount != winnr('$') | return | endif
"     for w in l:windows
"       call setwinvar(l:w.id, '&stl', '%#Normal#')
"     endfor
"   endfun
"   call timer_start(0, function('<SID>CocDisableStatusLineCb'))
" endfun

" augroup vimrc_CocDisableStatusLine
"   autocmd!
"   autocmd BufEnter,BufWinEnter,TabEnter * call <SID>CocDisableStatusLine()
"   autocmd FileType coc-explorer call <SID>CocDisableStatusLine()
"   autocmd FileType coctree call <SID>CocDisableStatusLine()
" augroup END
" }}}

" Scrolling in floating windows {{{
fun! s:CocScroll(cmd, ...)
  if coc#float#has_scroll()
    call call("coc#float#scroll", a:000)
    return "\<Ignore>"
  endif
  return a:cmd
endfun

nnoremap <expr> <C-e> <SID>CocScroll("\<C-e>", 1, 1)
nnoremap <expr> <C-y> <SID>CocScroll("\<C-y>", 0, 1)
xnoremap <expr> <C-e> <SID>CocScroll("\<C-e>", 1, 1)
xnoremap <expr> <C-y> <SID>CocScroll("\<C-y>", 0, 1)
inoremap <expr> <C-e> <SID>CocScroll("<C-r>=coc#rpc#request('doKeymap', ['snippets-expand',''])<CR>", 1, 1)
" C-y can also used for snippet completion in insert mode
inoremap <silent> <expr> <C-y> <SID>CocScroll(
  \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand',''])\<CR>", 0, 1)

nmap <expr> <PageDown> <SID>CocScroll("\<Plug>(SmoothieForwards)", 1)
nmap <expr> <PageUp> <SID>CocScroll("\<Plug>(SmoothieBackwards)", 0)
xmap <expr> <PageDown> <SID>CocScroll("\<Plug>(SmoothieForwards)", 1)
xmap <expr> <PageUp> <SID>CocScroll("\<Plug>(SmoothieBackwards)", 0)
imap <expr> <PageDown> <SID>CocScroll("<C-o>\<Plug>(SmoothieForwards)", 1)
imap <expr> <PageUp> <SID>CocScroll("<C-o>\<Plug>(SmoothieBackwards)", 0)

nmap <expr> <C-d> <SID>CocScroll("\<Plug>(SmoothieDownwards)", 1)
nmap <expr> <C-u> <SID>CocScroll("\<Plug>(SmoothieUpwards)", 0)
xmap <expr> <C-d> <SID>CocScroll("\<Plug>(SmoothieDownwards)", 1)
xmap <expr> <C-u> <SID>CocScroll("\<Plug>(SmoothieUpwards)", 0)
imap <expr> <C-d> <SID>CocScroll("\<C-o>\<Plug>(SmoothieDownwards)", 1)
imap <expr> <C-u> <SID>CocScroll("\<C-o>\<Plug>(SmoothieUpwards)", 0)
" }}}

" Refresh the completion suggestions {{{
inoremap <silent> <expr> <C-Space> coc#refresh()
" }}}

" Snippet completion {{{
inoremap <silent> <C-e> <C-r>=coc#rpc#request('doKeymap', ['snippets-expand',''])<CR>
" }}}

" Diagnostics {{{
nnoremap <silent> <Space>dd :CocDiagnostics<CR>
" }}}

" Code navigation {{{
nmap <silent> gd :<C-U>call CocActionAsync('jumpDefinition', v:false)<CR>
nmap <silent> gy :<C-U>call CocActionAsync('jumpTypeDefinition', v:false)<CR>
nmap <silent> gi :<C-U>call CocActionAsync('jumpImplementation', v:false)<CR>
nmap <silent> gr :<C-U>call CocActionAsync('jumpReferences', v:false)<CR>

nnoremap <silent> <Space>dci :call CocAction('showIncomingCalls')<CR>
nnoremap <silent> <Space>dco :call CocAction('showOutgoingCalls')<CR>
nnoremap <silent> <Space>do :call CocAction('showOutline')<CR>
" }}}

" Refactoring {{{
" Rename symbol
nmap <Space>drr <Plug>(coc-rename)

" Rename file
nnoremap <silent> <Space>drf :CocCommand workspace.renameCurrentFile<CR>
" }}}

" Show documentation {{{
nnoremap <silent> <C-a> :call CocActionAsync('doHover')<CR>
" }}}

" Formatting code {{{
xmap <Space>dff <Plug>(coc-format-selected)
nmap <Space>dff <Plug>(coc-format)
" }}}

" Code actions {{{
nmap <C-Space> <Plug>(coc-codeaction)
xmap <C-Space> <Plug>(coc-codeaction-selected)

" Apply AutoFix to problem on the current line.
nmap <Space>dfx <Plug>(coc-fix-current)
nmap <silent> <Space>dfu :call CocAction('runCommand', 'editor.action.organizeImport')<CR>
" }}}

" Preview document (markdown) {{{
fun! s:PreviewDocument()
  if &ft != 'markdown' | return | endif
  execute 'Glow'
  execute "normal! \<C-w>|\<C-w>_"
  call nvim_win_set_config(0, {'border': 'none'})
endfun

nnoremap <silent> <Space>dp :call <SID>PreviewDocument()<CR>
" }}}

" CocList {{{
nnoremap <silent> <C-t> <nop>
nnoremap <silent> <C-t>t :CocList tasks<CR>
nnoremap <silent> <C-t><C-t> :CocList tasks<CR>

nnoremap <silent> <C-f> <nop>
nnoremap <silent> <C-f><C-r> :FZFMru<CR>
nnoremap <silent> <C-f>r :FZFMru<CR>
nnoremap <silent> <C-f><C-f> :Files<CR>
nnoremap <silent> <C-f>f :Files<CR>
nnoremap <silent> <C-f><C-g> :Rg<CR>
nnoremap <silent> <C-f>g :Rg<CR>
nnoremap <silent> <C-f><C-b> :Rg<CR>
nnoremap <silent> <C-f>b :Buffers<CR>
nnoremap <silent> <C-h> :Buffers<CR>
nnoremap <silent> <C-f>/ :Lines<CR>
nnoremap <silent> <C-f><C-_> :Lines<CR>
nnoremap <silent> <C-_> :BLines<CR>

" Unmap ctrl-b because it's the tmux leader
nnoremap <silent> <C-b> <nop>
" }}}

" Text objects {{{
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" }}}

augroup vimrc_CocActions
  autocmd!

  " Highlight symbols on hover
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')

  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END
" }}}

" wilder {{{
fun! s:WilderInit()
  call wilder#setup({
    \ 'modes': [':', '/', '?'],
    \ 'next_key': '<Tab>',
    \ 'previous_key': '<S-Tab>',
    \ 'accept_key': '<Down>',
    \ 'reject_key': '<Up>',
    \ })

  let s:scale = [
    \ '#f4468f', '#fd4a85', '#ff507a', '#ff566f', '#ff5e63',
    \ '#ff6658', '#ff704e', '#ff7a45', '#ff843d', '#ff9036',
    \ '#f89b31', '#efa72f', '#e6b32e', '#dcbe30', '#d2c934',
    \ '#c8d43a', '#bfde43', '#b6e84e', '#aff05b',
    \ ]

  let s:gradient = map(s:scale, {i, fg -> wilder#make_hl(
    \ 'WilderGradient' . i, 'Pmenu', [{}, {}, {'foreground': fg}]
    \ )})

  let s:highlighters = wilder#highlighter_with_gradient([
    \ wilder#pcre2_highlighter(),
    \ wilder#basic_highlighter(),
    \ ])

  let s:popupmenu_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
    \ 'border': 'rounded',
    \ 'empty_message': wilder#popupmenu_empty_message_with_spinner(),
    \ 'highlights': {
    \   'gradient': s:gradient,
    \ },
    \ 'highlighter': s:highlighters,
    \ 'left': [
    \   ' ',
    \   wilder#popupmenu_devicons(),
    \   wilder#popupmenu_buffer_flags({
    \     'flags': ' a + ',
    \     'icons': {'+': '', 'a': '', 'h': ''},
    \   }),
    \ ],
    \ 'right': [
    \   ' ',
    \   wilder#popupmenu_scrollbar(),
    \ ],
    \ }))

  call wilder#set_option('pipeline', [
    \ wilder#branch(
    \   wilder#python_file_finder_pipeline({
    \     'file_command': {_, arg -> stridx(arg, '.') != -1 ? ['fd', '-tf', '-H'] : ['fd', '-tf']},
    \     'dir_command': ['fd', '-td'],
    \     'filters': ['cpsm_filter'],
    \   }),
    \   wilder#cmdline_pipeline({
    \     'fuzzy': 1,
    \     'fuzzy_filter': wilder#lua_fzy_filter(),
    \     'hide_in_substitute': 1,
    \   }),
    \   [
    \     wilder#check({_, x -> empty(x)}),
    \     wilder#history(),
    \   ],
    \   wilder#python_search_pipeline({
    \     'pattern': wilder#python_fuzzy_pattern({
    \       'start_at_boundary': 0,
    \     }),
    \   }),
    \ ),
    \ ])

  let s:wildmenu_renderer = wilder#wildmenu_renderer({
    \ 'highlighter': s:highlighters,
    \ 'separator': ' · ',
    \ 'left': [' ', wilder#wildmenu_spinner(), ' '],
    \ 'right': [' ', wilder#wildmenu_index()],
    \ })

  call wilder#set_option('renderer', wilder#renderer_mux({
    \ ':': s:popupmenu_renderer,
    \ '/': s:wildmenu_renderer,
    \ }))
endfun

augroup vimrc_WilderConfig
  autocmd!
  autocmd CmdlineEnter * ++once call <SID>WilderInit()
augroup END

" Workaround for a neovim bug (#14304)
" https://github.com/gelguy/wilder.nvim/issues/41#issuecomment-860025867
fun! s:SetShortmessF(on) abort
  if a:on
    set shortmess+=F
  else
    set shortmess-=F
  endif
  return ''
endfun

nnoremap <expr> : <SID>SetShortmessF(1) . ':'

augroup vimrc_WilderShortmessFix
  autocmd!
  autocmd CmdlineLeave * call <SID>SetShortmessF(0)
augroup END
" }}}

" Lightline {{{
let g:lightline = {
\   'colorscheme': 'jellybeans',
\   'component_function': {
\     'filetype': 'LightlineFiletype',
\     'fileformat': 'LightlineFileformat',
\     'fileencoding': 'Lightline',
\     'gps': 'LightlineGps',
\   },
\   'tab_component_function': {
\     'fticon': 'LightlineTabIcon',
\     'filename': 'LightlineTabFilename',
\   },
\   'tab': {
\     'active': ['filename', 'fticon'],
\     'inactive': ['filename', 'fticon'],
\   },
\   'active': {
\     'left': [
\       ['mode', 'paste'],
\       ['readonly', 'filename', 'modified'],
\       ['gps'],
\     ],
\     'right': [
\       ['lineinfo'],
\       [
\         'linter_info',
\         'linter_hints',
\         'linter_errors',
\         'linter_warnings',
\       ],
\       ['fileformat', 'fileencoding', 'filetype'],
\     ],
\   },
\   'inactive': {
\     'right': [],
\   },
\   'subseparator': { 'left': '|', 'right': '|' },
\   'component_expand': {
\     'linter_warnings': expand('<SID>').'LightlineCocWarnings',
\     'linter_errors': expand('<SID>').'LightlineCocErrors',
\     'linter_info': expand('<SID>').'LightlineCocInfo',
\     'linter_hints': expand('<SID>').'LightlineCocHints',
\   },
\   'component_type': {
\     'linter_warnings': 'warning',
\     'linter_errors': 'error',
\     'linter_info': 'tabsel',
\     'linter_hints': 'hints',
\    }
\ }

augroup vimrc_LightlineCoc
  autocmd!
  autocmd User CocDiagnosticChange call lightline#update()
  autocmd User CocStatusChange call lightline#update()
  " TODO: update on ModeChanged when this is resolved: https://github.com/neovim/neovim/issues/4399
augroup END

" let g:coc_diagnostic_indicator_checking = ' '
let g:coc_diagnostic_indicator_info = '﯂ '
let g:coc_diagnostic_indicator_hints = ' '
let g:coc_diagnostic_indicator_warnings = ' '
let g:coc_diagnostic_indicator_errors = '× '
let g:coc_diagnostic_indicator_ok = ' '

fun! s:LightlineCocWarnings()
  if mode() =~# '^i' | return '' | endif
  let l:stat = get(b:coc_diagnostic_info, 'warning', 0)
  if !l:stat | return '' | endif
  return g:coc_diagnostic_indicator_warnings . l:stat
endfun

fun! s:LightlineCocErrors()
  if mode() =~# '^i' | return '' | endif
  let l:stat = get(b:coc_diagnostic_info, 'error', 0)
  if !l:stat | return '' | endif
  return g:coc_diagnostic_indicator_errors . l:stat
endfun

fun! s:LightlineCocInfo()
  if mode() =~# '^i' | return '' | endif
  let l:stat = get(b:coc_diagnostic_info, 'information', 0)
  if !l:stat | return '' | endif
  return g:coc_diagnostic_indicator_info . l:stat
endfun

fun! s:LightlineCocHints()
  if mode() =~# '^i' | return '' | endif
  let l:stat = get(b:coc_diagnostic_info, 'hints', 0)
  if !l:stat | return '' | endif
  return g:coc_diagnostic_indicator_hints . l:stat
endfun

let g:taboo_tabline = 0
let g:taboo_tab_format = ' %f%m '

fun! LightlineFiletype()
  if &columns <= 70 | return '' | endif
  if &filetype == 'qf' | return '' | endif
  return strlen(&filetype)
    \ ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol()
    \ : 'no ft'
endfun

fun! LightlineFileformat()
  if &columns <= 70 | return '' | endif
  if &filetype == 'qf' | return '' | endif
  return &fileformat . ' ' . WebDevIconsGetFileFormatSymbol()
endfun

fun! LightlineGps()
  if luaeval("require'nvim-gps'.is_available()")
    return luaeval("require'nvim-gps'.get_location()")
  endif
  return ''
endfun

fun! LightlineTabIcon(n)
  let l:buflist = tabpagebuflist(a:n)
  let l:winnr = tabpagewinnr(a:n)
  let l:name = expand('#' . l:buflist[l:winnr - 1] . ':t')
  let l:icon = WebDevIconsGetFileTypeSymbol(l:name)
  return l:icon !=# '' ? l:icon : ''
endfun

fun! LightlineTabFilename(n) abort
  return TabooTabTitle(a:n)
endfun
" }}}

" Appearance {{{
fun! s:SetColorschemePreferences()
  " These preferences clear some gruvbox background colours,
  " allowing transparency.
  " hi SignColumn ctermbg=NONE guibg=NONE
  hi! Todo ctermbg=NONE guibg=NONE

  " This makes unused code gray
  hi! link CocFadeOut NonText

  " The background is wrong
  " https://github.com/morhetz/gruvbox/issues/260
  hi! link vimUserFunc clear
  hi! clear Operator
  hi! htmlBold cterm=bold ctermfg=223 ctermbg=NONE gui=bold guifg=fg guibg=NONE
  hi! htmlItalic cterm=italic ctermfg=223 ctermbg=NONE gui=italic guifg=fg guibg=NONE
  hi! htmlBoldItalic cterm=bold,italic ctermfg=223 ctermbg=NONE gui=bold,italic guifg=fg guibg=NONE
  hi! htmlUnderlineItalic cterm=underline,italic ctermfg=223 ctermbg=NONE gui=underline,italic guifg=fg guibg=NONE
  hi! htmlBoldUnderline cterm=bold,underline ctermfg=223 ctermbg=NONE gui=bold,underline guifg=fg guibg=NONE
  hi! htmlUnderline cterm=underline ctermfg=223 ctermbg=NONE gui=underline guifg=fg guibg=NONE
  hi! htmlBoldUnderlineItalic cterm=bold,underline,italic ctermfg=223 ctermbg=NONE gui=bold,underline,italic guifg=fg guibg=NONE

  doautocmd User vimrc_ColorSchemePost
endfun

augroup vimrc_ColorschemePreferences
  autocmd!
  autocmd ColorScheme * call <SID>SetColorschemePreferences()
augroup END

let g:gruvbox_italic = 1
set termguicolors " Enable True Color (24-bit)
set background=dark
colorscheme gruvbox-material

" function! s:SynStack()
"   if !exists("*synstack")
"     return
"   endif
"   echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
" endfunc
" nnoremap <silent> q :call <SID>SynStack()<CR>
" }}}
