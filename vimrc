" 80 char limit.
set textwidth=80

" Show lines over 80 chars as errors.
highlight OverLength ctermbg=red ctermfg=red guibg=#592929 
match OverLength /\%81v.*/

" Keep search pattern at the center of the screen.
nnoremap <silent> n nzz
nnoremap <silent> N Nzz

" I can type :help on my own, thanks.
inoremap <F1> <nop>
nnoremap <F1> <nop>
vnoremap <F1> <nop>

" Disable vi compatibility.
set nocompatible
" Confirm to save file instead of failing a command.
set confirm
set undolevels=666
" Doesn't automaticaly break the line. Use gq to rewrap.
set formatoptions-=t
" Anybody who uses anything else should be shot I'm afraid to say.
set encoding=utf-8
set gfn=Monospace\ 8

" Search options:
set hlsearch " Highlight results.
set incsearch " Don't wait for me to hit enter to search.

" Indentation options:
set smartindent
set expandtab " Replace <tab> with spaces.
set smarttab " Backspace spaces as if they were tabs.
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Text options:
set scrolloff=3 " Keep 3 lines at the top or bottom of the screen
set number " Line numbers.
set ruler " Show line and column in the status bar.

" Show relative file path in the statusline
set statusline+=%f
set laststatus=2

" Colors.
syntax on
colorscheme default


" Tell vim to remember certain things when we exit
"  '10  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='10,\"100,:20,%,n~/.viminfo

" Mappings -------------------------------------------------------------------------------------------------------------

" F2 - toggle show special characters"
imap <F2> <ESC>:set list!<CR>a
map <F2> :set list!<CR>
" F3 - toggle complete matching characters
imap <F3> <ESC>:call ToggleCompleteMatching()<CR>a
map <F3> :call ToggleCompleteMatching()<CR>
" F4 - toggle C-like mode
imap <F4> <ESC>:call CLikeMode()<CR>a
map <F4> :call CLikeMode()<CR>

" Navigation windows
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Toggle previous file with `,,`.
nnoremap ,, <c-^>

" Autos ----------------------------------------------------------------------------------------------------------------

autocmd Syntax c,java,cpp,cs call CLikeMode()
"autocmd Syntax c,java,cpp setlocal foldmethod=syntax

" Restore cursor on reopening.
function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

" Functions ------------------------------------------------------------------------------------------------------------
function CLikeMode()
    if !exists("b:clikeState") || b:clikeState == "off"
        let b:clikeState = "on"
        set autoindent
        set cindent
        if !exists("b:matchState") || b:matchState == "off"
            call ToggleCompleteMatching()
        endif
    else
        let b:clikeState = "off"
        set noautoindent
        set nocindent
        if exists("b:matchState") && b:matchState == "on"
            call ToggleCompleteMatching()
        endif
    endif
endf

function ToggleCompleteMatching()
    if !exists("b:matchState") || b:matchState == "off"
        let b:matchState = "on"
        inoremap ( ()<Esc>i
        inoremap [ []<Esc>i
        inoremap { {<CR>}<Esc>O
        "autocmd Syntax html,vim inoremap < <lt>><Esc>i| inoremap > <c-r>=ClosePair('>')<CR>
        inoremap ) <c-r>=ClosePair(')')<CR>
        inoremap ] <c-r>=ClosePair(']')<CR>
        "inoremap } <c-r>=CloseBracket()<CR>
        inoremap " <c-r>=QuoteDelim('"')<CR>
    else
        let b:matchState = "off"
        iunmap (
        iunmap [
        iunmap {
        iunmap )
        iunmap ]
        iunmap "
    endif
endf

function ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endf

function CloseBracket()
    if match(getline(line('.') + 1), '\s*}') < 0
        return "\<CR>}"
    else
        return "\<Esc>j0f}o"
    endif
endf

function QuoteDelim(char)
     let line = getline('.')
     let col = col('.')
     if line[col - 2] == "\\"
         "Inserting a quoted quotation mark into the string
         return a:char
     elseif line[col - 1] == a:char
         "Escaping out of the string
         return "\<Right>"
     else
         "Starting a string
         return a:char.a:char."\<Esc>i"
     endif
endf
