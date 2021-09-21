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
let &t_ut = ''

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

" Plugins: {{{
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'shinchu/lightline-gruvbox.vim'
" https://web.archive.org/web/20200112215437/https://jeffkreeftmeijer.com/vim-number/
" Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'simeji/winresizer'
Plug 'editorconfig/editorconfig-vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'preservim/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
" Plug 'haya14busa/incsearch.vim'
Plug 'machakann/vim-highlightedyank'
Plug 'andymass/vim-matchup'
Plug 'luochen1990/rainbow'
Plug 'RRethy/vim-illuminate'
" Plug 'Yggdroot/indentLine'
Plug 'wesQ3/vim-windowswap'
Plug 'LnL7/vim-nix'
Plug 'xolox/vim-misc'
Plug 'tikhomirov/vim-glsl'
Plug 'baopham/vim-nerdtree-unfocus'
Plug 'tomtom/tcomment_vim'
Plug 'lambdalisue/suda.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'inkarkat/vim-ReplaceWithRegister'
Plug 'vim-scripts/argtextobj.vim'
Plug 'PeterRincker/vim-argumentative'
Plug 'gcmt/taboo.vim'
Plug 'mhinz/vim-startify'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'puremourning/vimspector'
" C# plugins
Plug 'OmniSharp/omnisharp-vim'
Plug 'dense-analysis/ale'
Plug 'nickspoons/vim-sharpenup'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'tsufeki/asyncomplete-fuzzy-match', {
  \ 'do': 'cargo build --release',
  \ }
Plug 'prabirshrestha/async.vim' " required for asyncomplete-fuzzy-match
Plug 'prabirshrestha/asyncomplete-ultisnips.vim'
Plug 'andreypopp/asyncomplete-ale.vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
" Plug 'ervandew/supertab'
" This must be loaded last
Plug 'ryanoasis/vim-devicons'
call plug#end()
" }}}

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

" Enable confirmation prompts when closing an unsaved buffer/file
set confirm

" Enable line wrapping
set wrap linebreak nolist
set breakat=" 	!@*-+;:,./?"

" Show line numbers
set number norelativenumber

" Cursor position (displayed in the bar)
set ruler

" Make undesirable characters more apparent
set list listchars=tab:→\ ,nbsp:␣,trail:·,extends:▶,precedes:◀

" Enable mouse interaction
set mouse=a

" Enable wildmenu
set wildmenu
" set wildmode=full
set wildmode=list:full,full

" Highlight position
set cursorline
"set cursorcolumn

" Search highlighting
set hlsearch
set incsearch

" Indentline
" XXX: unfortunately Indentline causes too many issues to be worth it
" let g:indentLine_concealcursor = &concealcursor
" " let g:indentLine_setConceal = 0
" let g:indentLine_faster = 1
" " let g:indentLine_noConcealCursor = 1
" let g:indentLine_char = "┊"
" let g:indentLine_fileTypeExclude = [ 'startify', 'help', 'text' ]
" autocmd Filetype json :IndentLinesDisable

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

" Stay in visual mode when indenting
vnoremap < <gv
vnoremap > >gv

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
nnoremap <silent> <S-Up> <C-w>k
nnoremap <silent> <S-Down> <C-w>j
nnoremap <silent> <S-Left> <C-w>h
nnoremap <silent> <S-Right> <C-w>l

nnoremap <silent> <Space><Up> <C-w>k
nnoremap <silent> <Space><Down> <C-w>j
nnoremap <silent> <Space><Left> <C-w>h
nnoremap <silent> <Space><Right> <C-w>l

" Buffer Navigation: {{{
nnoremap <silent> <M-Up> :bnext<CR>
nnoremap <silent> <M-Down> :bprev<CR>
" Unmap alt-up/down to prevent accidents in insert mode
inoremap <silent> <M-Up> <nop>
inoremap <silent> <M-Down> <nop>
" }}}

" Skip over words
"nnoremap <C-Left> gE
"nnoremap <C-Right> W
" Just to make navigation consistent
"nmap <C-Up> <Up>
"nmap <C-Down> <Down>

" Tab navigation

" Modified version of CBGotoDefinition from
" autoload/OmniSharp/actions/definition.vim
fun! s:cs_new_tab_cb(location, fromMetadata) abort
  if type(a:location) != type({})
    execute 'tabedit'
    let found = 0
  else
    let found = OmniSharp#locations#Navigate(a:location, 'tabedit')
    if found && a:fromMetadata
      setlocal nomodifiable readonly
    endif
  endif
  return found
endfun

fun! s:cs_new_tab()
  call OmniSharp#actions#definition#Find(function('<SID>cs_new_tab_cb'))
endfun

augroup newtab_cs
  autocmd!
  autocmd FileType cs nmap <silent> <buffer> <C-t> :call <SID>cs_new_tab()<CR>
augroup END

nnoremap <silent> th :tabfirst<CR>
nnoremap <silent> tl :tablast<CR>
nnoremap tt :tabedit<Space>
nnoremap tr :TabooRename<Space>
nnoremap <silent> tn :tabnew<CR>
nnoremap <silent> <C-t> :tabnew<CR>
nnoremap <silent> ts :tab split<CR>
nnoremap <silent> <M-C-Right> :tabnext<CR>
nnoremap <silent> <M-C-Left> :tabprev<CR>
nnoremap <silent> <M-S-Right> :tabnext<CR>
nnoremap <silent> <M-S-Left> :tabprev<CR>
nnoremap <silent> <M-Right> :tabnext<CR>
nnoremap <silent> <M-Left> :tabprev<CR>
nnoremap <silent> td :windo :q<CR>

" Reorder tabs
nnoremap <silent> <F24> :silent! tabmove +1<CR>
nnoremap <silent> <F23> :silent! tabmove -1<CR>

" Close window
nnoremap <silent> <Space>q :confirm q<CR>
nnoremap <silent> <Space>Q :confirm qa<CR>
nnoremap <silent> <Space>bd :bdelete<CR>
" nnoremap <silent> <Space>d :q<CR>
" nnoremap <silent> <Space>D :q!<CR>
" nnoremap <silent> <Space>q :qa<CR>
" nnoremap <silent> <Space>Q :qa!<CR>

" Unmap ex mode
nnoremap Q <Nop>

" Open session
nnoremap <Space>s :SLoad<Space>

" Save
nnoremap <silent> <Space>w :w<CR>

" Save (sudo)
nnoremap <silent> <Space>W :SudaWrite<CR>

" Split line (symmetrical to J)
nnoremap K a<CR><Esc>

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
nnoremap <silent> <Space>gc :G commit<CR>
nnoremap <silent> <Space>gb :G blame<CR>
nnoremap <silent> <Space>gd :Gdiffsplit<CR>
nnoremap <silent> <Space>gl :tabnew <bar> Gclog <bar> TabooRename git log<CR>

" Toggle paste mode
noremap <silent> <F2> :set paste!<CR>

" Toggle line wrapping
noremap <silent> <F1> :set wrap!<CR>

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

" Enable rainbow parentheses
let g:rainbow_active = 1

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

" Enable fold markers, e.g: Name: {{{\nContent here\n}}}
set foldmethod=syntax
set foldignore=
" Start with everything unfolded
set foldlevelstart=99

augroup vimrc_folds
  autocmd!
  autocmd FileType * setlocal foldmethod=syntax
  autocmd FileType vim setlocal foldmethod=marker
augroup END

" Insert-mode auto-complete menu
set completeopt=menuone,noinsert,noselect
"set completepopup=highlight:Pmenu,border:off " not supported by nvim yet

" Incsearch
" let g:incsearch#auto_nohlsearch = 1
" map / <Plug>(incsearch-forward)
" map ? <Plug>(incsearch-backward)
" map g/ <Plug>(incsearch-stay)
" map n  <Plug>(incsearch-nohl-n)
" map N  <Plug>(incsearch-nohl-N)
" map *  <Plug>(incsearch-nohl-*)
" map #  <Plug>(incsearch-nohl-#)
" map g* <Plug>(incsearch-nohl-g*)
" map g# <Plug>(incsearch-nohl-g#)

" Interactive replace
nnoremap ;; :%s:::cg<Left><Left><Left><Left>
vnoremap ;; :s:::cg<Left><Left><Left><Left>
noremap ;: :s:::cg<Left><Left><Left><Left>

" Windowswap: {{{
let g:windowswap_map_keys = 0
nnoremap <silent> <Space>ww :call WindowSwap#EasyWindowSwap()<CR>
" }}}

" Appearance: {{{
if !exists('g:load_colorscheme') || g:load_colorscheme
  let g:load_colorscheme = 0
  let g:gruvbox_italic = 1
  set termguicolors " Enable True Color (24-bit)
  set background=dark
  silent! colorscheme gruvbox
end

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

augroup ColorschemePreferences
  autocmd!
  " These preferences clear some gruvbox background colours, allowing transparency
  autocmd ColorScheme * highlight Normal     ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight SignColumn ctermbg=NONE guibg=NONE
  autocmd ColorScheme * highlight Todo       ctermbg=NONE guibg=NONE
  " Link ALE sign highlights to similar equivalents without background colours
  autocmd ColorScheme * highlight link ALEErrorSign   WarningMsg
  autocmd ColorScheme * highlight link ALEWarningSign ModeMsg
  autocmd ColorScheme * highlight link ALEInfoSign    Identifier
augroup END
" }}}

" Argumentative: {{{
let g:argumentative_no_mappings = 1
nmap ,b <Plug>Argumentative_Prev
nmap ,w <Plug>Argumentative_Next
xmap ,b <Plug>Argumentative_XPrev
xmap ,w <Plug>Argumentative_XNext
nmap ,< <Plug>Argumentative_MoveLeft
nmap ,> <Plug>Argumentative_MoveRight
" xmap i, <Plug>Argumentative_InnerTextObject
" xmap a, <Plug>Argumentative_OuterTextObject
" omap i, <Plug>Argumentative_OpPendingInnerTextObject
" omap a, <Plug>Argumentative_OpPendingOuterTextObject
" }}}

" FZF: {{{
nnoremap <silent> <C-f> :FZF<CR>
let $FZF_DEFAULT_COMMAND = 'ag -l --hidden --ignore .git'
" }}}

" ALE: {{{
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'
let g:ale_sign_info = '·'
let g:ale_sign_style_error = '·'
let g:ale_sign_style_warning = '·'

let g:ale_linters = { 'cs': ['OmniSharp'] }

" Integrate with asyncomplete
augroup asyncomplete_ale
  au!
  au User asyncomplete_setup call asyncomplete#ale#register_source({
    \ 'name': 'reason',
    \ 'linter': 'flow',
    \ })
augroup END
" }}}

" Vimspector: {{{
let g:vimspector_install_gadgets = [
  \ 'netcoredbg'
  \ ]

" Visual Studio mappings
nmap <F5> <Plug>VimspectorContinue
" S-F5 maps to S-F3 in the terminal
nmap <S-F3> <Plug>VimspectorStop
" C-S-F5 doesn't work in the terminal
" nmap <C-S-F5> <Plug>VimspectorRestart
nmap <F4> <Plug>VimspectorRestart
nmap <F6> <Plug>VimspectorPause
nmap <F9> <Plug>VimspectorToggleBreakpoint
nmap <S-F9> <Plug>VimspectorAddFunctionBreakpoint
nmap <F10> <Plug>VimspectorStepOver
nmap <F11> <Plug>VimspectorStepInto
nmap <S-F11> <Plug>VimspectorStepOut
nmap <C-x> <Plug>VimspectorToggleBreakpoint

" Other mappings
nmap <silent> <Space>dq :VimspectorReset<CR>
nmap <silent> <Space>de <Plug>VimspectorBalloonEval
vmap <silent> <Space>de <Plug>VimspectorBalloonEval

augroup vimspector_commands
  autocmd!
  autocmd FileType cs noremap <silent> <buffer> <Space>db :!dotnet build<CR>
" }}}

" OmniSharp: {{{
let g:OmniSharp_diagnostic_showid = 1
let g:OmniSharp_popup_position = 'peek'
" set previewheight=5
if has('nvim')
  let g:OmniSharp_popup_options = {
  \ 'wrap': v:true,
  \ 'winhl': 'Normal:NormalFloat'
  \}
else
  let g:OmniSharp_popup_options = {
  \ 'highlight': 'Normal',
  \ 'padding': [0, 0, 0, 0],
  \ 'border': [1]
  \}
endif

" Prevents type lookups from triggering the "Hit ENTER to continue" prompt
set shortmess=a

let g:OmniSharp_server_stdio = 1
let g:OmniSharp_typeLookupInPreview = 1
let g:OmniSharp_selector_ui = 'fzf'
let g:OmniSharp_selector_findusages = 'fzf'
let g:OmniSharp_fzf_options = { 'down': '6' }
let g:OmniSharp_want_snippet = 1
" }}}

" asyncomplete: {{{
" Disable 'pattern not found' messages
" https://github.com/prabirshrestha/asyncomplete.vim/issues/59
set shortmess+=c
imap <C-Space> <Plug>(asyncomplete_force_refresh)
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
" }}}

" Ultisnips: {{{
let g:UltiSnipsSnippetDirectories = [$HOME.'/.vim/ultisnips']
let g:UltiSnipsJumpForwardTrigger = "<c-w>"
let g:UltiSnipsJumpBackwardTrigger = "<c-b>"
" Integrate with asyncomplete
let g:UltiSnipsExpandTrigger = "<C-e>"
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit = "horizontal"
augroup asyncomplete_ultisnips
 au!
  au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
  \ 'name': 'ultisnips',
  \ 'allowlist': ['*'],
  \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
  \ }))
augroup END
" }}}

" Sharpenup: {{{
" All sharpenup mappings will begin with `<Space>os`, e.g. `<Space>osgd` for
" :OmniSharpGotoDefinition
let g:sharpenup_map_prefix = '<Space>os'
let g:sharpenup_codeactions = 0
let g:sharpenup_statusline_opts = {
\ 'Highlight': 0,
\ 'TextLoading': 'O#: %s  (%p of %P)',
\ 'TextReady': 'O#: %s',
\ 'TextDead': 'O#: Not running.',
\ }

augroup OmniSharpIntegrations
  autocmd!
  autocmd User OmniSharpProjectUpdated,OmniSharpReady call lightline#update()
augroup END

let g:sharpenup_create_mappings = 0

augroup omnisharp_commands
  autocmd!

  " Show type information automatically when the cursor stops moving.
  " Note that the type is echoed to the Vim command line, and will overwrite
  " any other messages in this space including e.g. ALE linting messages.
  " autocmd CursorHold *.cs OmniSharpTypeLookup

  autocmd FileType cs nmap <silent> <buffer> <C-a> <Plug>(omnisharp_type_lookup)

  " The following commands are contextual, based on the cursor position.
  autocmd FileType cs nmap <silent> <buffer> gd <Plug>(omnisharp_go_to_definition)
  autocmd FileType cs nmap <silent> <buffer> <Space>osgd <Plug>(omnisharp_go_to_definition)
  autocmd FileType cs nmap <silent> <buffer> <Space>osfu <Plug>(omnisharp_find_usages)
  autocmd FileType cs nmap <silent> <buffer> <Space>osu <Plug>(omnisharp_find_usages)
  autocmd FileType cs nmap <silent> <buffer> <Space>osfi <Plug>(omnisharp_find_implementations)
  autocmd FileType cs nmap <silent> <buffer> <Space>ospd <Plug>(omnisharp_preview_definition)
  autocmd FileType cs nmap <silent> <buffer> <Space>ospi <Plug>(omnisharp_preview_implementations)
  autocmd FileType cs nmap <silent> <buffer> <Space>ost <Plug>(omnisharp_type_lookup)
  autocmd FileType cs nmap <silent> <buffer> <Space>osd <Plug>(omnisharp_documentation)
  autocmd FileType cs nmap <silent> <buffer> <Space>osfs <Plug>(omnisharp_find_symbol)
  autocmd FileType cs nmap <silent> <buffer> <Space>osfx <Plug>(omnisharp_fix_usings)
  "autocmd FileType cs nmap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
  "autocmd FileType cs imap <silent> <buffer> <C-\> <Plug>(omnisharp_signature_help)
  autocmd FileType cs nmap <silent> <buffer> <Space>oss <Plug>(omnisharp_signature_help)
  " autocmd FileType cs imap <silent> <buffer> <Space>oss <Plug>(omnisharp_signature_help)

  " Navigate up and down by method/property/field
  autocmd FileType cs nmap <silent> <buffer> [[ <Plug>(omnisharp_navigate_up)
  autocmd FileType cs nmap <silent> <buffer> ]] <Plug>(omnisharp_navigate_down)
  " Find all code errors/warnings for the current solution and populate the quickfix window
  autocmd FileType cs nmap <silent> <buffer> <Space>osgcc <Plug>(omnisharp_global_code_check)
  " Contextual code actions (uses fzf, vim-clap, CtrlP or unite.vim selector when available)
  autocmd FileType cs nmap <silent> <buffer> <C-Space> <Plug>(omnisharp_code_actions)
  autocmd FileType cs nmap <silent> <buffer> <Space>osca <Plug>(omnisharp_code_actions)
  autocmd FileType cs xmap <silent> <buffer> <Space>osca <Plug>(omnisharp_code_actions)
  " Repeat the last code action performed (does not use a selector)
  autocmd FileType cs nmap <silent> <buffer> <Space>os. <Plug>(omnisharp_code_action_repeat)
  autocmd FileType cs xmap <silent> <buffer> <Space>os. <Plug>(omnisharp_code_action_repeat)

  autocmd FileType cs nmap <silent> <buffer> <Space>os= <Plug>(omnisharp_code_format)

  autocmd FileType cs nmap <silent> <buffer> <Space>osr <Plug>(omnisharp_rename)

  " autocmd FileType cs nmap <silent> <buffer> <Space>osre <Plug>(omnisharp_restart_server)
  " autocmd FileType cs nmap <silent> <buffer> <Space>osst <Plug>(omnisharp_start_server)
  " autocmd FileType cs nmap <silent> <buffer> <Space>ossp <Plug>(omnisharp_stop_server)
augroup END
" }}}

" wilder: {{{
call wilder#setup({
  \ 'modes': [':', '/', '?'],
  \ 'next_key': '<Tab>',
  \ 'previous_key': '<S-Tab>',
  \ 'accept_key': '<Down>',
  \ 'reject_key': '<Up>',
  \ })
" File finder
call wilder#set_option('pipeline', [
  \   wilder#branch(
  \     wilder#python_file_finder_pipeline({
  \       'file_command': ['ag', '-l', '--hidden', '--ignore', '.git'],
  \       'dir_command': ['find', '.', '-type', 'd', '-printf', '%P\n'],
  \       'filters': ['fuzzy_filter', 'difflib_sorter'],
  \     }),
  \     wilder#cmdline_pipeline(),
  \     wilder#python_search_pipeline(),
  \   ),
  \ ])

" Workaround for a neovim bug (#14304)
" https://github.com/gelguy/wilder.nvim/issues/41#issuecomment-860025867
function! SetShortmessF(on) abort
  if a:on
    set shortmess+=F
  else
    set shortmess-=F
  endif
  return ''
endfunction

nnoremap <expr> : SetShortmessF(1) . ':'

augroup WilderShortmessFix
  autocmd!
  autocmd CmdlineLeave * call SetShortmessF(0)
augroup END
" }}}

" Lightline: {{{
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
\     'inactive': ['tabnum', 'filename', 'fticon'],
\   },
\   'active': {
\     'right': [
\       ['lineinfo', 'percent'],
\       ['linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok', 'sharpenup'],
\       ['fileformat', 'fileencoding', 'filetype'],
\     ],
\   },
\   'inactive': {
\     'right': [],
\   },
\   'subseparator': { 'left': '|', 'right': '|' },
\   'component_expand': {
\     'sharpenup': 'sharpenup#statusline#Build',
\     'linter_checking': 'lightline#ale#checking',
\     'linter_infos': 'lightline#ale#infos',
\     'linter_warnings': 'lightline#ale#warnings',
\     'linter_errors': 'lightline#ale#errors',
\     'linter_ok': 'lightline#ale#ok',
\    },
\   'component_type': {
\     'sharpenup': 'tabsel',
\     'linter_warnings': 'warning',
\     'linter_errors': 'error',
\    }
\ }

" Use unicode chars for ale indicators in the statusline
let g:lightline#ale#indicator_checking = "\uf110 "
let g:lightline#ale#indicator_infos = "\uf129 "
let g:lightline#ale#indicator_warnings = "\uf071 "
let g:lightline#ale#indicator_errors = "\uf05e "
let g:lightline#ale#indicator_ok = "\uf00c "

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
" }}}
