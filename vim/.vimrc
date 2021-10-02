" Compatibility {{{
scriptencoding utf-8
set nocompatible
set encoding=utf-8
set timeoutlen=1000
set ttimeoutlen=0

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
elseif has('win32')
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
Plug 'ellisonleao/glow.nvim'
Plug 'wesQ3/vim-windowswap'
" Plug 'mattboehm/vim-accordion'
Plug 'LnL7/vim-nix'
Plug 'xolox/vim-misc'
Plug 'tikhomirov/vim-glsl'
Plug 'tpope/vim-commentary'
Plug 'lambdalisue/suda.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'PeterRincker/vim-argumentative'
Plug 'chaoren/vim-wordmotion'
Plug 'gcmt/taboo.vim'
Plug 'mhinz/vim-startify'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'romgrk/fzy-lua-native' " used by wilder
" Requires cmake, libboost-all-dev, python-dev and libicu-dev
" FIXME: install.sh exits with exitcode 1
Plug 'nixprime/cpsm', { 'do': './install.sh' } " used by wilder
Plug 'puremourning/vimspector'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'skywind3000/asynctasks.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'honza/vim-snippets'
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
augroup BWCCreateDir
  autocmd!
  autocmd BufWritePre * call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END
" }}}

" Replace gx to open urls {{{
" https://web.archive.org/web/20200129052658/https://old.reddit.com/r/vim/comments/7j9znw/gx_failing_to_open_url_on_vim8/dr6e3ks/
fun! OpenUrl() abort
  " Open the current URL
  " - If line begins with "Plug" open the github page
  " of the plugin.

  let cl = getline('.')
  let url = escape(matchstr(cl, '[a-z]*:\/\/\/\?[^ >,;()]*'), '#%')
  if cl =~# 'Plug'
    let pn = cl[match(cl, "'", 0, 1) + 1 :
          \ match(cl, "'", 0, 2) - 1]
    let url = printf("https://github.com/%s", pn)
  endif
  if !empty(url)
    let url = substitute(url, "['\"]", '', 'g')
    let wmctrl = executable('wmctrl') && v:windowid isnot# 0 ?
          \ ' && wmctrl -ia ' . v:windowid : ''
    exe 'silent :!' . (g:is_unix ?
          \   'xdg-open ' . shellescape(url) :
          \   ' start "' . shellescape(url)) .
          \ wmctrl .
          \ (g:is_unix ? ' 2> /dev/null &' : '')
    if !g:is_gui | redraw! | endif
  endif
endfun
nnoremap <silent> gx :call OpenUrl()<CR>
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

" Always show at least one one line above/below the cursor
set scrolloff=1
set sidescrolloff=5

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
noremap <silent> <C-c> :confirm q<CR>
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
let g:wordmotion_uppercase_spaces = ['=', '(', ')', '[', ']', '{', '}']
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
augroup set_formatoptions
  autocmd!
  autocmd FileType * set formatoptions-=ro
augroup END
" }}}

" Filetypes {{{
" TODO: get rid of vim-devicons and unify with coc-explorer icons
let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols = {
  \ '.ignore': "\ue615",
  \ '.editorconfig': "\ue615",
  \ }
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {
  \ 'fx': "\ue60b",
  \ 'fxh': "\ue60b",
  \ 'js': "\ue74e",
  \ 'mjs': "\ue74e",
  \ 'cjs': "\ue74e",
  \ }
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {
  \ '^\.prettierrc.*': "\ue615",
  \ '^\.eslintrc.*': "\ue615",
  \ }

augroup CustomFiletypes
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

" Make navigation with nolinewrap less jarring {{{
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
inoremap <C-a> <Home>
inoremap <C-e> <End>
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
" }}}

" indent-blankline {{{
lua << EOF
require("indent_blankline").setup {
  char = "|",
  buftype_exclude = {"terminal"},
  filetype_exclude = {"startify"},
}
EOF
" }}}

" numb {{{
lua <<EOF
require('numb').setup()
EOF
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

" Folds {{{
set foldmethod=syntax
set foldignore=
" Start with everything unfolded
set foldlevelstart=99

augroup vimrc_folds
  autocmd!
  autocmd FileType * setl foldmethod=syntax
  autocmd FileType vim setl foldmethod=marker
augroup END
" }}}

" Interactive replace {{{
nnoremap ;; :%s:::cg<Left><Left><Left><Left>
vnoremap ;; :s:::cg<Left><Left><Left><Left>
noremap ;: :s:::cg<Left><Left><Left><Left>
" }}}

" Windowswap {{{
let g:windowswap_map_keys = 0
nnoremap <silent> <Space>ws :call WindowSwap#EasyWindowSwap()<CR>
" }}}

" registers {{{
let g:registers_delay = 500
" }}}

" ReplaceWithRegister {{{
nnoremap r <nop>
nnoremap rc r
xnoremap rc r
nmap rr <Plug>ReplaceWithRegisterOperator
xmap rr <Plug>ReplaceWithRegisterVisual
nmap r^ <Plug>ReplaceWithRegisterLine
" }}}

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

" Vimspector {{{
let g:vimspector_install_gadgets = [
  \ 'netcoredbg',
  \ 'vscode-node-debug2',
  \ ]

nmap <F5> <Plug>VimspectorContinue
" <F15> = shift-f5
nmap <F15> <Plug>VimspectorStop
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

augroup VimspectorColorschemePreferences
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

" CoC {{{
let g:coc_global_extensions = [
  \ 'coc-explorer',
  \ 'coc-git',
  \ 'coc-highlight',
  \ 'coc-pairs',
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
  \ ]

" Prevents the cursor from disappearing when pressing ctrl-c in :CocList
" let g:coc_disable_transparent_cursor = 1

nnoremap <silent> <Bar> :CocCommand explorer --sources=buffer+<CR>
nnoremap <silent> \ :CocCommand explorer --sources=file+<CR>
nnoremap <silent> à :CocCommand explorer<CR>

" Close vim if coc-explorer is the last open window
augroup CocExplorerAutoClose
  autocmd!
  autocmd BufEnter * if (winnr('$') == 1 && &ft == 'coc-explorer') | q | endif
augroup END

fun! s:FixCocExplorerMappings()
  if &ft != 'coc-explorer' | return | endif
  if exists('b:coc_explorer_mapping_fix') | return | endif
  let b:coc_explorer_mapping_fix = 1

  " Prevent r mappings from conflicting with the rename function
  nmap <buffer> <nowait> r <Plug>(coc-explorer-key-n-r)
  nmap <buffer> <nowait> t <Plug>(coc-explorer-key-n-t)
endfun

augroup CocExplorerFixMappings
  autocmd!
  " Our function needs to execute after coc-explorer is done
  autocmd BufEnter * call timer_start(0, {-> <SID>FixCocExplorerMappings()})
augroup END

fun! s:DisableCocExplorerStatusline()
  let wincount = winnr('$')
  let coc_ex_winnr = index(
    \   map(range(1, l:wincount), {_,v -> getbufvar(winbufnr(v), '&ft')}),
    \   'coc-explorer'
    \ ) + 1
  call timer_start(0, {->
    \ l:wincount == winnr('$')
    \ && l:coc_ex_winnr
    \ && setwinvar(l:coc_ex_winnr, '&stl', '%#Normal#')})
endfun

augroup CocExplorerDisableStatusLine
  autocmd!
  autocmd WinEnter,BufWinEnter,TabEnter * call <SID>DisableCocExplorerStatusline()
  autocmd FileType coc-explorer call <SID>DisableCocExplorerStatusline()
augroup END

" Scrolling in floating windows {{{
nnoremap <expr> <C-e> coc#float#has_scroll() ? coc#float#scroll(1, 1) : "\<C-e>"
nnoremap <expr> <C-y> coc#float#has_scroll() ? coc#float#scroll(0, 1) : "\<C-y>"
inoremap <silent> <expr> <C-e> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0, 1)\<CR>" : "\<End>"
inoremap <silent> <expr> <C-y> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1, 1)\<CR>" : ""
vnoremap <expr> <C-e> coc#float#has_scroll() ? coc#float#scroll(1, 1) : "\<C-e>"
vnoremap <expr> <C-y> coc#float#has_scroll() ? coc#float#scroll(0, 1) : "\<C-y>"
nnoremap <expr> <PageDown> coc#float#has_scroll() ? coc#float#scroll(1) : "\<PageDown>"
nnoremap <expr> <PageUp> coc#float#has_scroll() ? coc#float#scroll(0) : "\<PageUp>"
inoremap <silent> <expr> <PageDown> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<PageDown>"
inoremap <silent> <expr> <PageUp> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<PageUp>"
vnoremap <expr> <PageDown> coc#float#has_scroll() ? coc#float#scroll(1) : "\<PageDown>"
vnoremap <expr> <PageUp> coc#float#has_scroll() ? coc#float#scroll(0) : "\<PageUp>"
" }}}

" Completion popup navigation {{{
" TODO: disable CoC suggestions while filling out a snippet
"       -> let b:coc_suggest_disable = 1
inoremap <silent> <expr> <Tab>
  \ &ft == 'registers'
  \   ? "\<Down>" :
  \ !coc#expandable() && coc#expandableOrJumpable()
  \   ? "\<C-r>=coc#rpc#request('snippetNext', [])\<CR>" :
  \ pumvisible()
  \   ? "\<C-n>" :
  \ <SID>can_suggest()
  \   ? coc#refresh()
  \   : "\<Tab>"
inoremap <silent> <expr> <S-Tab>
  \ &ft == 'registers'
  \   ? "\<Up>" :
  \ !coc#expandable() && coc#expandableOrJumpable()
  \   ? "\<C-r>=coc#rpc#request('snippetPrev'])\<CR>" :
  \ pumvisible()
  \   ? "\<C-p>"
  \   : "\<C-h>"

fun! s:can_suggest() abort
  let col = col('.') - 1
  if !col | return v:false | endif
  let c = getline('.')[col - 1]
  return l:c !~# '\s' && l:c !~# '\\'
endfun

" Refresh the completion suggestions
inoremap <silent> <expr> <C-Space> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <CR> could be remapped by other vim plugin
inoremap <silent> <expr> <CR>
  \ pumvisible()
  \ ? coc#_select_confirm()
  \ : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"
" }}}

" Diagnostics {{{
nnoremap <silent> <Space>dd :CocDiagnostics<CR>
" }}}

" Code navigation {{{
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" }}}

" Symbol renaming {{{
nmap <Space>dr <Plug>(coc-rename)
" }}}

" Show documentation {{{
fun! s:ShowDocumentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    echom "CoC RPC not ready"
    " execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfun

nnoremap <silent> <C-a> :call <SID>ShowDocumentation()<CR>
" }}}

" Formatting selected code {{{
xmap <Space>dff <Plug>(coc-format)
nmap <Space>dff <Plug>(coc-format-selected)
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
nnoremap <silent> <Space>do :CocList outline<CR>
nnoremap <silent> <Space>ds :CocList -I symbols<CR>
nnoremap <silent> <C-t>w :CocList windows<CR>
nnoremap <silent> <C-t><C-w> :CocList windows<CR>
nnoremap <silent> <C-t>b :CocList buffers<CR>
nnoremap <silent> <C-t>t :CocList tasks<CR>
nnoremap <silent> <C-t><C-t> :CocList tasks<CR>
nnoremap <silent> <C-t>r :CocList mru<CR>
nnoremap <silent> <C-t><C-r> :CocList mru<CR>
nnoremap <silent> <C-t>f :CocList files<CR>
nnoremap <silent> <C-t><C-f> :CocList files<CR>
nnoremap <silent> <C-f> :CocList grep<CR>
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

augroup CocActions
  autocmd!

  " Highlight symbols on hover
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')

  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup END
"show_documentation }}}

" wilder {{{
augroup WilderConfig
  autocmd!
  autocmd CmdlineEnter * ++once call <SID>WilderInit()
augroup END

fun! s:WilderInit()
  call wilder#setup({
    \ 'modes': [':', '/', '?'],
    \ 'next_key': '<Tab>',
    \ 'previous_key': '<S-Tab>',
    \ 'accept_key': '<Down>',
    \ 'reject_key': '<Up>',
    \ })

  let s:highlighters = [
    \ wilder#pcre2_highlighter(),
    \ wilder#basic_highlighter(),
    \ ]

  let s:popupmenu_renderer = wilder#popupmenu_renderer(wilder#popupmenu_border_theme({
    \ 'border': 'rounded',
    \ 'empty_message': wilder#popupmenu_empty_message_with_spinner(),
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
    \   wilder#branch(
    \     wilder#python_file_finder_pipeline({
    \       'file_command': {_, arg -> stridx(arg, '.') != -1 ? ['fd', '-tf', '-H'] : ['fd', '-tf']},
    \       'dir_command': ['fd', '-td'],
    \       'filters': ['cpsm_filter'],
    \     }),
    \     wilder#cmdline_pipeline({
    \       'fuzzy': 1,
    \       'fuzzy_filter': wilder#lua_fzy_filter(),
    \       'hide_in_substitute': 1,
    \     }),
    \     [
    \       wilder#check({_, x -> empty(x)}),
    \       wilder#history(),
    \     ],
    \     wilder#python_search_pipeline({
    \       'pattern': wilder#python_fuzzy_pattern({
    \         'start_at_boundary': 0,
    \       }),
    \     }),
    \   ),
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

" Workaround for a neovim bug (#14304)
" https://github.com/gelguy/wilder.nvim/issues/41#issuecomment-860025867
fun! SetShortmessF(on) abort
  if a:on
    set shortmess+=F
  else
    set shortmess-=F
  endif
  return ''
endfun

nnoremap <expr> : SetShortmessF(1) . ':'

augroup WilderShortmessFix
  autocmd!
  autocmd CmdlineLeave * call SetShortmessF(0)
augroup END
" }}}

" Lightline {{{
let g:lightline = {
\   'colorscheme': 'jellybeans',
\   'component_function': {
\     'filetype': 'LightlineFiletype',
\     'fileformat': 'LightlineFileformat',
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
\     'linter_warnings': 'lightline#coc#warnings',
\     'linter_errors': 'lightline#coc#errors',
\     'linter_info': 'lightline#coc#info',
\     'linter_hints': 'lightline#coc#hints',
\    },
\   'component_type': {
\     'linter_warnings': 'warning',
\     'linter_errors': 'error',
\     'linter_info': 'tabsel',
\     'linter_hints': 'hints',
\    }
\ }

" let g:lightline#ale#indicator_checking = "\uf110 "
let g:lightline#coc#indicator_info = "\ufbc2 "
let g:lightline#coc#indicator_hints = "\uf141 "
let g:lightline#coc#indicator_warnings = "\uf071 "
let g:lightline#coc#indicator_errors = "× "
let g:lightline#coc#indicator_ok = "\uf00c "

let g:taboo_tabline = 0
let g:taboo_tab_format = " %f%m "

fun! LightlineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfun

fun! LightlineFileformat()
  return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
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
endfun

augroup ColorschemePreferences
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
