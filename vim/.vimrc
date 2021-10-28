" vim:foldmethod=marker

" Compatibility {{{
scriptencoding utf-8
set nocompatible
set encoding=utf-8
set timeoutlen=1000
set ttimeoutlen=0

" Enable True Color (24-bit)
set termguicolors

let g:is_unix = has('unix')
let g:is_win = has('win32')
let g:is_gui = has('gui_running')

" Vim compatibility
if !has('nvim')
  " Fix certain terminals not getting recognized as 256-color capable
  set t_Co=256

  " Disable termresponses on vim to prevent artifacts with kitty
  " https://github.com/vim/vim/issues/3197#issuecomment-549086639
  set t_RB= t_RF= t_RV= t_u7=

  " Fixes scrolling issues with st
  set ttymouse=sgr

  " Fix redrawing issues with kitty
  " https://github.com/kovidgoyal/kitty/issues/108#issuecomment-320492663
  set t_ut=
endif
" }}}

" Helpers {{{
fun! s:SetHl(id, opts)
  let l:props = get(a:opts, 'props', {})
  execute('hi! clear ' . a:id)
  let l:cmd = 'hi! ' . a:id
  for [l:key, l:settings] in items(l:props)
    if type(l:settings) == v:t_string
      let l:cmd .= ' ' . l:key . '=' . l:settings
    elseif type(l:settings) == v:t_dict
      let l:default = get(l:settings, 'default', 'NONE')
      let l:value = s:GetHlProp(settings.copy_from, settings.prop, settings.mode, l:default)
      let l:cmd .= ' ' . l:key . '=' . l:value
    else
      echoerr printf('Invalid property (%s) of type %s', l:key, type(l:settings))
    endif
  endfor
  execute(l:cmd)
endfun

fun! s:GetHlProp(id, prop, mode, default = 'NONE')
  let l:value = synIDattr(synIDtrans(hlID(a:id)), a:prop, a:mode)
  if l:value ==# ''
    return a:default
  endif
  return l:value
endfun

fun! FormatTerm(str, opts)
  return s:TermFormat(a:str, a:opts)
endfun

fun! s:TermFormat(str, opts)
  fun! s:Format(val, formats)
    let l:ret = a:val
    if l:ret =~ '^\d\+$' && str2nr(l:ret) < 256
      let l:ret = printf(a:formats['16'], l:ret)
    elseif l:ret =~ '^#' && len(l:ret) == 7
      let l:ret = printf(a:formats['256'],
        \ str2nr(l:ret[1:2], 16),
        \ str2nr(l:ret[3:4], 16),
        \ str2nr(l:ret[5:6], 16),
        \ )
    elseif l:ret =~ '^#' && len(l:ret) == 4
      let l:ret = printf(a:formats['256'],
        \ str2nr(l:ret[1], 16),
        \ str2nr(l:ret[2], 16),
        \ str2nr(l:ret[3], 16),
        \ )
    else
      let l:ret = ''
    endif

    return l:ret
  endfun

  let l:bg = s:Format(get(a:opts, 'bg', ''), {
    \ '16': "\x1b[48;5;%sm",
    \ '256': "\x1b[48;2;%d;%d;%dm",
    \ })
  let l:fg = s:Format(get(a:opts, 'fg', ''), {
    \ '16': "\x1b[38;5;%sm",
    \ '256': "\x1b[38;2;%d;%d;%dm",
    \ })

  return l:fg . l:bg . a:str
endfun
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
Plug 'sainnhe/gruvbox-material'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
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
Plug 'luukvbaal/stabilize.nvim'
Plug 'folke/todo-comments.nvim'
Plug 'folke/trouble.nvim'
Plug 'romainl/vim-qf'
" Plug 'kevinhwang91/nvim-bqf'
Plug 'nvim-lua/plenary.nvim'
Plug 'ellisonleao/glow.nvim'
Plug 'wesQ3/vim-windowswap'
Plug 'numtostr/FTerm.nvim'
Plug 'kwkarlwang/bufresize.nvim'
" Automatically creates missing LSP diagnostics highlight groups
" Plug 'folke/lsp-colors.nvim'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-treesitter/playground'
" Plug 'nvim-treesitter/nvim-tree-docs'
Plug 'romgrk/nvim-treesitter-context'
Plug 'RRethy/nvim-treesitter-textsubjects'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'windwp/nvim-ts-autotag'
Plug 'p00f/nvim-ts-rainbow'
Plug 'SmiteshP/nvim-gps'
Plug 'theHamsta/nvim-treesitter-pairs'
Plug 'windwp/nvim-autopairs'
Plug 'kevinoid/vim-jsonc'
Plug 'LnL7/vim-nix'
Plug 'xolox/vim-misc'
Plug 'tikhomirov/vim-glsl'
Plug 'kkoomen/vim-doge', { 'do': {-> doge#install()} }
" Plug 'tpope/vim-commentary'
Plug 'numToStr/Comment.nvim'
Plug 'AndrewRadev/tagalong.vim'
Plug 'lambdalisue/suda.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-dotenv'
Plug 'tpope/vim-dadbod'
Plug 'inkarkat/vim-ReplaceWithRegister'
" Plug 'PeterRincker/vim-argumentative'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-fold'
Plug 'gcmt/taboo.vim'
Plug 'mhinz/vim-startify'
" TODO: switch to Telescope for Trouble integration?
Plug 'junegunn/fzf', { 'do': {-> fzf#install()} }
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
" This must be loaded last
Plug 'kyazdani42/nvim-web-devicons'
call plug#end()
" }}}

" mkdir -p on save {{{
" https://stackoverflow.com/questions/4292733/vim-creating-parent-directories-on-save
fun! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&bt')) && a:file !~# '\v^\w+\:\/'
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

" Line wrapping
set breakat=" 	!@*-+;:,./?"

" Show some context around the cursor
set scrolloff=5
set sidescrolloff=1

" Set max command history
set history=10000

" Prevent screen from redrawing while executing commands
set lazyredraw

" Always show the signcolumn, otherwise it would shift the text each time the
" signcolumn is triggered
augroup vimrc_SignColumn
  autocmd!
  autocmd BufWinEnter * set signcolumn=yes:1
  " Hide signcolumn for nofile buffers
  autocmd BufWinEnter * if &bt ==# 'nofile' | setl signcolumn=no | endif
augroup END

" Window-local settings
fun! s:SetWindowLocalSettings()
  if &bt !=# ''
    \ && &bt !=# 'acwrite'
    \ && &ft !=# 'qf'
    setlocal nonumber norelativenumber
    return
  endif

  " Show line numbers
  setlocal number norelativenumber
  setlocal numberwidth=5
  " Enable line wrapping
  setlocal wrap linebreak
  " Enable list mode
  setlocal list
endfun

augroup vimrc_WindowLocalSettings
  autocmd!
  autocmd VimEnter,TabNewEntered,WinEnter,BufEnter * call s:SetWindowLocalSettings()
  autocmd User StartifyBufferOpened call s:SetWindowLocalSettings()
augroup END

" Cursor position (handled by lightline)
set noruler

" Make undesirable characters more apparent
set listchars=tab:\ →,nbsp:␣,trail:·,extends:▶,precedes:◀

" Set the filling characters
set fillchars=eob:\ ,stl:\ ,stlnc:\ ,vert:\|,fold:·,diff:-

" Enable mouse interaction
set mouse=a

" Enable wildmenu
set wildmenu
set wildmode=full

" Highlight current line
set cursorline nocursorcolumn
" }}}

" Search and substitution {{{
" Incremental search
set incsearch

" Case-insensitive search
" unless there's a capital character
set ignorecase
set smartcase

" Disable search highlight after pressing ENTER
" https://stackoverflow.com/questions/657447/vim-clear-last-search-highlighting
nnoremap <silent> <CR> <Cmd>noh<CR><CR>

" Live substitutions
if has('nvim')
  set inccommand=split
endif
" }}}

" Disable builtin plugins {{{
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1
let g:loaded_zipPlugin = 1
let g:loaded_zip = 1
" }}}

" shortmess {{{
" Shorten a bunch of messages
set shortmess=a

" Disable the vim intro message
set shortmess+=I

" Disable 'pattern not found' messages
set shortmess+=c

" Hide file info when editing a file
set shortmess+=F
" }}}

" highlightedyank {{{
" Highlight yanks for quarter of a second
let g:highlightedyank_highlight_duration = 250
" }}}

" tagalong {{{
let g:tagalong_filetypes = [
  \ 'html',
  \ 'xml',
  \ 'jsx',
  \ 'tsx',
  \ 'typescript',
  \ 'javascript',
  \ 'typescriptreact',
  \ 'javascriptreact',
  \ 'typescriptcommon',
  \ 'javascriptcommon',
  \ ]
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

" Icons {{{
lua <<EOF
require'nvim-web-devicons'.setup {
  override = {
    [".gitattributes"] = {
      icon = "",
      color = "#fc4c25",
      name = "GitAttributes",
    },
    [".gitconfig"] = {
      icon = "",
      color = "#fc4c25",
      name = "GitConfig",
    },
    [".gitignore"] = {
      icon = "",
      color = "#fc4c25",
      name = "GitIgnore",
    },
    [".gitmodules"] = {
      icon = "",
      color = "#fc4c25",
      name = "GitModules",
    },
    [".ignore"] = {
      icon = "",
      color = "#C2C8CA",
      name = "Ignore",
    },
    [".editorconfig"] = {
      icon = "",
      color = "#C2C8CA",
      name = "Editorconfig",
    },
    ["cjs"] = {
      icon = "",
      color = "#f1e05a",
      name = "Cjs",
    },
    ["rs"] = {
      icon = "",
      color = "#cc6933",
      name = "Rs"
    },
    ["default_icon"] = {
      icon = "",
      color = "#6d8086",
      name = "Default",
    },
  },
  default = true,
}
EOF
" }}}

" Filetypes {{{
augroup vimrc_FileTypes
  autocmd! BufNewFile,BufRead *.fx set filetype=glsl
  autocmd! BufNewFile,BufRead *.fxh set filetype=glsl
  autocmd! BufNewFile,BufRead .ignore set filetype=conf
augroup END
" }}}

" General mappings {{{
" Free C-f/C-b so we can use it for other mappings {{{
nnoremap <C-f> <nop>
" Unmap C-b because it's the tmux leader
nnoremap <C-b> <nop>
" }}}

" Unmap C-c to prevent the "Type :qa and press <Enter> to exit Nvim" message from showing up {{{
noremap <C-c> <nop>
" }}}

" Close windows with C-c {{{
fun! s:CtrlC()
  " Close CoC floating windows
  if coc#float#has_float()
    call coc#float#close_all()
    return
  endif

  " Delete terminal buffers
  if &bt == 'terminal'
    execute("bd")
    return
  endif

  " Close all floating windows before running :q
  let l:wins = nvim_list_wins()
  for l:winnr in l:wins
    let l:config = nvim_win_get_config(l:winnr)
    if l:config.relative != ''
      call nvim_win_close(l:winnr, v:false)
    endif
  endfor

  execute("confirm q")
endfun

nnoremap <C-c> <Cmd>call <SID>CtrlC()<CR>
" }}}

" Floating term (fterm) {{{
" Toggle in normal mode
nnoremap <C-t>t <Cmd>lua require'FTerm'.toggle()<CR>
nnoremap <C-t><C-t> <Cmd>lua require'FTerm'.toggle()<CR>
" Toggle in terminal mode
tnoremap <C-t>t <Cmd>call <SID>Esc()<CR>
tnoremap <C-t><C-t> <Cmd>call <SID>Esc()<CR>
" }}}

" Close floating windows with Esc key {{{
fun! s:Esc()
  if coc#float#has_float()
    call coc#float#close_all()
    return
  endif

  if &ft ==# 'FTerm'
    lua require'FTerm'.close()
    return
  endif

  call feedkeys("\<Esc>", 'n')
endfun

nnoremap <Esc> <Cmd>call <SID>Esc()<CR>
inoremap <Esc> <Cmd>call <SID>Esc()<CR>
" }}}

" Terminal mappings {{{
fun! s:TerminalSettings()
  if &bt !=# 'terminal' | return | endif
  setlocal nonumber
  setlocal signcolumn=

  tnoremap <buffer> <C-Space> <C-\><C-n><Cmd>echo<CR>
  nnoremap <buffer> <silent> <C-Space> a

  " Close with <Esc>
  " NOTE: the echo is used to clear the cmdline message
  tnoremap <buffer> <Esc> <C-\><C-n><Cmd>echo<CR>

  if &ft ==# 'fzf'
    tnoremap <buffer> <Esc> <Cmd>q<CR>
  endif

  if &ft ==# 'FTerm'
    tunmap <buffer> <Esc>
  endif
endfun

augroup vimrc_Terminal
  autocmd TermEnter,TermOpen * call s:TerminalSettings()
augroup END
" }}}

" Stay in visual mode when indenting {{{
vnoremap <lt> <lt>gv
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

" Unmap (ctrl-)alt-up/down to prevent accidents in insert mode {{{
inoremap <silent> <M-Up> <nop>
inoremap <silent> <M-Down> <nop>
inoremap <silent> <M-S-Up> <nop>
inoremap <silent> <M-S-Down> <nop>
" Unmap ctrl-up/down in insert mode
inoremap <silent> <S-Up> <nop>
inoremap <silent> <S-Down> <nop>
" }}}

" Interactive replace {{{
nnoremap ;; :%s~~~cg<Left><Left><Left><Left>
" WARN: this conflicts with nvim-treesitter-textsubjects
" xnoremap ;; :s~~~cg<Left><Left><Left><Left>
" }}}

" Move lines {{{
inoremap <M-Up> <Cmd>move -2<CR>
inoremap <M-Down> <Cmd>move +1<CR>
nnoremap <M-Up> <Cmd>move -2<CR>
nnoremap <M-Down> <Cmd>move +1<CR>
xnoremap <silent> <M-Up> :move '<-2<CR>gv-gv
xnoremap <silent> <M-Down> :move '>+1<CR>gv-gv
xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv
" }}}

" Emacs-style navigation {{{
" inoremap <C-a> <Home>
" inoremap <C-e> <End>
inoremap <C-a> <nop>
inoremap <C-e> <nop>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
" }}}

" Tab navigation {{{
nnoremap <silent> th <Cmd>tabfirst<CR>
nnoremap <silent> tl <Cmd>tablast<CR>
nnoremap tt :tabedit<Space>
nnoremap te :edit<Space>
nnoremap tr :TabooRename<Space>
nnoremap <silent> tn <Cmd>tabnew<CR>
" nnoremap <silent> <C-t> <Cmd>tabnew<CR>
nnoremap <silent> ts <Cmd>tab split<CR>
nnoremap <silent> <M-C-Right> <Cmd>tabnext<CR>
nnoremap <silent> <M-C-Left> <Cmd>tabprev<CR>
" nnoremap <silent> <M-S-Right> <Cmd>tabnext<CR>
" nnoremap <silent> <M-S-Left> <Cmd>tabprev<CR>
nnoremap <silent> <M-Right> <Cmd>tabnext<CR>
nnoremap <silent> <M-Left> <Cmd>tabprev<CR>
nnoremap <silent> td <Cmd>windo :q<CR>

" Reorder tabs (requires manual remapping of keys through terminal emulator)
" nnoremap <silent> <F24> <Cmd>silent! tabmove +1<CR>
" nnoremap <silent> <F23> <Cmd>silent! tabmove -1<CR>
nnoremap <silent> <M-S-Right> <Cmd>silent! tabmove +1<CR>
nnoremap <silent> <M-S-Left> <Cmd>silent! tabmove -1<CR>
" }}}

" Close window {{{
nnoremap <silent> <Space>q <Cmd>confirm q<CR>
nnoremap <silent> <Space>Q <Cmd>confirm qa<CR>
nnoremap <silent> <Space>bd <Cmd>bdelete<CR>
" }}}

" Save {{{
nnoremap <silent> <Space>ww <Cmd>w<CR>

" Save (sudo)
nnoremap <silent> <Space>wW <Cmd>SudaWrite<CR>
" }}}

" Git {{{
nnoremap <silent> <Space>gg <Cmd>G<CR>
nnoremap <silent> <Space>gc <Cmd>G commit<CR>
nnoremap <silent> <Space>gb <Cmd>G blame<CR>
nnoremap <silent> <Space>gd <Cmd>Gdiffsplit<CR>
nnoremap <silent> <Space>gl <Cmd>tabnew <bar> Gclog <bar> TabooRename git log<CR>
" }}}

" Miscellaneous {{{
" Makes it so that ctrl-right doesn't skip over to the next line
inoremap <S-Right> <C-o>e

" Unmap ex mode
nnoremap Q <Nop>

" Split line (symmetrical to J)
nnoremap K a<CR><Esc>

" Toggle line wrapping
noremap <silent> <F2> <Cmd>set wrap!<CR>
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

" Hide mapping warnings
let g:VM_show_warnings = 0
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

" NOTE: this prevents conflicts with coc/coc-explorer
let g:startify_change_to_dir = 0
let g:startify_change_cmd = 'tcd'
" }}}

" indent-blankline {{{
" BUG: https://github.com/lukas-reineke/indent-blankline.nvim/issues/59#issuecomment-806374954
set colorcolumn=99999

lua << EOF
require'indent_blankline'.setup {
  use_treesitter = true,
  buftype_exclude = {"terminal"},
  filetype_exclude = {
    "qf",
    "startify",
    "help",
    "coc-explorer",
    "coctree",
    "fzf",
    "Trouble",
  },
  bufname_exclude = {
    'vimspector.Variables',
    'vimspector.Watches',
    'vimspector.StackTrace',
    'vimspector.Console',
  },
}
EOF
" }}}

" numb {{{
lua <<EOF
require'numb'.setup {}
EOF
" }}}

" todo-comments {{{
augroup vimrc_TodoComments
  autocmd!
  autocmd User vimrc_ColorSchemePost call s:SetupTodoComments()
augroup END

fun! s:SetupTodoComments()
  lua << EOF
  require'todo-comments'.setup {
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

fun! s:OpenTodoList(workspace)
  let l:path = ''
  if a:workspace
    " HACK: coc echoes the workspace folder instead of returning it...
    redir => l:path
    silent! call coc#rpc#request('runCommand', ['workspace.workspaceFolders'])
    redir END
    " The captured output contains a NULL byte and a line feed
    let l:path = substitute(l:path, '[\x0\n]', '', 'g')
  endif

  " If coc doesn't have a workspace folder, we use the current file instead
  if !strlen(l:path)
    let l:path = expand('%:p')
  endif

  call luaeval('require"trouble".open("todo", "cwd=".._A[1])', [l:path])
  " call luaeval('require("todo-comments.search").setloclist(_A[1])', [l:path])
endfun

nnoremap <silent> <Space>dt <Cmd>call <SID>OpenTodoList(0)<CR>
nnoremap <silent> <Space>dT <Cmd>call <SID>OpenTodoList(1)<CR>
" }}}

" quickfix {{{
lua <<EOF
  require'trouble'.setup {
    auto_preview = true, -- NOTE: set to false for debugging qf/loc list stuff
  }
EOF

fun! s:QfCommand(direction)
  if a:direction ==# 'down'
    if line('.') ==# line('$')
      call cursor(1, col('.'))
    else
      execute('normal! j')
    endif
  else
    if line('.') == 1
      call cursor(line('$'), col('.'))
    else
      execute('normal! k')
    endif
  endif
endfun

fun! s:QfMappings()
  nnoremap <buffer> <Up> <Cmd>call <SID>QfCommand('up')<CR>
  nnoremap <buffer> k <Cmd>call <SID>QfCommand('up')<CR>
  nnoremap <buffer> <Down> <Cmd>call <SID>QfCommand('down')<CR>
  nnoremap <buffer> j <Cmd>call <SID>QfCommand('down')<CR>
endfun

augroup vimrc_qf
  autocmd!
  autocmd FileType qf call s:QfMappings()
augroup END
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
require'bufresize'.setup {}
EOF
" }}}

" Folds {{{
" Start with everything unfolded
set foldlevelstart=99

fun! s:SetFoldSettings()
  set foldcolumn=0
  set foldignore=
  set foldmethod=expr
  set foldexpr=nvim_treesitter#foldexpr()
  " NOTE: syntax doesn't work with treesitter
  " set foldmethod=syntax
  " if &ft ==# 'vim'
  "   set foldmethod=marker
  " endif
endfun

augroup vimrc_VimFolds
  autocmd!
  autocmd FileType * call s:SetFoldSettings()
augroup END
" }}}

" Windowswap {{{
let g:windowswap_map_keys = 0
nnoremap <silent> <C-w>w <Cmd>call WindowSwap#EasyWindowSwap()<CR>
nnoremap <silent> <C-w><C-w> <Cmd>call WindowSwap#EasyWindowSwap()<CR>
nnoremap <C-w>W <nop>
" }}}

" asynctasks {{{
let g:asyncrun_open = 6
let g:asynctasks_term_pos = 'bottom'
" }}}

" Comment.nvim {{{
lua <<EOF
require'Comment'.setup {
  pre_hook = function(ctx)
    -- Integrate with ts-context-commentstring
    return require'ts_context_commentstring.internal'.calculate_commentstring()
  end
}
EOF
" }}}

" autopairs {{{
lua <<EOF
local ts_utils = require'nvim-treesitter.ts_utils'
local Rule = require'nvim-autopairs.rule'
local cond = require'nvim-autopairs.conds'
local npairs = require'nvim-autopairs'

npairs.setup {
  -- Don't pair if it already has a close pair in the same line.
  enable_check_bracket_line = true,
  -- Don't pair if the next char is alphanumeric.
  ignored_next_char = "[w]",
  -- Pair after quotes: (|"abc" => (|"abc")
  -- FIXME: doesn't seem to work?
  -- enable_afterquote = true,
}

-- Helpers {{{
function get_rules(start_pair)
  local tbl = {}
  for _, r in pairs(npairs.config.rules) do
    if r.start_pair == start_pair then
      table.insert(tbl, r)
    end
  end
  return tbl
end

function add_pair(rule, cond)
  if rule.pair_cond == nil then rule.pair_cond = {} end
  table.insert(rule.pair_cond, 1, cond)
end

function get_ts_lang()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local _, _, lang_root = ts_utils.get_root_for_position(row, col)
  if lang_root == nil then
    return nil
  end
  -- vim.api.nvim_echo({{lang_root:lang(), 'None'}}, true, {})
  return lang_root:lang()
end

local not_word_char_next = cond.not_after_regex_check("%w", 1)
--- }}}

-- Vim {{{
vim.tbl_map(function(v)
  -- Never pair " because they're also used for comments
  add_pair(v, function(opts)
    if get_ts_lang() == "vim" then
      return false
    end
  end)
end, get_rules'"')
--- }}}

-- Don't pair if a word char is next {{{
for _, c  in pairs({'(', '{', '[', '"', "'"}) do
  vim.tbl_map(function(r)
    add_pair(r, not_word_char_next)
  end, get_rules(c))
end
--- }}}
EOF
" }}}

" gps {{{
lua <<EOF
require'nvim-gps'.setup {
  icons = {
    ["class-name"] = ' ',      -- Classes and class-like objects
    ["function-name"] = ' ',   -- Functions
    ["method-name"] = ' ',     -- Methods (functions inside class-like objects)
    ["container-name"] = '⛶ ',  -- Containers (example: lua tables)
    ["tag-name"] = '炙'         -- Tags (example: html tags)
  },
  separator = ' > ',
}
EOF
" }}}

" treesitter {{{
" Do nothing if we hit the inc. selection mapping in visual mode
xnoremap gnn <nop>

command! -nargs=0 TSPlaygroundUpdate lua require'nvim-treesitter-playground.internal'.update()

lua <<EOF
require'treesitter-context'.setup {
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
        --     'impl_item',
        --   },
    },
}
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  highlight = {
    -- false will disable the whole extension
    enable = true,
    -- list of language that will be disabled
    disable = {
      "json",
      "jsonc",
      -- NOTE: bash lang breaks with zsh scripts
      "bash",
    },
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
    config = {
      vim = {
        __default = "\" %s",
        lua_statement = "-- %s",
      }
    }
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

" nvim-treesitter-textobjects {{{
lua <<EOF
require'nvim-treesitter.configs'.setup {
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
    },
  },
}
EOF

fun! s:TextobjectMapping(lhs, rhs)
  execute("onoremap " . a:lhs . " <Cmd>lua require'nvim-treesitter.textobjects.select'.select_textobject('" . a:rhs .  "', 'o')<CR>")
endfun

call s:TextobjectMapping('af', '@function.outer')
call s:TextobjectMapping('if', '@function.inner')
call s:TextobjectMapping('ac', '@class.outer')
call s:TextobjectMapping('ic', '@class.inner')
call s:TextobjectMapping('aa', '@parameter.outer')
call s:TextobjectMapping('ia', '@parameter.inner')
call s:TextobjectMapping('ac', '@comment.outer')
call s:TextobjectMapping('ic', '@comment.outer')
call s:TextobjectMapping('as', '@statement.outer')
call s:TextobjectMapping('is', '@statement.outer')
" }}}
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
" let g:argumentative_no_mappings = 1
" nmap ,b <Plug>Argumentative_Prev
" nmap ,w <Plug>Argumentative_Next
" xmap ,b <Plug>Argumentative_XPrev
" xmap ,w <Plug>Argumentative_XNext
" nmap ,< <Plug>Argumentative_MoveLeft
" nmap ,> <Plug>Argumentative_MoveRight
" xmap ia <Plug>Argumentative_InnerTextObject
" xmap aa <Plug>Argumentative_OuterTextObject
" omap ia <Plug>Argumentative_OpPendingInnerTextObject
" omap aa <Plug>Argumentative_OpPendingOuterTextObject
" }}}

" Spaces {{{
call textobj#user#plugin('space', {
\ '-': {
\   '*sfile*': expand('<sfile>:p'),
\   'select-a': 'a<Space>', '*select-a-function*': 's:SelectSpaces_a',
\   'select': '<Space>', '*select-function*': 's:SelectSpaces_i',
\   'select-i': 'i<Space>', '*select-i-function*': 's:SelectSpaces_i',
\ }
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
  \ 'CodeLLDB',
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

nmap <silent> <Space>dq <Cmd>VimspectorReset<CR>
nmap <silent> <Space>de <Plug>VimspectorBalloonEval
vmap <silent> <Space>de <Plug>VimspectorBalloonEval
nmap <silent> <Space>dx <Cmd>call vimspector#ListBreakpoints()<CR>

" Signs
fun! s:SetVimspectorColors()
  call s:SetHl('vimspectorBP', {
    \ 'props': {
    \   'ctermbg': {'copy_from': 'SignColumn', 'mode': 'cterm', 'prop': 'bg'},
    \   'guibg':   {'copy_from': 'SignColumn', 'mode': 'gui', 'prop': 'bg'},
    \   'ctermfg': {'copy_from': 'ErrorMsg', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'ErrorMsg', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })
  call s:SetHl('vimspectorBPCond', {
    \ 'props': {
    \   'ctermbg': {'copy_from': 'SignColumn', 'mode': 'cterm', 'prop': 'bg'},
    \   'guibg':   {'copy_from': 'SignColumn', 'mode': 'gui', 'prop': 'bg'},
    \   'ctermfg': {'copy_from': 'ErrorMsg', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'ErrorMsg', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })
  call s:SetHl('vimspectorBPLog', {
    \ 'props': {
    \   'ctermbg': {'copy_from': 'SignColumn', 'mode': 'cterm', 'prop': 'bg'},
    \   'guibg':   {'copy_from': 'SignColumn', 'mode': 'gui', 'prop': 'bg'},
    \   'ctermfg': {'copy_from': 'Underlined', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'Underlined', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })
  call s:SetHl('vimspectorBPDisabled', {
    \ 'props': {
    \   'ctermbg': {'copy_from': 'SignColumn', 'mode': 'cterm', 'prop': 'bg'},
    \   'guibg':   {'copy_from': 'SignColumn', 'mode': 'gui', 'prop': 'bg'},
    \   'ctermfg': {'copy_from': 'LineNr', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'LineNr', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })

  " Other colors: #16162a #151d29 #212429
  call s:SetHl('vimspectorCursorLine', {
    \ 'props': {
    \   'ctermbg': '236',
    \   'guibg': '#181e29',
    \ }
    \ })
  call s:SetHl('vimspectorCursorLineSpecial', {
    \ 'props': {
    \   'ctermfg': {'copy_from': 'Special', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg': {'copy_from': 'Special', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })
endfun

augroup vimrc_VimspectorColors
  autocmd!
  autocmd ColorScheme * call s:SetVimspectorColors()
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
\ 'vimspectorBP':         12,
\ 'vimspectorBPCond':     12,
\ 'vimspectorBPLog':      12,
\ 'vimspectorBPDisabled': 12,
\ 'vimspectorPC':         999,
\ }

function! s:CustomiseUI()
  call win_gotoid(g:vimspector_session_windows.output)
  q
endfunction

augroup vimrc_vimspectorUI
  autocmd!
  autocmd User VimspectorUICreated call s:CustomiseUI()
augroup END
" }}}

" FZF {{{
let $FZF_DEFAULT_COMMAND='rg --files --hidden || true'

fun! s:FzfSink(what)
  let p1 = stridx(a:what, '<')
  if l:p1 >= 0
    let name = strpart(a:what, 0, p1)
    let name = substitute(l:name, '^\s*\(.\{-}\)\s*$', '\1', '')
    if name != ''
      exec "AsyncTask ". fnameescape(l:name)
    endif
  endif
endfun

fun! s:FzfTask()
  let l:rows = asynctasks#source(&columns * 48 / 100)
  let l:source = []
  for l:row in l:rows
    let l:source += [
      \ s:TermFormat(l:row[0], {
      \   'bg': s:GetHlProp('Constant', 'bg', 'cterm'),
      \   'fg': s:GetHlProp('Constant', 'fg', 'cterm'),
      \ }) . "\x1b[0m  " .
      \ s:TermFormat(l:row[1], {
      \   'bg': s:GetHlProp('Type', 'bg', 'cterm'),
      \   'fg': s:GetHlProp('Type', 'fg', 'cterm'),
      \ }) . "\x1b[0m  : " .
      \ s:TermFormat(l:row[2], {
      \   'bg': s:GetHlProp('Comment', 'bg', 'cterm'),
      \   'fg': s:GetHlProp('Comment', 'fg', 'cterm'),
      \ })
      \ ]
  endfor
  let l:opts = {
    \ 'source': l:source,
    \ 'sink': function('s:FzfSink'),
    \ 'options': '+m --ansi',
    \ }
  call fzf#run(fzf#wrap('tasks', l:opts))
endfun

command! -nargs=0 AsyncTaskFzf call s:FzfTask()

nnoremap <silent> <C-t> <nop>
nnoremap <silent> <C-t>g <Cmd>AsyncTaskFzf<CR>
nnoremap <silent> <C-t><C-g> <Cmd>AsyncTaskFzf<CR>

nnoremap <silent> <C-f> <nop>
" inoremap <silent> <C-f><C-y> <Cmd>CocFzfList yank<CR>
" inoremap <silent> <C-f>y <Cmd>CocFzfList yank<CR>
nnoremap <silent> <C-f><C-y> <Cmd>CocFzfList yank<CR>
nnoremap <silent> <C-f>y <Cmd>CocFzfList yank<CR>
nnoremap <silent> <C-f><C-r> <Cmd>FZFMru<CR>
nnoremap <silent> <C-f>r <Cmd>FZFMru<CR>
nnoremap <silent> <C-f><C-f> <Cmd>Files<CR>
nnoremap <silent> <C-f>f <Cmd>Files<CR>
nnoremap <silent> <C-f><C-g> <Cmd>Rg<CR>
nnoremap <silent> <C-f>g <Cmd>Rg<CR>
nnoremap <silent> <C-f><C-b> <Cmd>Rg<CR>
nnoremap <silent> <C-f>b <Cmd>Buffers<CR>
nnoremap <silent> <C-h> <Cmd>Buffers<CR>
nnoremap <silent> <C-f>/ <Cmd>Lines<CR>
nnoremap <silent> <C-f><C-_> <Cmd>Lines<CR>
nnoremap <silent> <C-_> <Cmd>BLines<CR>

augroup vimrc_fzf
  autocmd!
  " Closes FZF when pressing escape instead of returning to normal mode
  autocmd FileType fzf tnoremap <buffer> <Esc> <Cmd>q<CR>
augroup END
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
  \ 'destructuring_props': 1,
  \ 'omit_redundant_param_types': 1,
  \ }

nmap <silent> <Space>dd <Plug>(doge-generate)
" }}}

" Completion popup navigation {{{
" This enables:
"   - registers.nvim navigation
"   - snippet jumping
"   - suggestion navigation
inoremap <silent> <expr> <Tab>
  \ &ft ==# 'registers'
  \   ? "\<Down>" :
  \ pumvisible()
  \   ? "\<C-n>" :
  \ coc#jumpable()
  \   ? "\<Cmd>call coc#rpc#request('snippetNext', [])\<CR>" :
  \ <SID>CanSuggest()
  \   ? coc#refresh()
  \   : "\<Tab>"
snoremap <silent> <expr> <Tab>
  \ coc#jumpable()
  \   ? "\<C-g><Cmd>call coc#rpc#request('snippetNext', [])\<CR>"
  \   : "\<Tab>"
inoremap <silent> <expr> <S-Tab>
  \ &ft ==# 'registers'
  \   ? "\<Up>" :
  \ pumvisible()
  \   ? "\<C-p>" :
  \ coc#jumpable()
  \   ? "\<Cmd>call coc#rpc#request('snippetPrev', [])\<CR>"
  \   : "\<C-h>"
snoremap <silent> <expr> <S-Tab>
  \ coc#jumpable()
  \   ? "\<C-g><Cmd>call coc#rpc#request('snippetPrev', [])\<CR>"
  \   : "\<S-Tab>"
inoremap <silent> <expr> <CR>
  \ pumvisible()
  \ ? "\<C-y>"
  \ : "\<C-g>u\<CR>\<Cmd>call coc#on_enter()\<CR>"

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
" Helpers {{{
let s:coc_config = {}

fun! s:merge(defaults, override) abort
  let l:new = copy(a:defaults)
  for [l:k, l:v] in items(a:override)
    let l:new[l:k] = (type(l:v) is v:t_dict && type(get(l:new, l:k)) is v:t_dict)
      \ ? s:merge(l:new[l:k], l:v)
      \ : l:v
  endfor
  return l:new
endfun

fun! s:CocConfig(section, value)
  let s:coc_config[a:section] = s:merge(get(s:coc_config, a:section, {}), a:value)
endfun
" }}}

" Extensions {{{
" WARN: coc-sh is nice but the LSP symbol resolution is slow/buggy
let g:coc_global_extensions = [
  \ 'coc-explorer',
  \ 'coc-git',
  \ 'coc-db',
  \ 'coc-rust-analyzer',
  \ 'coc-clangd',
  \ 'coc-highlight',
  \ 'coc-tasks',
  \ 'coc-lists',
  \ 'coc-yank',
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
" }}}

" Prevent coc from creating a default.vim session {{{
call s:CocConfig('session', {
  \ 'saveOnVimLeave': v:false,
  \ })
" }}}

" coc-git {{{
call s:CocConfig('git', {
  \ 'addedSign': { 'hlGroup': 'GitGutterAdd' },
  \ 'changedSign': { 'hlGroup': 'GitGutterChange' },
  \ 'removedSign': { 'hlGroup': 'GitGutterDelete' },
  \ 'topRemovedSign': { 'hlGroup': 'GitGutterDelete' },
  \ 'changeRemovedSign': { 'hlGroup': 'GitGutterChangeDelete' },
  \ 'signPriority': 11,
  \ })

" Blame virtual text {{{
" This enables b:coc_git_blame
call s:CocConfig('git', {
  \ 'addGBlameToBufferVar': v:true,
  \ })

fun! s:UpdateGitVirtualText()
  if get(g:, 'show_git_blame_vt_ns', 0) <= 0
    let g:show_git_blame_vt_ns = nvim_create_namespace('git_blame')
  endif

  call nvim_buf_clear_namespace(bufnr(), g:show_git_blame_vt_ns, 0, -1)
  if !get(g:, 'show_git_blame_vt', 0)
    return
  endif
  let l:blame = get(b:, 'coc_git_blame', '')
  try
    call nvim_buf_set_extmark(
      \ bufnr(),
      \ g:show_git_blame_vt_ns,
      \ line('.') - 1,
      \ 0,
      \ {
      \   'virt_text': [[l:blame, 'CocCodeLens']],
      \   'virt_text_pos': 'overlay',
      \   'virt_text_win_col': strdisplaywidth(getline('.')) + 1,
      \   'hl_mode': 'combine',
      \ })
  catch /.*E5555.*/
  endtry
endfun

augroup vimrc_gitVirtualText
  autocmd!
  autocmd CursorHold * call s:UpdateGitVirtualText()
augroup END

fun! s:ToggleGitVirtualText()
  let g:show_git_blame_vt = !get(g:, 'show_git_blame_vt', 0)
  call s:UpdateGitVirtualText()
endfun

nnoremap <Space>gv <Cmd>call s:ToggleGitVirtualText()<CR>
" }}}
" }}}

" coc-prettier {{{
call s:CocConfig('prettier', {
  \ 'onlyUseLocalVersion': v:true,
  \ 'requireConfig': v:true,
  \ 'disableSuccessMessage': v:true,
  \ })
" }}}

" coc-tsserver {{{
call s:CocConfig('tsserver', {
  \ 'disableAutomaticTypeAcquisition': v:false,
  \ })

call s:CocConfig('typescript', {
  \ 'implementationsCodeLens': { 'enabled': v:false },
  \ })

call s:CocConfig('javascript', {
  \ 'suggestionActions': { 'enabled': v:false },
  \ })
" }}}

" coc-rust-analyzer {{{
call s:CocConfig('rust-analyzer', {
  \ 'lens': {
  \   'enable': v:true,
  \   'run': v:false,
  \   'references': v:true,
  \   'implementations': v:true,
  \   'methodReferences': v:true,
  \   'enumVariantReferences': v:true,
  \ },
  \ 'inlayHints': {
  \   'enable': v:true,
  \   'typeHints': v:true,
  \   'chainingHints': v:true,
  \   'typeHintsSeparator': '‣',
  \   'chainingHintsSeparator': '‣',
  \ },
  \ 'debug': {
  \   'runtime': 'vimspector',
  \   'vimspector': {'configuration': {'name': '_launch_coc_ra'}},
  \ },
  \ })
" }}}

" Prevents the cursor from disappearing when pressing ctrl-c in :CocList {{{
" NOTE: this is not necessary when ctrl-c is remapped
" let g:coc_disable_transparent_cursor = 1
" }}}

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

" coc-explorer {{{
call s:CocConfig('explorer', {
  \ 'icon': {
  \   'enableNerdfont': v:true,
  \   'source': 'nvim-web-devicons',
  \ },
  \ 'root': {
  \   'strategies': [
  \     'keep',
  \     'workspace',
  \     'cwd',
  \     'sourceBuffer',
  \     'reveal',
  \   ],
  \ },
  \ 'file': {
  \   'cdCommand': 'tcd',
  \   'hiddenRules': {
  \     'extensions': ['o', 'a', 'obj', 'pyc'],
  \     'filenames': ['node_modules'],
  \     'patternMatches': ['^\\.'],
  \   },
  \   'reveal': {
  \     'filter': {
  \       'literals': ['node_modules'],
  \     },
  \   },
  \ },
  \ 'presets': {
  \   'floatingLeft': {
  \     'position': 'floating',
  \     'floating-position': 'left-center',
  \     'floating-width': 40,
  \     'floating-height': 0,
  \     'open-action-strategy': 'sourceWindow',
  \     'file-child-template': '[git | 2] [selection | clip | 1] [indent][icon | 1] [diagnosticError & 1][filename omitCenter 1][modified][readonly] [linkIcon & 1][link growRight 1 omitCenter 5]',
  \     'toggle': v:true,
  \     'focus': v:true,
  \   }
  \ },
  \ 'floating': {
  \   'border': {
  \     'enable': v:true,
  \     'title': ' Explorer',
  \     'chars': [
  \       ' ',
  \       '│',
  \       ' ',
  \       ' ',
  \       '',
  \       ' |',
  \       ' |',
  \       '',
  \     ],
  \   }
  \ },
  \ 'keyMappings': {
  \   'global': {
  \     'u': ['wait', 'gotoParent'],
  \     'r': 'rename',
  \     '<cr>': [
  \       'expandable?',
  \       ['expanded?', 'collapse', 'expand'],
  \       ['open', 'quit']
  \     ],
  \     't': ['open:tab'],
  \     'T': ['open:tab'],
  \     '<C-t>': ['open:tab'],
  \     'o': ['wait', 'expandable?', 'cd', 'open'],
  \     'F': 'search',
  \     'f': 'search:recursive',
  \   },
  \ },
  \ })

nnoremap <silent> <Bar> <Cmd>CocCommand explorer --sources=buffer+ --preset floatingLeft<CR>
nnoremap <silent> \ <Cmd>CocCommand explorer --sources=file+ --preset floatingLeft<CR>
nnoremap <silent> à <Cmd>CocCommand explorer --sources=file+ --preset floatingLeft<CR>
nnoremap <silent> <Space>ecd <Cmd>execute('tcd ' . expand("%:p:h"))<CR>

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
  autocmd BufEnter,WinEnter * call s:CocExplorerMappings()
augroup END

fun! s:SetupCocExplorerColors()
  hi link CocExplorerNormalFloat Clear
  hi link CocExplorerNormalFloatBorder Clear
endfun

augroup vimrc_CocExplorerColors
  autocmd!
  autocmd User vimrc_ColorScheme call s:SetupCocExplorerColors()
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
  autocmd BufEnter * call s:CocTreeMappings()
augroup END
" }}}

" Disable line wrapping for coctree {{{
augroup vimrc_CocTreeDisableWrap
  autocmd!
  autocmd FileType coctree set nowrap
augroup END
" }}}

" Snippets {{{
call s:CocConfig('snippets', {
  \ 'extends': {
  \   'javascriptreact': ['javascript'],
  \   'typescriptreact': ['javascript'],
  \   'typescript': ['javascript'],
  \ },
  \ })

" NOTE: this prevents coc-tsserver from providing default snippets
" XXX: unfortunately this disables snippets for all coc extensions
call s:CocConfig('snippets', {
  \ 'loadFromExtensions': v:false,
  \ })

inoremap <silent> <C-e> <Cmd>call coc#rpc#request('doKeymap', ['snippets-expand',''])<CR>
" }}}

" Refresh the completion suggestions {{{
inoremap <silent> <expr> <C-Space> coc#refresh()
" }}}

" Code lens {{{
nnoremap <Space>c <Cmd>call CocActionAsync('codeLensAction')<CR>
call s:CocConfig('codeLens', {
  \ 'enable': v:true,
  \ 'separator': '‣',
  \ 'subseparator': ' ',
  \ })
" }}}

" Hover {{{
call s:CocConfig('hover', {
  \ 'floatConfig': {
  \   'border': v:false,
  \   'highlight': 'CocFloating',
  \   'focusable': v:true,
  \ },
  \ })
" }}}

" Formatting {{{
call s:CocConfig('coc', {
  \ 'preferences': {
  \   'formatOnType': v:true,
  \   'bracketEnterImprove': v:false,
  \   'formatOnSaveFiletypes': [
  \     'rust',
  \     'javascript',
  \     'typescript',
  \     'cs',
  \     'css',
  \     'markdown'
  \   ],
  \ },
  \ })
" }}}

" Suggest {{{
" BUG: 'struct' should use icon '\ufb44'. Unfortunately nerd-fonts maps it to
" a hebrew codepoint, which changes the text direction to right-to-left:
" https://github.com/ryanoasis/nerd-fonts/issues/478
call s:CocConfig('suggest', {
  \ 'autoTrigger': 'none',
  \ 'enablePreselect': v:false,
  \ 'noselect': v:true,
  \ 'completionItemKindLabels': {
  \   'keyword': '',
  \   'variable': '',
  \   'value': '',
  \   'operator': 'Ψ',
  \   'constructor': '',
  \   'function': 'ƒ',
  \   'reference': '渚',
  \   'constant': '',
  \   'method': '',
  \   'struct': '',
  \   'class': '',
  \   'interface': '',
  \   'text': '',
  \   'enum': '',
  \   'enumMember': '',
  \   'module': '',
  \   'color': '',
  \   'property': '',
  \   'field': '料',
  \   'unit': '',
  \   'event': '鬒',
  \   'file': '',
  \   'folder': '',
  \   'snippet': '',
  \   'typeParameter': '',
  \   'default': ''
  \ },
  \ })
" }}}

" Completion {{{
call s:CocConfig('coc', {
  \ 'source': {
  \   'around': {'priority': 50},
  \   'buffer': {'priority': 51},
  \ }
  \ })

call s:CocConfig('suggest', {
  \ 'languageSourcePriority': 49,
  \ })
" }}}

" Diagnostics {{{
call s:CocConfig('diagnostic', {
  \ 'warningSign': '',
  \ 'infoSign': '',
  \ 'errorSign': '',
  \ 'hintSign': '',
  \ 'signPriority': 9,
  \ })

fun! s:OpenDiagnostics(update = 0)
  " For current buffer only: call coc#rpc#request('fillDiagnostics', [bufnr('%')])
  if !coc#rpc#ready() | return | endif
  " let l:list = coc#rpc#request('diagnosticList', [])
  let l:list = coc#rpc#request('diagnosticList', [])
  if type(l:list) != v:t_list | return | endif
  let l:UriToBufnr = luaeval('vim.uri_to_bufnr')
  fun! s:FormatItem(_, item) closure
    let l:severity = type(a:item.severity) == v:t_string && strlen(a:item.severity)
      \ ? a:item.severity[0]
      \ : '?'
    let l:bufnr = 0
    if has_key(a:item, 'location') && has_key(a:item.location, 'uri')
      let l:bufnr = l:UriToBufnr(a:item.location.uri)
      call bufload(l:bufnr)
    endif

    let l:range = a:item.location.range

    return {
      \ 'lnum': l:range.start.line + 1,
      \ 'col': l:range.start.character + 1,
      \ 'end_lnum': l:range.end.line + 1,
      \ 'end_col': l:range.end.character + 1,
      \ 'bufnr': l:bufnr,
      \ 'type': l:severity,
      \ 'text': printf('[%s %d] %s',
      \   a:item.source,
      \   a:item.code,
      \   a:item.message),
      \ 'valid': 1,
      \ }
  endfun

  " HACK: TypeScript is too dumb to ignore errors from excluded files
  call filter(l:list, {idx,v -> !(v.source ==# "tsserver" && fnamemodify(v.file, ':.') =~ 'node_modules/')})

  call map(l:list, function('<SID>FormatItem'))
  call setqflist(l:list, 'r')

  if a:update
    lua require'trouble'.refresh('quickfix')
  else
    lua require'trouble'.open('quickfix')
  endif
endfun

" FIXME: unfortunately this seems to cause instabilities in neovim's RPC
" augroup vimrc_CocDiagnostics
"   autocmd!
"   autocmd User CocDiagnosticChange call s:OpenDiagnostics(1)
" augroup END

nnoremap <silent> <Space>dc <Cmd>call <SID>OpenDiagnostics()<CR>
" }}}

" Diagnostics navigation {{{
nmap <silent> [g <Cmd>call CocActionAsync('diagnosticPrevious')<CR>
nmap <silent> ]g <Cmd>call CocActionAsync('diagnosticNext')<CR>
" }}}

" Code navigation {{{
nmap <silent> gd <Cmd>call CocActionAsync('jumpDefinition', v:false)<CR>
nmap <silent> gy <Cmd>call CocActionAsync('jumpTypeDefinition', v:false)<CR>
nmap <silent> gi <Cmd>call CocActionAsync('jumpImplementation', v:false)<CR>
nmap <silent> gr <Cmd>call CocActionAsync('jumpReferences', v:false)<CR>

nnoremap <silent> <Space>doi <Cmd>call CocAction('showIncomingCalls')<CR>
nnoremap <silent> <Space>doo <Cmd>call CocAction('showOutgoingCalls')<CR>
nnoremap <silent> <Space>dot <Cmd>call CocAction('showOutline')<CR>
" }}}

" Refactoring {{{
" Rename symbol
nmap <Space>drr <Plug>(coc-rename)

" Rename file
nnoremap <silent> <Space>drf <Cmd>CocCommand workspace.renameCurrentFile<CR>
" }}}

" Show documentation {{{
nnoremap <silent> <C-a> <Cmd>call CocActionAsync('definitionHover')<CR>
inoremap <silent> <C-a> <Cmd>call CocActionAsync('showSignatureHelp')<CR>
" }}}

" Formatting code {{{
xmap <Space>dff <Plug>(coc-format-selected)
nmap <Space>dff <Plug>(coc-format)
" }}}

" Code actions {{{
nmap <silent> <C-Space> <Plug>(coc-codeaction)
xmap <silent> <C-Space> <Plug>(coc-codeaction-selected)

" Apply AutoFix to problem on the current line.
nmap <Space>dfx <Plug>(coc-fix-current)
nmap <silent> <Space>dfu <Cmd>call CocAction('runCommand', 'editor.action.organizeImport')<CR>
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
vnoremap <expr> <C-e> <SID>CocScroll("\<C-e>", 1, 1)
vnoremap <expr> <C-y> <SID>CocScroll("\<C-y>", 0, 1)
inoremap <silent> <expr> <C-e> <SID>CocScroll("\<Cmd>call coc#rpc#request('doKeymap', ['snippets-expand',''])<CR>", 1, 1)
" C-y can also used for snippet completion in insert mode
inoremap <silent> <expr> <C-y> <SID>CocScroll(
  \ "\<Cmd>call coc#rpc#request('doKeymap', ['snippets-expand',''])\<CR>", 0, 1)

nmap <expr> <PageDown> <SID>CocScroll("\<Plug>(SmoothieForwards)", 1)
nmap <expr> <PageUp> <SID>CocScroll("\<Plug>(SmoothieBackwards)", 0)
vmap <expr> <PageDown> <SID>CocScroll("\<Plug>(SmoothieForwards)", 1)
vmap <expr> <PageUp> <SID>CocScroll("\<Plug>(SmoothieBackwards)", 0)
imap <expr> <PageDown> <SID>CocScroll("<C-o>\<Plug>(SmoothieForwards)", 1)
imap <expr> <PageUp> <SID>CocScroll("<C-o>\<Plug>(SmoothieBackwards)", 0)

nmap <expr> <C-d> <SID>CocScroll("\<Plug>(SmoothieDownwards)", 1)
nmap <expr> <C-u> <SID>CocScroll("\<Plug>(SmoothieUpwards)", 0)
vmap <expr> <C-d> <SID>CocScroll("\<Plug>(SmoothieDownwards)", 1)
vmap <expr> <C-u> <SID>CocScroll("\<Plug>(SmoothieUpwards)", 0)
imap <expr> <C-d> <SID>CocScroll("\<C-o>\<Plug>(SmoothieDownwards)", 1)
imap <expr> <C-u> <SID>CocScroll("\<C-o>\<Plug>(SmoothieUpwards)", 0)
" }}}

" Preview document (markdown) {{{
fun! s:PreviewDocument()
  if &ft != 'markdown' | return | endif
  execute 'Glow'
  execute "normal! \<C-w>|\<C-w>_"
  call nvim_win_set_config(0, {'border': 'none'})
endfun

nnoremap <silent> <Space>dp <Cmd>call <SID>PreviewDocument()<CR>
" }}}

" coc-list {{{
call s:CocConfig('list', {
  \ 'source': {
  \   'files': {
  \     'command': 'rg',
  \     'args': ['--hidden', '--files'],
  \   },
  \   'mru': {
  \     'ignoreGitIgnore': v:true,
  \   },
  \ },
  \ 'normalMappings': {
  \   '<C-c>': 'do:exit',
  \ },
  \ 'insertMappings': {
  \   '<C-c>': 'do:exit',
  \ },
  \ })
" }}}

" Yank {{{
call s:CocConfig('yank', {
  \ 'enableCompletion': v:false,
  \ })
" }}}

" Text objects {{{
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
" xmap if <Plug>(coc-funcobj-i)
" omap if <Plug>(coc-funcobj-i)
" xmap af <Plug>(coc-funcobj-a)
" omap af <Plug>(coc-funcobj-a)
" xmap ic <Plug>(coc-classobj-i)
" omap ic <Plug>(coc-classobj-i)
" xmap ac <Plug>(coc-classobj-a)
" omap ac <Plug>(coc-classobj-a)
" }}}

" Miscellaneous {{{
augroup vimrc_CocActions
  autocmd!

  " Highlight symbols on hover
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')

  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END

" TODO: https://github.com/neoclide/coc.nvim/pull/3355
call s:CocConfig('coc', {
  \ 'preferences': {
  \   'semanticTokensHighlights': v:false,
  \ },
  \ })
" }}}

" Apply config {{{
for [section, value] in items(s:coc_config)
  call coc#config(section, value)
endfor
" }}}
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

  let l:scale = [
    \ '#f4468f', '#fd4a85', '#ff507a', '#ff566f', '#ff5e63',
    \ '#ff6658', '#ff704e', '#ff7a45', '#ff843d', '#ff9036',
    \ '#f89b31', '#efa72f', '#e6b32e', '#dcbe30', '#d2c934',
    \ '#c8d43a', '#bfde43', '#b6e84e', '#aff05b',
    \ ]

  let l:gradient = map(l:scale, {i, fg -> wilder#make_hl(
    \ 'WilderGradient' . i, 'Pmenu', [{}, {}, {'foreground': fg}]
    \ )})

  let l:Highlighter = wilder#highlighter_with_gradient([
    \ wilder#pcre2_highlighter(),
    \ wilder#basic_highlighter(),
    \ ])

  let l:popupmenu_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
    \ 'border': 'rounded',
    \ 'empty_message': wilder#popupmenu_empty_message_with_spinner(),
    \ 'highlights': {
    \   'gradient': l:gradient,
    \ },
    \ 'highlighter': l:Highlighter,
    \ 'left': [
    \   ' ',
    \   wilder#popupmenu_devicons({
    \     'get_icon': wilder#devicons_get_icon_from_nvim_web_devicons(),
    \     'get_hl': wilder#devicons_get_hl_from_nvim_web_devicons(),
    \   }),
    \   wilder#popupmenu_buffer_flags({
    \     'flags': ' a + ',
    \     'icons': {'+': '', 'a': '', 'h': ''},
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

  let l:wildmenu_renderer = wilder#wildmenu_renderer({
    \ 'highlighter': l:Highlighter,
    \ 'separator': ' · ',
    \ 'left': [' ', wilder#wildmenu_spinner(), ' '],
    \ 'right': [' ', wilder#wildmenu_index()],
    \ })

  call wilder#set_option('renderer', wilder#renderer_mux({
    \ ':': l:popupmenu_renderer,
    \ '/': l:wildmenu_renderer,
    \ }))
endfun

augroup vimrc_WilderConfig
  autocmd!
  autocmd CursorHold * ++once call s:WilderInit()
augroup END
" }}}

" Lightline {{{
let g:lightline = {
\ 'colorscheme': 'jellybeans',
\ 'component_function': {
\   'readonly': expand('<SID>').'LightlineReadonly',
\   'modified': expand('<SID>').'LightlineModified',
\   'mode': expand('<SID>').'LightlineMode',
\   'filename': expand('<SID>').'LightlineFilename',
\   'filetype': expand('<SID>').'LightlineFiletype',
\   'fileformat': expand('<SID>').'LightlineFileformat',
\   'fileencoding': expand('<SID>').'LightlineFileencoding',
\   'lineinfo': expand('<SID>').'LightlineLineinfo',
\   'git': expand('<SID>').'LightlineGit',
\   'gps': expand('<SID>').'LightlineGps',
\ },
\ 'tab_component_function': {
\   'fticon': expand('<SID>').'LightlineTabIcon',
\   'filename': expand('<SID>').'LightlineTabFilename',
\ },
\ 'tab': {
\   'active': ['filename', 'fticon'],
\   'inactive': ['filename', 'fticon'],
\ },
\ 'active': {
\   'left': [
\     ['mode', 'paste'],
\     ['readonly', 'filename', 'modified'],
\     ['gps'],
\   ],
\   'right': [
\     ['lineinfo'],
\     [
\       'linter_info',
\       'linter_hints',
\       'linter_errors',
\       'linter_warnings',
\     ] ,
\     ['fileformat', 'fileencoding', 'filetype', 'git'],
\   ],
\ },
\ 'inactive': {
\   'left': [['readonly', 'filename', 'modified']],
\   'right': [],
\ },
\ 'subseparator': { 'left': '|', 'right': '|' },
\ 'component_expand': {
\   'linter_warnings': expand('<SID>').'LightlineCocWarnings',
\   'linter_errors': expand('<SID>').'LightlineCocErrors',
\   'linter_info': expand('<SID>').'LightlineCocInfo',
\   'linter_hints': expand('<SID>').'LightlineCocHints',
\ },
\ 'component_type': {
\   'linter_warnings': 'warning',
\   'linter_errors': 'error',
\   'linter_info': 'tabsel',
\   'linter_hints': 'hints',
\ },
\ }

augroup vimrc_LightlineCoc
  autocmd!
  autocmd User CocDiagnosticChange call lightline#update()
  autocmd User CocStatusChange call lightline#update()
  " TODO: update on ModeChanged when this is resolved: https://github.com/neovim/neovim/issues/4399
augroup END

fun! s:LightlineIsHidden()
  if get(b:, 'lightline_hidden', v:false)
    return v:true
  endif

  let l:filetypes = [
    \ 'Trouble',
    \ 'startify',
    \ 'list',
    \ 'help',
    \ 'git',
    \ 'gitrebase',
    \ 'gitcommit',
    \ 'fugitive',
    \ 'fugitiveblame',
    \ 'qf',
    \ 'coctree',
    \ 'coc-explorer',
    \ ]
  let l:filenames = [
    \ 'vimspector.Variables',
    \ 'vimspector.Watches',
    \ 'vimspector.StackTrace',
    \ 'vimspector.Console'
    \ ]

  return &bt ==# 'terminal'
    \ || index(l:filetypes, &ft) != -1
    \ || index(l:filenames, expand('%:t')) != -1
endfunction

" Components {{{
" TODO: other symbols
" checking/loading: 
" ok: 
fun! s:LightlineCocWarnings()
  if mode() =~# '^i' | return '' | endif
  let l:stat = get(b:coc_diagnostic_info, 'warning', 0)
  if !l:stat | return '' | endif
  return ' ' . l:stat
endfun

fun! s:LightlineCocErrors()
  if mode() =~# '^i' | return '' | endif
  let l:stat = get(b:coc_diagnostic_info, 'error', 0)
  if !l:stat | return '' | endif
  return '× ' . l:stat
endfun

fun! s:LightlineCocInfo()
  if mode() =~# '^i' | return '' | endif
  let l:stat = get(b:coc_diagnostic_info, 'information', 0)
  if !l:stat | return '' | endif
  return '﯂ ' . l:stat
endfun

fun! s:LightlineCocHints()
  if mode() =~# '^i' | return '' | endif
  let l:stat = get(b:coc_diagnostic_info, 'hints', 0)
  if !l:stat | return '' | endif
  return ' ' . l:stat
endfun

fun! s:LightlineReadonly()
  if s:LightlineIsHidden() | return '' | endif
  if &readonly | return '﯎' | endif " RO
  return ''
endfun

fun! s:LightlineModified()
  if s:LightlineIsHidden() | return '' | endif
  if &modified | return '' | endif " +
  if ! &modifiable | return '' | endif " -
  return ''
endfun

fun! s:LightlineMode()
  if s:LightlineIsHidden() | return '' | endif
  return lightline#mode()
endfun

fun! s:LightlineFilename()
  " Filetypes
  " NOTE: other icons;  
  if &ft ==# 'help' | return ' Help' | endif
  if &ft ==# 'Trouble' | return ' Trouble' | endif
  if &ft ==# 'startify' | return ' Startify' | endif
  if &ft ==# 'coc-explorer' | return ' Explorer' | endif
  if &ft =~# '^\(git\|fugitive\)$' | return ' Git' | endif
  if &ft ==# 'fugitiveblame' | return ' Blame' | endif
  if &ft ==# 'gitrebase' | return ' Rebase' | endif
  if &ft ==# 'gitcommit' | return ' Commit' | endif
  if &ft ==# 'qf' | return ' List' | endif

  " Terminals
  if get(b:, 'asyncrun_name', '') !=# ''
    return ' ' . b:asyncrun_name
  endif
  if &bt ==# 'terminal' | return ' Terminal' | endif

  let l:fname = expand('%')
  if match(l:fname, 'vimspector\.') == 0
    return substitute(l:fname, '^vimspector\.', ' ', '')
  endif

  if s:LightlineIsHidden() | return '' | endif

  let l:name = expand('%:t')
  if l:name ==# '' | return '[untitled]' | endif

  return l:name
endfun

fun! s:LightlineFiletype()
  if &columns <= 70 | return '' | endif
  if s:LightlineIsHidden() | return '' | endif
  let l:r = luaeval("{require'nvim-web-devicons'.get_icon(_A[1], _A[2])}", [expand('%:t'), v:null])
  let l:icon = l:r[0]
  let l:color = l:r[1]
  " TODO: colors
  return strlen(&ft)
    \ ? l:icon . ' ' . &ft
    \ : 'no ft'
endfun

fun! s:LightlineFileformat()
  if &columns <= 90 | return '' | endif
  if s:LightlineIsHidden() | return '' | endif
  " Don't display unless it's not unix line endings
  if &fileformat ==# 'unix' | return '' | endif
  return &fileformat
endfun

fun! s:LightlineFileencoding()
  if &columns <= 70 | return '' | endif
  if s:LightlineIsHidden() | return '' | endif
  " Don't display unless it's some weird encoding
  if &fileencoding ==# 'utf-8' | return '' | endif
  return &fileencoding
endfun

fun! s:LightlineLineinfo()
  " NOTE: line info is useful for writing commit messsages
  if &ft !=# 'gitcommit'
    \ && s:LightlineIsHidden() | return '' | endif
  return printf('%3d:%-2d', line('.'), col('.'))
endfun

fun! s:LightlineGit()
  if &ft != 'git'
    \ && &ft != 'fugitive'
    \ && &ft != 'gitrebase'
    \ && &ft != 'gitcommit'
    \ && s:LightlineIsHidden() | return '' | endif

  let [l:obj, l:path] = FugitiveParse()
  if l:path !=# ''
    if l:obj =~# '^:0'
      return ' ' . '0000000'
    endif
    return ' ' . l:obj[:6]
  endif

  let l:info = fugitive#head()
  if l:info ==# '' | return '' | endif

  return ' '. l:info
endfunction

augroup vimrc_LightlineGit
  autocmd!
  autocmd User FugitiveChanged,FugitiveObject,FugitiveIndex call lightline#update()
augroup END

fun! s:LightlineGps()
  if luaeval("require'nvim-gps'.is_available()")
    return luaeval("require'nvim-gps'.get_location()")
  endif
  return ''
endfun
" }}}

" Tab components {{{
let g:taboo_tabline = 0
let g:taboo_tab_format = ' %f%m '

fun! s:LightlineTabIcon(n)
  let l:buflist = tabpagebuflist(a:n)
  let l:winnr = tabpagewinnr(a:n)
  let l:name = expand('#' . l:buflist[l:winnr - 1] . ':t')
  let l:r = luaeval("{require'nvim-web-devicons'.get_icon(_A[1], _A[2])}", [l:name, v:null])
  let l:icon = l:r[0]
  let l:color = l:r[1]
  " TODO: colors
  return l:icon[0] !=# '' ? l:icon : ''
endfun

fun! s:LightlineTabFilename(n) abort
  return TabooTabTitle(a:n)
endfun
" }}}
" }}}

" Appearance {{{
fun! s:SetColorScheme()
  " This makes unused code gray
  " hi! link CocFadeOut NonText

  " This changes the highlight color for search results
  hi Search ctermbg=100 guibg=#6f8352

  " Fixes Trouble highlight groups
  hi! link TroubleFoldIcon NonText
  hi! link TroubleText Clear
  call s:SetHl('TroubleSignError', {
    \ 'props': {
    \   'ctermbg': 'NONE',
    \   'guibg':   'NONE',
    \   'ctermfg': {'copy_from': 'LspDiagnosticsSignError', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'LspDiagnosticsSignError', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })
  call s:SetHl('TroubleSignInformation', {
    \ 'props': {
    \   'ctermbg': 'NONE',
    \   'guibg':   'NONE',
    \   'ctermfg': {'copy_from': 'LspDiagnosticsSignInformation', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'LspDiagnosticsSignInformation', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })
  call s:SetHl('TroubleSignWarning', {
    \ 'props': {
    \   'ctermbg': 'NONE',
    \   'guibg':   'NONE',
    \   'ctermfg': {'copy_from': 'LspDiagnosticsSignWarning', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'LspDiagnosticsSignWarning', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })
  call s:SetHl('TroubleSignHint', {
    \ 'props': {
    \   'ctermbg': 'NONE',
    \   'guibg':   'NONE',
    \   'ctermfg': {'copy_from': 'LspDiagnosticsSignHint', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'LspDiagnosticsSignHint', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })
  call s:SetHl('TroubleSignOther', {
    \ 'props': {
    \   'ctermbg': 'NONE',
    \   'guibg':   'NONE',
    \   'ctermfg': {'copy_from': 'TroubleSignInformation', 'mode': 'cterm', 'prop': 'fg'},
    \   'guifg':   {'copy_from': 'TroubleSignInformation', 'mode': 'gui', 'prop': 'fg'},
    \ }
    \ })

  doautocmd User vimrc_ColorScheme
  doautocmd User vimrc_ColorSchemePost
endfun

augroup vimrc_ColorschemePreferences
  autocmd!
  autocmd ColorScheme * call s:SetColorScheme()
augroup END

set background=dark

" tokyonight {{{
" let g:tokyonight_style = 'storm'
" colorscheme tokyonight
" }}}

" gruvbox {{{
" let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_enable_italic = 1
let g:gruvbox_material_diagnostic_line_highlight = 0
" BUG: unfortunately this doesn't work with CoC floating windows
" let g:gruvbox_material_better_performance = 1
colorscheme gruvbox-material
" }}}

" function! s:SynStack()
"   if !exists("*synstack")
"     return
"   endif
"   echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
" endfunc
" nnoremap <silent> q <Cmd>call <SID>SynStack()<CR>
" }}}
