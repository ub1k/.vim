" This is Gary Bernhardt's .vimrc file
"
" Be warned: this has grown slowly over years and may not be internally
" consistent.

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
filetype off  " required!

set rtp+=~/.vim/vundle.git/ 
call vundle#rc()
Bundle 'tpope/vim-fugitive'
Bundle 'lokaltog/vim-easymotion'
Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
" vim-scripts repos
Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'rails.vim'

filetype plugin indent on     " required!
" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers
set hidden

" Remember more commands and search history
set history=1000

" Make tab completion for files/buffers act like bash
set wildmenu

" Make searches case-sensitive only if they contain upper-case characters
set ignorecase
set smartcase

" Keep more context when scrolling off the end of a buffer
set scrolloff=3

" Store temporary files in a central spot
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  " set guifont=Monaco:h14
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype off
  call pathogen#infect()
  syntax on
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")


" GRB: sane editing configuration"
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
" set smartindent
set laststatus=2
set showmatch
set incsearch

" GRB: wrap lines at 78 characters
set textwidth=78

" GRB: highlighting search"
set hls

if has("gui_running")
  " GRB: set font"
  :set enc=utf-8 gfn=Consolas:h14

  " GRB: set window size"
  :set lines=100
  :set columns=300

  " GRB: highlight current line"
  ":set cursorline
endif

" GRB: set the color scheme
if has("gui_running")
    ":color molokai
    ":color moria
    :color vividchalk
else
    :color molokai
endif

" GRB: hide the toolbar in GUI mode
if has("gui_running")
    set go-=T
end

" GRB: add pydoc command
:command! -nargs=+ Pydoc :call ShowPydoc("<args>")
function! ShowPydoc(module, ...)
    let fPath = "/tmp/pyHelp_" . a:module . ".pydoc"
    :execute ":!pydoc " . a:module . " > " . fPath
    :execute ":sp ".fPath
endfunction

" GRB: Always source python.vim for Python files
au FileType python source ~/.vim/scripts/python.vim

" GRB: Use custom python.vim syntax file
au! Syntax python source ~/.vim/syntax/python.vim
let python_highlight_all = 1
let python_slow_sync = 1

" GRB: use emacs-style tab completion when selecting files, etc
set wildmode=longest,list

" GRB: Put useful info in status line
:set statusline=%<%f%=\ [%1*%M%*%n%R%H]\ %-19(%3l,%02c%03V%)%O'%02b'
:hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red

" GRB: clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<CR>/<BS>





" Remap the tab key to do autocompletion or indentation depending on the
" context (from http://www.vim.org/tips/tip.php?tip_id=102)
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
"inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

function! Smart_TabComplete()
    let line = getline('.')                         " curline
    let substr = strpart(line, -1, col('.')+1)      " from start to cursor
    let substr = matchstr(substr, "[^ \t]*$")       " word till cursor
    if (strlen(substr)==0)                          " nothing to match on empty string
        return "\<tab>"
    endif
    let has_period = match(substr, '\.') != -1      " position of period, if any
    let has_slash = match(substr, '\/') != -1       " position of slash, if any
    if (!has_period && !has_slash)
        return "\<C-X>\<C-P>"                         " existing text matching
    elseif ( has_slash )
        return "\<C-X>\<C-F>"                         " file matching
    else
        return "\<C-X>\<C-O>"                         " plugin matching
    endif
endfunction
                                                      
inoremap <tab> <c-r>=Smart_TabComplete()<CR>
" When hitting <;>, complete a snippet if there is one; else, insert an actual
" <;>
function! InsertSnippetWrapper()
    let inserted = TriggerSnippet()
    if inserted == "\<tab>"
        return "§"
    else
        return inserted
    endif
endfunction
inoremap § <c-r>=InsertSnippetWrapper()<cr>

if version >= 700
    autocmd FileType python set omnifunc=pythoncomplete#Complete
    let Tlist_Ctags_Cmd='~/bin/ctags'
endif

function! RunTests(target, args)
    silent ! echo
    exec 'silent ! echo -e "\033[1;36mRunning tests in ' . a:target . '\033[0m"'
    silent w
    exec "make " . a:target . " " . a:args
endfunction

function! ClassToFilename(class_name)
    let understored_class_name = substitute(a:class_name, '\(.\)\(\u\)', '\1_\U\2', 'g')
    let file_name = substitute(understored_class_name, '\(\u\)', '\L\1', 'g')
    return file_name
endfunction

function! ModuleTestPath()
    let file_path = @%
    let components = split(file_path, '/')
    let path_without_extension = substitute(file_path, '\.py$', '', '')
    let test_path = 'tests/unit/' . path_without_extension
    return test_path
endfunction

function! NameOfCurrentClass()
    let save_cursor = getpos(".")
    normal $<cr>
    call PythonDec('class', -1)
    let line = getline('.')
    call setpos('.', save_cursor)
    let match_result = matchlist(line, ' *class \+\(\w\+\)')
    let class_name = ClassToFilename(match_result[1])
    return class_name
endfunction

function! TestFileForCurrentClass()
    let class_name = NameOfCurrentClass()
    let test_file_name = ModuleTestPath() . '/test_' . class_name . '.py'
    return test_file_name
endfunction

function! TestModuleForCurrentFile()
    let test_path = ModuleTestPath()
    let test_module = substitute(test_path, '/', '.', 'g')
    return test_module
endfunction

function! RunTestsForFile(args)
    if @% =~ 'test_'
        call RunTests('%', a:args)
    else
        let test_file_name = TestModuleForCurrentFile()
        call RunTests(test_file_name, a:args)
    endif
endfunction

function! RunAllTests(args)
    silent ! echo
    silent ! echo -e "\033[1;36mRunning all unit tests\033[0m"
    silent w
    exec "make!" . a:args
endfunction

function! JumpToError()
    if getqflist() != []
        for error in getqflist()
            if error['valid']
                break
            endif
        endfor
        let error_message = substitute(error['text'], '^ *', '', 'g')
        silent cc!
        exec ":sbuffer " . error['bufnr']
        call RedBar()
        echo error_message
    else
        call GreenBar()
        echo "All tests passed"
    endif
endfunction

function! RedBar()
    hi RedBar ctermfg=white ctermbg=red guibg=red
    echohl RedBar
    echon repeat(" ",&columns - 1)
    echohl
endfunction

function! GreenBar()
    hi GreenBar ctermfg=white ctermbg=green guibg=green
    echohl GreenBar
    echon repeat(" ",&columns - 1)
    echohl
endfunction

function! JumpToTestsForClass()
    exec 'e ' . TestFileForCurrentClass()
endfunction

let mapleader=","
" nnoremap <leader>m :call RunTestsForFile('--machine-out')<cr>:redraw<cr>:call JumpToError()<cr>
" nnoremap <leader>M :call RunTestsForFile('')<cr>
" nnoremap <leader>a :call RunAllTests('--machine-out')<cr>:redraw<cr>:call JumpToError()<cr>
" nnoremap <leader>A :call RunAllTests('')<cr>

" nnoremap <leader>a :call RunAllTests('')<cr>:redraw<cr>:call JumpToError()<cr>
" nnoremap <leader>A :call RunAllTests('')<cr>

"nnoremap <leader>t :call RunAllTests('')<cr>:redraw<cr>:call JumpToError()<cr>
"nnoremap <leader>T :call RunAllTests('')<cr>

" nnoremap <leader>t :call JumpToTestsForClass()<cr>
nnoremap <leader><leader> <c-^>

" highlight current line
"set cursorline
"hi CursorLine cterm=NONE ctermbg=black

set cmdheight=2

" Don't show scroll bars in the GUI
set guioptions-=L
set guioptions-=r

" Use <c-h> for snippets
let g:NERDSnippets_key = '<c-h>'

augroup myfiletypes
  "clear old autocmds in group
  autocmd!
  "for ruby, autoindent with two spaces, always expand tabs
  autocmd FileType ruby,haml,eruby,yaml,html,javascript,sass set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et
augroup END

set switchbuf=useopen

autocmd BufRead,BufNewFile *.html source ~/.vim/indent/html_grb.vim
autocmd FileType htmldjango source ~/.vim/indent/html_grb.vim
autocmd! BufRead,BufNewFile *.sass setfiletype sass 

" Map ,e and ,v to open files in the same directory as the current file
map <leader>e :edit <C-R>=expand("%:h")<cr>/
map <leader>v :view <C-R>=expand("%:h")<cr>/

"if has("python")
    "source ~/.vim/ropevim/rope.vim
"endif

autocmd BufRead,BufNewFile *.feature set sw=4 sts=4 et

set number
set numberwidth=5

if has("gui_running")
    " source ~/proj/vim-complexity/repo/complexity.vim
endif

" Seriously, guys. It's not like :W is bound to anything anyway.
command! W :w

map <leader>rm :BikeExtract<cr>

function! ExtractVariable()
    let name = input("Variable name: ")
    if name == ''
        return
    endif
    " Enter visual mode (not sure why this is needed since we're already in
    " visual mode anyway)
    normal! gv

    " Replace selected text with the variable name
    exec "normal c" . name
    " Define the variable on the line above
    exec "normal! O" . name . " = "
    " Paste the original selected text to be the variable value
    normal! $p
endfunction

function! InlineVariable()
    " Copy the variable under the cursor into the 'a' register
    " XXX: How do I copy into a variable so I don't pollute the registers?
    :normal "ayiw
    " It takes 4 diws to get the variable, equal sign, and surrounding
    " whitespace. I'm not sure why. diw is different from dw in this respect.
    :normal 4diw
    " Delete the expression into the 'b' register
    :normal "bd$
    " Delete the remnants of the line
    :normal dd
    " Go to the end of the previous line so we can start our search for the
    " usage of the variable to replace. Doing '0' instead of 'k$' doesn't
    " work; I'm not sure why.
    normal k$
    " Find the next occurence of the variable
    exec '/\<' . @a . '\>'
    " Replace that occurence with the text we yanked
    exec ':.s/\<' . @a . '\>/' . @b
endfunction

vnoremap <leader>rv :call ExtractVariable()<cr>
nnoremap <leader>ri :call InlineVariable()<cr>
" Find comment
map <leader>/# /^ *#<cr>
" Find function
map <leader>/f /^ *def\><cr>
" Find class
map <leader>/c /^ *class\><cr>
" Find if
map <leader>/i /^ *if\><cr>
" Delete function
" \%$ means 'end of file' in vim-regex-speak
map <leader>df d/\(^ *def\>\)\\|\%$<cr>
com! FindLastImport :execute'normal G<CR>' | :execute':normal ?^\(from\|import\)\><CR>'
map <leader>/m :FindLastImport<cr>

map <leader>ws :%s/ *$//g<cr><c-o><cr>

" Always show tab bar
set showtabline=2

map <leader>\t :CommandT<cr>

augroup mkd
    autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
    autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;
augroup END

"set makeprg=python\ -m\ nose.core\ --machine-out
autocmd FileType javascript set makeprg=cat\ %\ \\\|\ /usr/local/bin/js\ /Users/emir/.vim/js/mylintrun.js\ %
autocmd FileType javascript set errorformat=%f:%l:%c:%m

map <silent> <leader>y :<C-u>silent '<,'>w !pbcopy<CR>

" Make <leader>' switch between ' and "
nnoremap <leader>' ""yls<c-r>={'"': "'", "'": '"'}[@"]<cr><esc>

filetype plugin on
set ofu=syntaxcomplete#Complete
"It will insert the longest common prefix of all the suggestions, then you can
"type and delete to narrow down or expand results.
set completeopt+=longest
"nerd tree plugin"
map <F3> :%s/^\s*\(NSLog.*\)/\/\/\1/g<CR>
  
function DeProtofy()
  "Get current line...
  let curr_line = getline('.')
  let replacement = substitute(curr_line,'ClassName','Class','g')
  let replacement = substitute(replacement,'readAttribute','attr','g')
  let replacement = substitute(replacement,'writeAttribute','attr','g')
  let replacement = substitute(replacement,'setStyle','css','g')
  let replacement = substitute(replacement,'getStyle','css','g')
  let replacement = substitute(replacement,'select','find','g')
  let replacement = substitute(replacement,'$(','(jQuery ','g')
  let replacement = substitute(replacement,'innerHTML =','html','g')
  call setline('.', replacement)
endfunction
function DeAmperfy()
  "Get current line...
  let curr_line = getline('.')
  "Replace raw ampersands...
  let replacement = substitute(curr_line,'=','&amp;','g')

  "Update current line...
  call setline('.', replacement)
endfunction

map <F7> :call DeProtofy()<CR>
"so obj_matchbracket.vim
"so  /Users/emir/.vim/ftplugin/obj_matchbracket.vim
"info file"
"folding
"nmap <F6> /}<CR>zf%<ESC>:nohlsearch<CR>
"set foldmethod=syntax
set foldmethod=indent
"au BufWinLeave * mkview
"au BufWinEnter * silent loadview
au BufNewFile,BufRead *.cpp,*.c,*.h,*.java,*.m syn region myCComment start="/\*" end="\*/" fold keepend transparent
"vmap <silent> w <Plug>CamelCaseMotion_w
"vmap <silent> b <Plug>CamelCaseMotion_b
"vmap <silent> e <Plug>CamelCaseMotion_e

map <leader>b :FuzzyFinderBuffer<cr>
map <leader>f :FuzzyFinderFile<cr>
map <leader>d :FuzzyFinderDir<cr>

nmap <F6> df*i[t;a]ha release^@<CR>
"let g:SuperTabDefaultCompletionType = "context"
if has("gui_macvim")
    macmenu &File.New\ Tab key=<nop>
    map <D-t> :CommandT<CR>
    :cd ..
    ":args */*.*
" idea    map <C-1> /[BBReportHelper accessoryNoneAllRowsInTable:tableView inSection:0];
"    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;<CR>
endif



""handle split"
"map <C-J> <C-W>j<C-W>_
"map <C-K> <C-W>k<C-W>_
"map <C-H> <C-W>h<C-W>_
"map <C-L> <C-W>l<C-W>_
"set wmh=0



"-------------------------------------------------------------------------------
"-- AUTOCOMMANDS   joeldotfiles
"-------------------------------------------------------------------------------

" enable some important things

" uncomment if you want to mark the current cursorline,
" column with a different color
"autocmd WinEnter * setlocal cursorcolumn
"autocmd BufEnter * setlocal cursorcolumn
"autocmd WinEnter * setlocal cursorline
"autocmd BufEnter * setlocal cursorline
"hi cursorcolumn ctermbg=247 ctermfg=?? guibg=grey70 guifg=??
"hi cursorline ctermbg=247 guibg=grey70

autocmd InsertLeave * call s:LeaveInsert()
autocmd InsertEnter * call s:EnterInsert()


au BufRead,BufNewFile *.json set filetype=json
au! Syntax json source /Users/emir/.vim/ftplugin/json.vim
set autowriteall
:setlocal tags=TAGS
let &tags="tags;./tags"
let s:tfs=split(globpath(&rtp, "tags/*.tags"),"\n")
for s:tf in s:tfs
     let &tags.=",".expand(escape(escape(s:tf, " "), " "))
   endfor


let g:speckyBannerKey        = "<C-S>b"
let g:speckyQuoteSwitcherKey = "<C-S>'"
let g:speckyRunRdocKey       = "<C-S>r"
let g:speckySpecSwitcherKey  = "<C-S>x"
let g:speckyRunSpecKey       = "<C-S>s"
let g:speckyRunRdocCmd       = "fri -L -f plain"
let g:speckyWindowType       = 2

" change background depending on mode
function! s:EnterInsert()
    "highlight Normal guibg=#442222
    "highlight Normal guibg=#000000
endfunction

function! s:LeaveInsert()
  "molokai"
   "hi Normal          guifg=#F8F8F2 guibg=#1B1D1E
endfunction

"http://stackoverflow.com/questions/1979520/auto-open-nerdtree-in-every-tab
"autocmd VimEnter *.rb NERDTree
"autocmd VimEnter *.rb TlistToggle
"filetype off
autocmd BufWritePost *.coffee CoffeeMake!
set viminfo='100,f1

"dictinary
set dictionary= "/usr/share/dict/words"
"setlocal spell spelllang=en_us
map <f4> :CoffeeCompile <CR>
" Vimcasts #1
" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>
"  
"  " Use the same symbols as TextMate for tabstops and EOLs
set listchars=tab:▸\ ,eol:¬
" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif
" edit the vimrc file after saving it
let mapleader = ","
nmap <leader>v :tabedit $MYVIMRC<CR>


nmap <leader>nf :NERDTreeFind<CR>
" open current window maximized
nmap t% :tabedit %<CR>
nmap td :tabclose<CR>

" next buffer 
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

" buffexplorer 
nnoremap <C-b> :BufExplorer<CR>

"ruby
"autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
""improve autocomplete menu color
highlight Pmenu ctermbg=238 gui=bold


"remaping collinding leader mappings on ruby-debuggenstall vim-ruby --remoter,
"needs commenting out the original mappings

noremap <leader>db  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.toggle_breakpoint()<CR>
noremap <leader>dv  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.open_variables()<CR>
noremap <leader>dm  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.open_breakpoints()<CR>
noremap <leader>dt  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.open_frames()<CR>
noremap <leader>ds  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.step()<CR>
noremap <leader>df  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.finish()<CR>
noremap <leader>dn  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.next()<CR>
noremap <leader>dc  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.continue()<CR>
noremap <leader>de  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.exit()<CR>
noremap <leader>dd  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.remove_breakpoints()<CR>

"fast color change
noremap <leader>c1  :color moria<CR>
noremap <leader>c2  :color vividchalk<CR>
noremap <leader>c3  :color molokai<CR>
"
" fix for rubby debugger
let g:ruby_debugger_progname = 'mvim'
let g:ruby_debugger_spec_path = '/Users/emir/.rvm/gems/ruby-1.8.7-p334@hoppakay/bin/rspec'         " set Rspec path

" rails.vim
noremap <leader>rc :Rcontroller<CR>
noremap <leader>rm :Rmodel<CR>
noremap <leader>rmi :Rmigration<CR>
noremap <leader>rl :Rlocale<CR>
noremap <leader>rv :Rview<CR>
