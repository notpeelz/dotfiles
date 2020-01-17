scriptencoding utf-8
set nocompatible
set encoding=utf-8
set t_Co=256

" Download vim-plug if not already installed
if has('unix')
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
Plug 'haya14busa/incsearch.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'andymass/vim-matchup'
Plug 'RRethy/vim-illuminate'
call plug#end()

" Custom intro
" https://vi.stackexchange.com/questions/627/how-can-i-change-vims-start-or-intro-screen
function! DisplayIntro()
  " Don't run if: we have commandline arguments, we don't have an empty
  " buffer, if we've not invoked as vim or gvim, or if we'e start in insert mode
  if argc() || line2byte('$') != -1 || v:progname !~? '^[-gmnq]\=vim\=x\=\%[\.exe]$' || &insertmode
    return
  endif

  " Start a new buffer ...
  enew

  " ... and set some options for it
  setlocal
    \ bufhidden=wipe
    \ buftype=nofile
    \ nobuflisted
    \ nocursorcolumn
    \ nocursorline
    \ nolist
    \ nonumber
    \ noswapfile
    \ norelativenumber

  " Print banner
  let l:prefix='        '
  call append('$', l:prefix . '__     _____ __  __')
  call append('$', l:prefix . '\ \   / /_ _|  \/  |')
  call append('$', l:prefix . ' \ \ / / | || |\/| |')
  call append('$', l:prefix . '  \ V /  | || |  | |')
  call append('$', l:prefix . '   \_/  |___|_|  |_|')

  " Print a random fortune message (if available)
  if executable('fortune')
    call append('$', '')
    for line in split(system('fortune -a'), '\n')
      call append('$', l:prefix . l:line)
    endfor
  endif

  " No modifications to this buffer
  setlocal nomodifiable nomodified

  " When we go to insert mode start a new buffer, and start insert
  nnoremap <buffer><silent> e :enew<CR>
  nnoremap <buffer><silent> i :enew <bar> startinsert<CR>
  nnoremap <buffer><silent> o :enew <bar> startinsert<CR>
endfunction

" Recursively create the directory structure
" before saving a file
" https://stackoverflow.com/questions/4292733/vim-creating-parent-directories-on-save
function! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let l:dir=fnamemodify(a:file, ':h')
    if !isdirectory(l:dir)
      call mkdir(l:dir, 'p')
    endif
  endif
endfunction
augroup BWCCreateDir
  autocmd!
  autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" Disable default vim backspace behavior
set backspace=indent,eol,start

" Always show the status line
set laststatus=2

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

" Disable search highlight after pressing ENTER
" https://stackoverflow.com/questions/657447/vim-clear-last-search-highlighting
nnoremap <silent> <CR> :noh<CR><CR>

" Live substitutions
if has('nvim')
    set inccommand=split
endif

" Highlight yanks for quarter of a second
let g:highlightedyank_highlight_duration = 250

" Enable persistent undo history
let s:undodir=glob("~/.vim/undodir")
if !isdirectory(s:undodir)
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

" Move through display lines (with wrap on)
" instead of full lines
noremap j gj
noremap k gk
noremap <Down> gj
noremap <Up> gk
noremap $ g<End>
noremap ^ g<Home>

" Window splitting
nnoremap <Space>- :split<CR>
nnoremap <Space>= :vsplit<CR>

" Window navigation
nnoremap <C-Up> <C-w>k
nnoremap <C-Down> <C-w>j
nnoremap <C-Left> <C-w>h
nnoremap <C-Right> <C-w>l

nnoremap <Space><Up> <C-w>k
nnoremap <Space><Down> <C-w>j
nnoremap <Space><Left> <C-w>h
nnoremap <Space><Right> <C-w>l

" Skip over words 
"nnoremap <C-Left> gE
"nnoremap <C-Right> W
" Just to make navigation consistent
"nmap <C-Up> <Up>
"nmap <C-Down> <Down>

" Tab navigation
nnoremap <silent> th :tabfirst<CR>
nnoremap <silent> tk :tabnext<CR>
nnoremap <silent> tj :tabprev<CR>
nnoremap <silent> tl :tablast<CR>
nnoremap <silent> tt :tabedit<Space>
nnoremap <silent> tn :tabnew<CR>
nnoremap <silent> <C-t> :tabnew<CR>
nnoremap <silent> td :windo :q<CR>

" Close window
nnoremap <Space>d :q<CR>

" Save
"inoremap <C-s> <C-o>:w<CR>
inoremap <C-s> <ESC>:w<CR>
nnoremap <C-s> :w<CR>

" NERDTree
function! OpenNERDTree()
  " Close NERDTree if focused
  if (exists("b:NERDTree") && b:NERDTree.isTabTree())
    q
  " Otherwise open/focus it
  else
    NERDTreeFocus
  endif
endfunction
noremap <silent> <C-\> :NERDTreeFind<CR>
noremap <silent> \ :call OpenNERDTree()<CR>
noremap <silent> à :call OpenNERDTree()<CR>

" Open NERDtree when run with no arguments
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | call DisplayIntro() | NERDTree | endif

" Exit VIM when NERDTree is the last open window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Show hidden files but ignore VIM swap files
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\..*\.sw[pom]$']

" Prevent vim-illuminate from triggering on NERDTree
let g:Illuminate_ftblacklist=['nerdtree']

" Prevent vim-matchup from replacing the status line
let g:matchup_matchparen_offscreen={'method': ''}

" WinResizer
let g:winresizer_enable=1
let g:winresizer_horiz_resize=1
let g:winresizer_vert_resize=1
let g:winresizer_start_key='<C-q>'
" Buggy; https://github.com/simeji/winresizer/issues/18
"nnoremap <C-e> :WinResizerStartFocus<CR>
let g:winresizer_keycode_left="\<Left>"
let g:winresizer_keycode_up="\<Up>"
let g:winresizer_keycode_right="\<Right>"
let g:winresizer_keycode_down="\<Down>"

" Case-insensitive search 
" unless there's a capital character
set ignorecase
set smartcase

" Incsearch
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" Interactive replace
noremap ;; :%s:::cg<Left><Left><Left><Left>

" Appearance
"set termguicolors " breaks on urxvt
let g:gruvbox_italic=1
silent! colorscheme gruvbox
set background=dark

" Fix CursorLine highlight problem with nvim
" https://github.com/neovim/neovim/issues/9019#issuecomment-521532103
if has('nvim')
  function! s:CustomizeColors()
    if has('guirunning') || has('termguicolors')
      let cursorline_gui=''
      let cursorline_cterm='ctermfg=white'
    else
      let cursorline_gui='guifg=white'
      let cursorline_cterm=''
    endif
    exec 'hi CursorLine ' . cursorline_gui . ' ' . cursorline_cterm 
  endfunction

  augroup OnColorScheme
    autocmd!
    autocmd ColorScheme,BufEnter,BufWinEnter * call s:CustomizeColors()
  augroup END
end