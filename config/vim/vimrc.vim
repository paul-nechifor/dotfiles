" Disable vi compatibility.
set nocompatible

" Pathogen.
filetype off
call pathogen#infect()
call pathogen#helptags()
filetype plugin indent on

" Toggle paste insert mode.
set pastetoggle=<F2>

" Toggle spell checking.
map <F3> :setlocal spell! spelllang=en_gb<CR>
set spellfile=~/.vim-spellfile.utf8.add

nnoremap <silent> <F5> :!~/.pn-dotfiles/bin/run-build %:p<CR><CR>
nnoremap <silent> <F9> :!~/.pn-dotfiles/bin/run-build %:p edit<CR><CR>

" EasyMotion settings.
let g:EasyMotion_startofline = 0 " Keep cursor column on JK motions.
map s <Plug>(easymotion-bd-w)

" Don't use the manual.
noremap K k

" Make Y behave like other capitals.
map Y y$

" Improve up/down movement on wrapped lines.
nnoremap j gj
nnoremap k gk

" Shortcut so I don’t have to type ‘Ack’.
cabbrev ack <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "Ack" : "ack"<CR>

" Auto reload .vimrc on write.
au! bufwritepost .vimrc source %

" Enable mouse usage in all modes.
set mouse=a

" Make Backspace and Delete work as expected.
set bs=2

let mapleader = "\<Space>"
let g:move_key_modifier = 'C'
let g:move_auto_indent = 0
xmap <C-j> <Plug>(textmanip-move-down)
xmap <C-k> <Plug>(textmanip-move-up)

" Disable some PyMode things.
let g:pymode_doc = 0
let g:pymode_folding = 0
let g:pymode_options = 0
let g:pymode_rope_completion = 0
let g:pymode_run = 0
let g:pymode_trim_whitespaces = 0
let g:pymode_rope_goto_definition_cmd = 'e'

let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers=['flake8']

" Quicksave command
noremap <C-Q> :update<CR>
vnoremap <C-Q> <C-C>:update<CR>
inoremap <C-Q> <C-O>:update<CR>

" Auto equally resize windows when Vim's total size changes.
au VimResized * wincmd =

" Change swap dir ('//' for absolute paths).
set directory=~/.vimswap//

" 80 char limit.
set textwidth=80

" Keep search pattern at the center of the screen.
nnoremap <silent> n nzz
nnoremap <silent> N Nzz

" I can type :help on my own, thanks.
inoremap <F1> <nop>
nnoremap <F1> <nop>
vnoremap <F1> <nop>

" Confirm to save file instead of failing a command.
set confirm
set undolevels=666
" Doesn't automatically break the line. Use gq to rewrap.
set formatoptions-=t
" Anybody who uses anything else should be shot I'm afraid to say.
set encoding=utf-8

" Highlight search results.
set hlsearch
" Don't wait for me to hit enter to search.
set incsearch
" Ignore case only if all characters are lowercase.
set ignorecase
set smartcase

" Indentation options:
set smartindent
set expandtab " Replace <tab> with spaces.
set smarttab " Backspace spaces as if they were tabs.
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Text options:
set scrolloff=3 " Keep 3 lines at the top or bottom of the screen
"set number " Line numbers.
set ruler " Show line and column in the status bar.

" Always show tab line.
set showtabline=2

" Status line:
set statusline=%f " relative file path
set statusline+=%= " left-right separator
set statusline+=\ %l:%c " cursor line:column

" Use 1 space when joining sentences.
set nojoinspaces

" Exit visual mode without a timeout.
set timeoutlen=1000 ttimeoutlen=0

" Use 256 colors and override Vim's autodetection.
set t_Co=256

" Open help in a new tab (better than using cabbrev).
augroup HelpInTabs
    autocmd!
    autocmd BufEnter  *.txt   call HelpInNewTab()
augroup END
function! HelpInNewTab ()
    if &buftype == 'help'
        "Convert the help window to a tab...
        execute "normal \<C-W>T"
    endif
endfunction

" Reselect visual block after indent/outdent.
vnoremap < <gv
vnoremap > >gv

" Use C+J & C+K to scroll command history.
cnoremap <C-J> <t_kd>
cnoremap <C-K> <t_ku>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" Use `filler` to keep lines in sync. Set the `context` to a large number so
" no folds are shown and hide the `foldcolumn`.
set diffopt=filler,vertical,context:1000000,foldcolumn:0

" Map Q to repeat last recorded command.
map Q @@

" Tell vim to remember certain things on exit.
"
" * `'10`: marks will be remembered for up to 10 previously edited files
" * `"100`: will save up to 100 lines for each register
" * `:50`: up to 50 lines of command-line history will be remembered
" * `%`: saves and restores the buffer list
" * `n...`: where to save the viminfo files
set viminfo='10,\"100,:50,%,n~/.viminfo

" Make undo work after restarting Vim.
if exists('+undofile')
  set undodir=~/.vimundo//
  set undofile
endif

" Navigation windows
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Go to tab by number.
noremap H <ESC>:tabprevious<CR>
noremap L <ESC>:tabnext<CR>

" Nerd tree. Toggle it with Ctrl+N.
map <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore=['\.o$', '\~$', '.pyc$']

" What to ignore in CtrlP.
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|build\|migrations\|environ\|pyc\|svn\|logs'

" Execute current file.
map <Leader>e :call ExecuteFile(expand("%"))<cr>

map <Leader>h :nohl<CR>
map <Leader>w :wqa<CR>
nnoremap <Leader>o :CtrlP<CR>

au Syntax c,java,cpp,cs set autoindent cindent

au FileType python,javascript,c,bash set ts=4 sw=4 sts=4
au FileType python setlocal textwidth=79
au FileType diff setlocal textwidth=81
au FileType css,html,stylus,sass set iskeyword=a-z,A-Z,_,- ts=2 sw=2 sts=2

au BufRead,BufNewFile Vagrantfile set filetype=ruby

" Restore cursor on reopening.
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  au!
  au BufWinEnter * call ResCur()
augroup END

" Highlight trailing spaces in magenta.
hi ExtraWhitespace ctermbg=197 ctermfg=16
match ExtraWhitespace /\s\+$/
au BufWinEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhitespace /\s\+$/
au BufWinLeave * call clearmatches()
autocmd ColorScheme * hi ExtraWhitespace ctermbg=197 ctermfg=16

" Colors.
syntax on
colorscheme default
set background=light

" Git Gutter highlights.
hi GitGutterAdd ctermbg=235 ctermfg=Green
hi GitGutterChange ctermbg=235 ctermfg=Yellow
hi GitGutterDelete ctermbg=235 ctermfg=Red
hi GitGutterChangeDelete ctermbg=235 ctermfg=Yellow
hi SignColumn ctermbg=235 ctermfg=White

" Splitting colors.
hi VertSplit ctermbg=240 ctermfg=Black
hi StatusLine ctermbg=Black ctermfg=242
hi StatusLineNC ctermbg=231 ctermfg=235

" Diff colors.
hi DiffAdd ctermbg=236
hi DiffChange ctermbg=236
hi DiffDelete ctermbg=None ctermfg=Black
hi DiffText ctermbg=16

" Tab colours.
hi TabLineFill ctermfg=Black
hi TabLine ctermbg=Black ctermfg=White cterm=None
hi TabLineSel ctermbg=Black ctermfg=Green

hi Visual ctermbg=236
hi Search ctermbg=226 ctermfg=16
hi Pmenu ctermbg=234 ctermfg=White
hi PmenuSel ctermbg=238 ctermfg=White
hi Folded ctermbg=240 ctermfg=White

" Other colors.
hi Comment ctermfg=242
hi ErrorMsg ctermbg=197 ctermfg=16
hi LineNr ctermbg=233 ctermfg=240
hi NonText ctermfg=0

" Spell checking.
hi SpellBad ctermbg=164 ctermfg=16
hi SpellCap ctermbg=164 ctermfg=16
hi SpellLocal ctermbg=164 ctermfg=16
hi SpellRare ctermbg=164 ctermfg=16

" Use the full pipe for the split character instead of the ASCII one.
set fillchars=vert:\│

" Show lines over 80 chars as errors.
au BufWinEnter * let w:m1=matchadd('ErrorMsg', '\%81v.', -1)

" Show end of line trailing whitespace as errors.
au BufWinEnter * let w:m1=matchadd('ErrorMsg', '\($\n\s*\)\+\%$\n', -1)

" Toggle show numbers.
nmap <C-M> :set invnumber<CR>

" Toggle GitGutter.
nmap <C-G> :GitGutterToggle<CR>
" Turn off GitGutter by default.
let g:gitgutter_enabled = 0

" Execute file if know how. Note that the file is saved before executing.
function! ExecuteFile(filename)
  :w
  :silent !clear
  if match(a:filename, '\.coffee$') != -1
    exec ":!coffee " . a:filename
  elseif match(a:filename, '\.js$') != -1
    exec ":!node " . a:filename
  elseif match(a:filename, '\.py$') != -1
    exec ":!python " . a:filename
  elseif match(a:filename, '\.sh$') != -1
    exec ":!bash " . a:filename
  elseif match(a:filename, '\.go$') != -1
    exec ":!go run " . a:filename
  else
    exec ":!echo \"Don't know how to execute: \"" . a:filename
  end
endf
