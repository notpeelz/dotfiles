scriptencoding utf-8
set nocompatible
set encoding=utf-8
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
let &t_ut=''

" Download vim-plug if not already installed
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

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
" https://web.archive.org/web/20200112215437/https://jeffkreeftmeijer.com/vim-number/
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'https://github.com/simeji/winresizer.git'
Plug 'editorconfig/editorconfig-vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'preservim/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'andymass/vim-matchup'
Plug 'RRethy/vim-illuminate'
Plug 'Yggdroot/indentLine'
Plug 'LnL7/vim-nix'
Plug 'xolox/vim-misc'
Plug 'tikhomirov/vim-glsl'
Plug 'baopham/vim-nerdtree-unfocus'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'gcmt/taboo.vim'
Plug 'mhinz/vim-startify'
" This must be loaded last
Plug 'ryanoasis/vim-devicons'
call plug#end()

" Recursively create the directory structure
" before saving a file
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
  autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" Replace gx to open URLs
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

" Disable default vim backspace behavior
set backspace=indent,eol,start

" Always show the status line
set laststatus=2

" Reduce inactivity delay before writing to swapfile
" This also allows gitgutter to update faster
set updatetime=100

" Disable virtualedit
set virtualedit=

" Always show signcolumn (so that gitgutter doesn't pop in and out)
set signcolumn=yes

" Don't show the mode below the status bar
set noshowmode

" Enable line wrapping
set wrap linebreak nolist
set breakat=" 	!@*-+;:,./?"

" Show line numbers
set number relativenumber

" Cursor position (displayed in the bar)
set ruler

" Make undesirable characters more apparent
set list listchars=tab:→\ ,nbsp:␣,trail:·,extends:▶,precedes:◀

" Enable mouse interaction
set mouse=a

" Enable wildmenu
set wildmenu
set wildmode=list:full,full

" Highlight position
set cursorline
"set cursorcolumn

" Search highlighting
set hlsearch
set incsearch

" Indentline
let g:indentLine_concealcursor = &concealcursor
let g:indentLine_char = "┊"
let g:indentLine_fileTypeExclude = [ 'startify', 'help', 'text' ]

" Disable search highlight after pressing ENTER
" https://stackoverflow.com/questions/657447/vim-clear-last-search-highlighting
nnoremap <silent> <CR> :noh<CR><CR>

" Live substitutions
if has('nvim')
  set inccommand=split
endif

" Highlight yanks for quarter of a second
let g:highlightedyank_highlight_duration = 250

" Let Taboo save tab names with :mksession
set sessionoptions+=tabpages,globals

" Enable persistent undo history
let s:undodir = $HOME . "/.vim/undodir"
if !isdirectory(s:undodir)
  echom s:undodir
  call mkdir(s:undodir, 'p')
endif
set undofile
execute "set undodir=" . s:undodir

" Default indentation
filetype plugin indent on
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab
set fileformat=unix

" Filetypes
autocmd! BufNewFile,BufRead *.fx set filetype=glsl
autocmd! BufNewFile,BufRead *.fxh set filetype=glsl

" Move through display lines (with wrap on)
" instead of full lines
noremap <silent> j gj
noremap <silent> k gk
noremap <silent> <Down> gj
noremap <silent> <Up> gk

" Window splitting
nnoremap <silent> <Space>- :split<CR>
nnoremap <silent> <Space>= :vsplit<CR>

" Window navigation
nnoremap <silent> <C-Up> <C-w>k
nnoremap <silent> <C-Down> <C-w>j
nnoremap <silent> <C-Left> <C-w>h
nnoremap <silent> <C-Right> <C-w>l

nnoremap <silent> <Space><Up> <C-w>k
nnoremap <silent> <Space><Down> <C-w>j
nnoremap <silent> <Space><Left> <C-w>h
nnoremap <silent> <Space><Right> <C-w>l

" Skip over words 
"nnoremap <C-Left> gE
"nnoremap <C-Right> W
" Just to make navigation consistent
"nmap <C-Up> <Up>
"nmap <C-Down> <Down>

" Tab navigation
nnoremap <silent> th :tabfirst<CR>
nnoremap <silent> tl :tablast<CR>
nnoremap tt :tabedit<Space>
nnoremap tr :TabooRename<Space>
nnoremap <silent> tn :tabnew<CR>
nnoremap <silent> <C-t> :tabnew<CR>
nnoremap <silent> ts :tab split<CR>
nnoremap <silent> <M-C-Right> :tabnext<CR>
nnoremap <silent> <M-C-Left> :tabprev<CR>
nnoremap <silent> td :windo :q<CR>

" Reorder tabs
nnoremap <silent> <F24> :silent! tabmove +1<CR>
nnoremap <silent> <F23> :silent! tabmove -1<CR>

" Close window
nnoremap <silent> <Space>d :q<CR>
nnoremap <silent> <Space>D :q!<CR>
nnoremap <silent> <Space>q :qa<CR>
nnoremap <silent> <Space>Q :qa<CR>

" Open session
nnoremap <Space>s :SLoad<Space>

" Save
nnoremap <silent> <Space>w :w<CR>

" Split line (symmetrical to J)
nnoremap K i<CR><Esc>

" Define google helper functions
command! -nargs=1 Google call <SID>google(<q-args>)

fun! s:google(query)
  execute "silent !xdg-open https://google.com/search?" . shellescape(s:encode_query(a:query), 1)
  return
endfun

fun! s:google_selection(visual)
  return s:google(s:get_sel(a:visual))
endfun

fun! s:get_sel(visual)
  let l:mode = mode()
  if a:visual == 1
    let [l:line1, l:col1] = getpos("'<")[1:2]
    let [l:line2, l:col2] = getpos("'>")[1:2]
    return getline("'<")[l:col1 - 1: l:col2 - 1]
  else
    return expand('<cword>')
  endif
endfun

fun! s:encode_query(str)
python3 << EOF
import sys, vim
from urllib.parse import urlencode, quote, quote_plus
encoded = urlencode({ 'q': vim.eval('a:str') }, quote_via=quote_plus)
vim.command("return \"" + encoded.replace('"', '\\"') + "\"")
EOF
endfun

" Look up on Google
" TODO: support motions
nnoremap <Space>fx :Google<Space>
nnoremap <Space>fw :call <SID>google_selection(0)<CR>
vnoremap <Space>f :<C-u>call <SID>google_selection(1)<CR>

" Git
nnoremap <silent> <Space>gg :G<CR>
nnoremap <silent> <Space>gc :Gcommit<CR>
nnoremap <silent> <Space>gb :Gblame<CR>
nnoremap <silent> <Space>gd :Gdiff<CR>
nnoremap <silent> <Space>gl :tabnew <bar> Glog <bar> TabooRename git log<CR>

" Toggle paste mode
noremap <silent> <F2> :set paste!<CR>

" Toggle line wrapping
noremap <silent> <F3> :set wrap!<CR>

" EditorConfig
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" NERDTree
fun! OpenNERDTree()
  " Close NERDTree if focused
  if (exists("b:NERDTree") && b:NERDTree.isTabTree())
    q
    " Otherwise open/focus it
  else
    NERDTreeFocus
  endif
endfun
noremap <silent> <C-\> :NERDTreeFind<CR>
noremap <silent> \ :call OpenNERDTree()<CR>
noremap <silent> à :call OpenNERDTree()<CR>

" Exit VIM when NERDTree is the last open window
autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Show hidden files but ignore VIM swap files
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = ['\..*\.sw[pom]$']

" Hide NERDTree after opening a file
let g:NERDTreeQuitOnOpen = 1

" https://vi.stackexchange.com/questions/22398/disable-lightline-on-nerdtree
" FIXME: update this when patch 2044 is available in neovim: has('patch2044')
augroup filetype_nerdtree
  au!
  au FileType nerdtree call s:disable_lightline_on_nerdtree()
  au WinEnter,BufWinEnter,TabEnter * call s:disable_lightline_on_nerdtree()
augroup END

fun! s:disable_lightline_on_nerdtree() abort
  let nerdtree_winnr = index(map(range(1, winnr('$')), {_,v -> getbufvar(winbufnr(v), '&ft')}), 'nerdtree') + 1
  call timer_start(0, {-> nerdtree_winnr && setwinvar(nerdtree_winnr, '&stl', '%#Normal#')})
endfun

" Lightline
let g:lightline = {
  \ 'colorscheme': 'jellybeans',
  \ 'component_function': {
  \   'filetype': 'LightlineFiletype',
  \   'fileformat': 'LightlineFileformat',
  \ },
  \ 'tab_component_function': {
  \   'fticon': 'LightlineTabIcon',
  \   'filename': 'LightlineTabFilename',
  \ },
  \ 'tab': {
  \   'active': ['filename', 'fticon'],
  \   'inactive': ['tabnum', 'filename', 'fticon'],
  \ },
  \ }

let g:taboo_tabline = 0
let g:taboo_tab_format = " %r%m "

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

" Startify options
let g:startify_session_dir = '~/.vim/sessions'
let g:startify_lists = [
  \ { 'type': 'sessions',  'header': ['   Sessions']       },
  \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
  \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
  \ { 'type': 'commands',  'header': ['   Commands']       },
  \ ]

" Prevent vim-illuminate from triggering on NERDTree
let g:Illuminate_ftblacklist = ['nerdtree']

" Prevent vim-matchup from replacing the status line
let g:matchup_matchparen_offscreen = {'method': ''}

" WinResizer
let g:winresizer_enable = 1
let g:winresizer_horiz_resize = 1
let g:winresizer_vert_resize = 1
let g:winresizer_start_key = '<C-q>'
" Buggy; https://github.com/simeji/winresizer/issues/18
"nnoremap <C-e> :WinResizerStartFocus<CR>
let g:winresizer_keycode_left = "\<Left>"
let g:winresizer_keycode_up = "\<Up>"
let g:winresizer_keycode_right = "\<Right>"
let g:winresizer_keycode_down = "\<Down>"

" Case-insensitive search 
" unless there's a capital character
set ignorecase
set smartcase

" Incsearch
let g:incsearch#auto_nohlsearch = 1
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" Interactive replace
nnoremap ;; :%s:::cg<Left><Left><Left><Left>
vnoremap ;; :s:::cg<Left><Left><Left><Left>
noremap ;: :s:::cg<Left><Left><Left><Left>

" Appearance
"set termguicolors " breaks on urxvt
let g:gruvbox_italic = 1
silent! colorscheme gruvbox
set background=dark

" Fix CursorLine highlight problem with nvim
" https://github.com/neovim/neovim/issues/9019#issuecomment-521532103
if has('nvim')
  fun! s:CustomizeColors()
    if g:is_gui || has('termguicolors')
      let cursorline_gui = ''
      let cursorline_cterm = 'ctermfg=white'
    else
      let cursorline_gui = 'guifg=white'
      let cursorline_cterm = ''
    endif
    exec 'hi CursorLine ' . cursorline_gui . ' ' . cursorline_cterm 
  endfun

  augroup OnColorScheme
    autocmd!
    autocmd ColorScheme,BufEnter,BufWinEnter * call s:CustomizeColors()
  augroup END
end
