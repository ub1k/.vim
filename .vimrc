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

" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers
set hidden

" Remember more commands and search history
" set
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
set nobackup
set nowritebackup
set noswapfile

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set nobackup		" keep a backup file
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

  " set fuoptions=maxvert,maxhorz " Fill Screen With Window
  set guifont=Inconsolata-dz:h14
  " GRB: set window size"
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  au BufNewFile,BufRead *.ejs set filetype=html

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

" folding
" GRB: wrap lines at 78 characters
" set textwidth=78

" GRB: Highlight long lines
" Turn long-line highlighting off when entering all files, then on when
" entering certain files. I don't understand why :match is so stupid that
" setting highlighting when entering a .rb file will cause e.g. a quickfix
" window opened later to have the same match. There doesn't seem to be any way
" to localize it to a file type.
" function! HighlightLongLines()
"   hi LongLine guifg=NONE guibg=NONE gui=undercurl ctermfg=white ctermbg=red cterm=NONE guisp=#FF6C60 " undercurl color
" endfunction
" function! StopHighlightingLongLines()
"   hi LongLine guifg=NONE guibg=NONE gui=NONE ctermfg=NONE ctermbg=NONE cterm=NONE guisp=NONE
" endfunction
" autocmd TabEnter,WinEnter,BufWinEnter * call StopHighlightingLongLines()
" autocmd TabEnter,WinEnter,BufWinEnter *.rb,*.py call HighlightLongLines()
" hi LongLine guifg=NONE
" match LongLine '\%>78v.\+'

" GRB: highlighting search"
set hls

if has("gui_running")
  " GRB: set font"
  ":set nomacatsui anti enc=utf-8 gfn=Monaco:h12

  " GRB: set window size"
  :set lines=100
  :set columns=300
" 
"   " GRB: highlight current line"
"   :set cursorline
endif

" GRB: set the color scheme
:set t_Co=256 " 256 colors
" :set background=dark
:set background=light
:color solarized
" :color grb256

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

" GRB: use emacs-style tab completion when selecting files, etc
set wildmode=longest,list

" GRB: Put useful info in status line
:set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
:hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red

" GRB: clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>

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
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

" When hitting <;>, complete a snippet if there is one; else, insert an actual
" <;>
function! InsertSnippetWrapper()
    let inserted = TriggerSnippet()
    if inserted == "\<tab>"
        return ";"
    else
        return inserted
    endif
endfunction

if version >= 700
    autocmd FileType python set omnifunc=pythoncomplete#Complete
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

" nnoremap <leader>t :call RunAllTests('')<cr>:redraw<cr>:call JumpToError()<cr>
" nnoremap <leader>T :call RunAllTests('')<cr>

" nnoremap <leader>t :call JumpToTestsForClass()<cr>

" highlight current line
" set cursorline

set cursorline
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
  autocmd FileType snippet,ruby,haml,eruby,yaml,html,javascript,sass,cucumber,objc,jasmine.coffee set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et
augroup END

set switchbuf=useopen

autocmd BufRead,BufNewFile *.html source ~/.vim/indent/html_grb.vim
autocmd FileType htmldjango source ~/.vim/indent/html_grb.vim
autocmd! BufRead,BufNewFile *.sass setfiletype sass 

" Map ,e and ,v to open files in the same directory as the current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
" from objective vimmer"
map <leader>cl :Class 
map <leader>v :view %%
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'))
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>

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
    :let l:tmp_a = @a
    :normal "ayiw
    " Delete variable and equals sign
    :normal 2daW
    " Delete the expression into the 'b' register
    :let l:tmp_b = @b
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
    :let @a = l:tmp_a
    :let @b = l:tmp_b
endfunction

vnoremap <leader>rv :call ExtractVariable()<cr>
nnoremap <leader>ri :call InlineVariable()<cr>
" " Find comment
" map <leader>/# /^ *#<cr>
" " Find function
" map <leader>/f /^ *def\><cr>
" " Find class
" map <leader>/c /^ *class\><cr>
" " Find if
" map <leader>/i /^ *if\><cr>
" " Delete function
" " \%$ means 'end of file' in vim-regex-speak
" map <leader>df d/\(^ *def\>\)\\|\%$<cr>
" com! FindLastImport :execute'normal G<CR>' | :execute':normal ?^\(from\|import\)\><CR>'
" map <leader>/m :FindLastImport<cr>

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

" Always show tab bar
set showtabline=2

augroup mkd
    autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
    autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;
augroup END

" set makeprg=python\ -m\ nose.core\ --machine-out

map <silent> <leader>y :<C-u>silent '<,'>w !pbcopy<CR>

" Make <leader>' switch between ' and "
nnoremap <leader>' ""yls<c-r>={'"': "'", "'": '"'}[@"]<cr><esc>

" Map keys to go to specific files
map <leader>gr :topleft :split config/routes.rb<cr>
function! ShowRoutes()
  " Requires 'scratch' plugin
  :topleft 100 :split __Routes__
  " Make sure Vim doesn't write __Routes__ as a file
  :set buftype=nofile
  " Delete everything
  :normal 1GdG
  " Put routes output in buffer
  :0r! rake -s routes
  " Size window to number of lines (1 plus rake output length)
  :exec ":normal " . line("$") . "_ "
  " Move cursor to bottom
  :normal 1GG
  " Delete empty trailing line
  :normal dd
endfunction

nnoremap <leader><leader> <c-^>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Running tests
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


function! RunTests(filename)
    " Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo
    if filereadable("script/test")
        exec ":!script/test " . a:filename
    else
        exec ":!bundle exec rspec " . a:filename
    end
endfunction

function! SetTestFile()
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_spec_file = match(expand("%"), '_spec.rb$') != -1
    if in_spec_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        return
    end
    call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number)
endfunction

map <leader>t :call RunTestFile()<cr>
map <leader>T :call RunNearestTest()<cr>
map <leader>a :call RunTests('spec')<cr>
map <leader>c :w\|:!cucumber<cr>
map <leader>C :w\|:!cucumber --profile wip<cr>

" set winwidth=84
" We have to have a winheight bigger than we want to set winminheight. But if
" we set winheight to be huge before winminheight, the winminheight set will
" fail.
" set winheight=5
" set winminheight=5
" set winheight=999

nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
" nnoremap <c-n> :let &wh = (&wh == 999 ? 10 : 999)<CR><C-W>=

function! ShowColors()
  let num = 255
  while num >= 0
    exec 'hi col_'.num.' ctermbg='.num.' ctermfg=white'
    exec 'syn match col_'.num.' "ctermbg='.num.':...." containedIn=ALL'
    call append(0, 'ctermbg='.num.':....')
    let num = num - 1
  endwhile
endfunction

command! -range Md5 :echo system('echo '.shellescape(join(getline(<line1>, <line2>), '\n')) . '| md5')

imap <c-l> <space>-><space>
imap <c-L> <space>=><space>

function! OpenChangedFiles()
  only " Close all windows, unless they're modified
  let status = system('git status -s | grep "^ \?\(M\|A\)" | cut -d " " -f 3')
  let filenames = split(status, "\n")
  exec "edit " . filenames[0]
  for filename in filenames[1:]
    exec "sp " . filename
  endfor
endfunction
command! OpenChangedFiles :call OpenChangedFiles()

if &diff
  nmap <c-h> :diffget 1<cr>
  nmap <c-l> :diffget 3<cr>
  nmap <c-k> [cz.
  nmap <c-j> ]cz.
  set nonumber
endif

" In these functions, we don't use the count argument, but the map referencing
" v:count seems to make it work. I don't know why.
function! ScrollOtherWindowDown(count)
  normal! 
  normal! 
  normal! 
endfunction
function! ScrollOtherWindowUp(count)
  normal! 
  normal! 
  normal! 
endfunction
nnoremap g<c-y> :call ScrollOtherWindowUp(v:count)<cr>
nnoremap g<c-e> :call ScrollOtherWindowDown(v:count)<cr>

" interactive shell"
set shell=/bin/zsh\ -l

" Can't be bothered to understand the difference between ESC and <c-c> in
" insert mode
imap <c-c> <esc>

command! InsertTime :normal a<c-r>=strftime('%F %H:%M:%S.0 %z')<cr>


function! PromoteToLet()
  :normal! dd
  " :exec '?^\s*it\>'
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
  " :normal! <<
  " :normal! ilet(:
  " :normal! f 2cl) {
  " :normal! A }
endfunction

:command! PromoteToLet :call PromoteToLet()
:map <leader>p :PromoteToLet<cr>

filetype off
set runtimepath+=~/.vim/vundle.git/ " my dev version



"Plugins " {{{
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'
"" trying this
" Bundle "YankRing.vim"
" bundle "http://github.com/thinca/vim-quickrun.git"
" bundle "http://github.com/thinca/vim-poslist.git"
" bundle "http://github.com/mattn/gist-vim.git"
" bundle "http://github.com/rstacruz/sparkup.git", {'rtp': 'vim/'}
" bundle "https://github.com/astashov/vim-ruby-debugger.git" 
let g:ruby_debugger_debug_mode = 1
let g:ruby_debugger_default_script = "script/rails s"
map <leader>db  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.toggle_breakpoint()<CR>
map <leader>dv  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.open_variables()<CR>
map <leader>dm  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.open_breakpoints()<CR>
map <leader>dt  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.open_frames()<CR>
map <leader>ds  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.step()<CR>
map <leader>df  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.finish()<CR>
map <leader>dn  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.next()<CR>
map <leader>dc  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.continue()<CR>
map <leader>de  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.exit()<CR>
map <leader>dd  :call ruby_debugger#load_debugger() <bar> call g:RubyDebugger.remove_breakpoints()<CR>
"
"" Programming
Bundle "jQuery"
Bundle "https://github.com/tpope/vim-rails.git"
Bundle "https://github.com/tpope/vim-bundler.git"
Bundle "https://github.com/tpope/vim-rvm.git"
Bundle "https://github.com/tpope/vim-abolish.git"
Bundle "https://github.com/tpope/vim-unimpaired.git"
" Bundle "https://github.com/vim-scripts/project.tar.gz.git" 
Bundle "https://github.com/vim-scripts/a.vim.git" 
noremap <leader>rc :Rcontroller<CR>
noremap <leader>rm :Rmodel<CR>
noremap <leader>rmi :Rmigration<CR>
noremap <leader>rl :Rlocale<CR>
noremap <leader>rv :Rview<CR>

Bundle "https://github.com/pangloss/vim-javascript.git"
Bundle "https://github.com/kchmck/vim-coffee-script.git"
Bundle "https://github.com/eraserhd/vim-kiwi.git"
Bundle "https://github.com/Rip-Rip/clang_complete.git" 
let xcode_platform_path = '/Developer/Platforms/iPhoneSimulator.platform'
let ios_sdk_path = xcode_platform_path . '/Developer/SDKs/iPhoneSimulator5.0.sdk'
"clangコマンドの最後に追加されるオプション
let options_for_ios = [
      \ '-isysroot', ios_sdk_path,
      \ '-fblocks',
      \ '-fexceptions',
      \ '-D__IPHONE_OS_VERSION_MIN_REQUIRED=40300',
      \ '-F' . ios_sdk_path . '/System/Library/Frameworks',
      \ '-include', 'Foundation/Foundation.h',
      \ '-include', 'UIKit/UIKit.h',
      \ '-Include', '.'
      \]

let g:clang_exec = xcode_platform_path.'/Developer/usr/bin/clang'
let g:clang_user_options = ''
for o in options_for_ios
  let g:clang_user_options .= ' '.shellescape(o)
endfor

" pythonで落ちる threadの取り回しが甘いんだろうなぁ
let g:clang_use_library = 0
let g:clang_library_path = '/Developer/usr/clang-ide/lib'

let g:clang_complete_auto = 0
let g:clang_complete_copen = 0
let g:clang_periodic_quickfix = 0
let g:clang_complete_macros = 1
let g:clang_complete_patterns = 0

if g:clang_use_library
else
  let g:clang_user_options .= ' 2>/dev/null || exit 0'
endif

let g:clang_debug = 0
" Bundle "https://github.com/msanders/cocoa.vim"

map <f4> :CoffeeCompile <CR>
" with bare option 
" autocmd BufWritePost *.coffee silent CoffeeMake! -b | cwindow | redraw!
Bundle "http://github.com/claco/jasmine.vim.git"
Bundle "http://github.com/mattn/zencoding-vim.git"
" Bundle "https://github.com/scrooloose/nerdtree.git"
" nmap <leader>nf :NERDTreeFind<CR>
Bundle "Specky"
" Bundle "Tagbar"
" " au BufRead,BufNewFile *.js TagbarOpen
" " autocmd FileType objc :TagbarOpen
" let g:tagbar_ctags_bin='/usr/local/bin/ctags'  " Proper Ctags locations
" let g:tagbar_width=30                          " Default is 40, seems too wide
" let g:tagbar_autofocus = 1
" let g:tagbar_compact = 1
" let g:tagbar_expand = 1
" let g:tagbar_autoshowtag = 1
" let g:tagbar_left = 1

" only variables and f = () -> functions, no class members, methods etc (yet)
" let g:tagbar_type_coffee = {
"       \ 'ctagstype' : 'coffee',
"       \ 'kinds' : [
"       \ 'c:class',
"       \ 'n:namespace',
"       \ 'f:functions',
"       \ 'm:methods',
"       \ 'v:variables'
"       \ ],
"       \ }
" let g:tagbar_type_objc = {
"     \ 'ctagstype' : 'objc',
"     \ 'kinds'     : [
"         \ 'c:class',
"         \ 'p:property',
"         \ 'm:method',
"         \ 'i:interface'
"     \ ],
"     \ 'sro'        : '.'
" \ }
" Display panel with \y (or ,y
" noremap <silent> <Leader>y :TagbarToggle<CR>
" Bundle "https://github.com/vim-scripts/taglist.vim.git" 
" noremap <silent> <Leader>tl :TlistToggle<CR>
" autocmd BufLeave *LIST__ silent TlistClose 

"
"" Snippets
Bundle "git://github.com/MarcWeber/vim-addon-mw-utils.git"
Bundle "git://github.com/tomtom/tlib_vim.git"
Bundle "git://github.com/honza/snipmate-snippets.git"
Bundle "git://github.com/garbas/vim-snipmate.git"
" let g:snips_trigger_key='<c-space>'
" let g:snips_trigger_key_backwards='<s-c-space>'
Bundle "https://github.com/shanejonas/coffeeScript-VIM-Snippets.git"
"
"" Syntax highlight
Bundle "cucumber.zip"
Bundle "Markdown"
"
"" Color 
Bundle "https://github.com/tpope/vim-vividchalk.git"
Bundle "https://github.com/nelstrom/vim-mac-classic-theme.git"
Bundle "https://github.com/altercation/vim-colors-solarized"

"" Git integration
Bundle "git.zip"
Bundle "https://github.com/tpope/vim-fugitive.git"
Bundle "https://github.com/tpope/vim-eunuch.git"
Bundle "https://github.com/scrooloose/syntastic.git"
let g:syntastic_auto_jump=1
let g:syntastic_auto_loc_list=1
set statusline=%<%f\ %h%m%r%{rvm#statusline()}%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
"
"" (HT|X)ml tool
Bundle "https://github.com/godlygeek/tabular.git" 
Bundle "ragtag.vim"
"
"" Utility
Bundle "https://github.com/vim-scripts/Google-translator" 
let g:langpair="nl"
Bundle "grep.vim"
Bundle "Toggle"
Bundle "http://github.com/tsaleh/vim-matchit.git"
Bundle "https://github.com/kana/vim-textobj-user.git"
Bundle "https://github.com/nelstrom/vim-textobj-rubyblock.git"
Bundle "repeat.vim"
Bundle "surround.vim"
Bundle "file-line"
Bundle "Align"
" Bundle "AutoComplPop"
" let g:acp_enableAtStartup = 0
" Bundle "https://github.com/vim-scripts/Conque-Shell.git" 
" let g:ConqueTerm_TERM = 'vt100'
"" experimental
Bundle "https://github.com/eraserhd/vim-ios.git"


" Bundle "neocomplcache"
" let g:neocomplcache_enable_at_startup = 1
" " let g:neocomplcache_auto_completion_start_length = 5
" let g:neocomplcache_enable_ignore_case			 = 0
" let g:neocomplcache_enable_auto_select = 0
" let g:neocomplcache_cursor_hold_i_time = 500 			
" let g:neocomplcache_enable_camel_case_completion = 1
" let g:neocomplcache_ctags_program				= '/usr/local/bin/ctags'  " Proper Ctags locations
" imap <C-k>     <Plug>(neocomplcache_snippets_expand)
" smap <C-k>     <Plug>(neocomplcache_snippets_expand)
" inoremap <expr><C-g>     neocomplcache#undo_completion()
" inoremap <expr><C-l>     neocomplcache#complete_common_string() 
" " SuperTab like snippets behavior.
" imap <expr><TAB> neocomplcache#sources#snippets_complete#expandable() ? "\<Plug>(neocomplcache_snippets_expand)" : pumvisible() ? "\<C-n>" : "\<TAB>"
" " Recommended key-mappings.
" " <CR>: close popup and save indent.
" inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
" " <TAB>: completion.
" inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" " <C-h>, <BS>: close popup and delete backword char.
" inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
" inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
" inoremap <expr><C-y>  neocomplcache#close_popup()
" inoremap <expr><C-e>  neocomplcache#cancel_popup()
"Bundle "https://github.com/topfunky/PeepOpen-EditorSupport.git"
"
"" FuzzyFinder

Bundle "L9"
" Bundle "FuzzyFinder"
" let g:fuf_modesDisable = [] " {{{
" nnoremap <silent> <LocalLeader>h :FufHelp<CR>
" nnoremap <silent> <LocalLeader>2 :FufFileWithCurrentBufferDir<CR>
" nnoremap <silent> <LocalLeader>@ :FufFile<CR>
" nnoremap <silent> <LocalLeader>3 :FufBuffer<CR>
" nnoremap <silent> <LocalLeader>4 :FufDirWithCurrentBufferDir<CR>
" nnoremap <silent> <LocalLeader>$ :FufDir<CR>
" nnoremap <silent> <LocalLeader>5 :FufChangeList<CR>
" nnoremap <silent> <LocalLeader>6 :FufMruFile<CR>
" nnoremap <silent> <LocalLeader>7 :FufLine<CR>
" nnoremap <silent> <LocalLeader>8 :FufBookmark<CR>
" nnoremap <silent> <LocalLeader>* :FuzzyFinderAddBookmark<CR><CR>
" nnoremap <silent> <LocalLeader>9 :FufTaggedFile<CR>
" " emir
" map <leader>f :FufFile<cr>
" map <leader>b :FufBuffer<cr>
"" " }}}
"
"" Zoomwin
Bundle "ZoomWin"
noremap <LocalLeader>o :ZoomWin<CR>
vnoremap <LocalLeader>o <C-C>:ZoomWin<CR>
inoremap <LocalLeader>o <C-O>:ZoomWin<CR>
noremap <C-W>+o :ZoomWin<CR>
"
"" Ack
Bundle "ack.vim"
noremap <LocalLeader># "ayiw:Ack <C-r>a<CR>
vnoremap <LocalLeader># "ay:Ack <C-r>a<CR>
"
"" tComment
" Bundle "tComment"
Bundle "git://github.com/tpope/vim-commentary.git"
"nnoremap // :TComment<CR>
"vnoremap // :TComment<CR>
"
"" Command-T
Bundle "git://git.wincent.com/command-t.git"
let g:CommandTMatchWindowAtTop=0 " show window at top
map <leader>f :CommandTFlush<cr>\|:CommandT<cr>
map <leader>F :CommandTFlush<cr>\|:CommandT %%<cr>
map <leader>b :CommandTFlush<cr>\|:CommandTBuffer<cr>
augroup rails
  autocmd FileType ruby map <leader>gR :call ShowRoutes()<cr>
  autocmd FileType ruby map <leader>gv :CommandTFlush<cr>\|:CommandT app/views<cr>
  autocmd FileType ruby map <leader>gc :CommandTFlush<cr>\|:CommandT app/controllers<cr>
  autocmd FileType ruby map <leader>gm :CommandTFlush<cr>\|:CommandT app/models<cr>
  autocmd FileType ruby map <leader>gh :CommandTFlush<cr>\|:CommandT app/helpers<cr>
  autocmd FileType ruby map <leader>gl :CommandTFlush<cr>\|:CommandT lib<cr>
  autocmd FileType ruby map <leader>gp :CommandTFlush<cr>\|:CommandT public<cr>
  autocmd FileType ruby map <leader>gs :CommandTFlush<cr>\|:CommandT public/stylesheets/sass<cr>
  autocmd FileType ruby map <leader>gj :CommandTFlush<cr>\|:CommandT app/assets/javascripts<cr>
  autocmd FileType ruby map <leader>gf :CommandTFlush<cr>\|:CommandT features<cr>
  autocmd FileType ruby map <leader>gg :topleft 100 :split Gemfile<cr>
  autocmd FileType coffee map <leader>gg :topleft 100 :split Gemfile<cr>
  autocmd FileType coffee map <leader>gm :CommandTFlush<cr>\|:CommandT app/assets/javascripts/models<cr>
  autocmd FileType coffee map <leader>gc :CommandTFlush<cr>\|:CommandT app/assets/javascripts/collections<cr>
  autocmd FileType coffee map <leader>gv :CommandTFlush<cr>\|:CommandT app/assets/javascripts/views<cr>
  autocmd FileType coffee map <leader>gt :CommandTFlush<cr>\|:CommandT app/assets/javascripts/templates<cr>
  autocmd FileType coffee map <leader>gr :CommandTFlush<cr>\|:CommandT app/assets/javascripts/routers<cr>
augroup END
augroup objc
  " autocmd FileType objc map <leader>gR :call ShowRoutes()<cr>
  autocmd FileType objc map <leader>gv :CommandTFlush<cr>\|:CommandT Classes/Views<cr>
  autocmd FileType objc map <leader>gc :CommandTFlush<cr>\|:CommandT Classes/Controllers<cr>
  autocmd FileType objc map <leader>gm :CommandTFlush<cr>\|:CommandT Classe/CoreData<cr>
  autocmd FileType objc map <leader>gh :CommandTFlush<cr>\|:CommandT Classes/Helpers<cr>
  autocmd FileType objc map <leader>gl :CommandTFlush<cr>\|:CommandT Classes/lib<cr>
  " autocmd FileType objc map <leader>gp :CommandTFlush<cr>\|:CommandT public<cr>
  " autocmd FileType objc map <leader>gs :CommandTFlush<cr>\|:CommandT public/stylesheets/sass<cr>
  " autocmd FileType objc map <leader>gf :CommandTFlush<cr>\|:CommandT features<cr>
  " autocmd FileType objc map <leader>gg :topleft 100 :split Gemfile<cr>

augroup END
"" Navigation
" Bundle "http://github.com/gmarik/vim-visual-star-search.git"
"" External
Bundle "https://github.com/robbyrussell/oh-my-zsh.git"
"
" " }}}
filetype plugin indent on " Automatically detect file types.
set ofu=syntaxcomplete#Complete
syntax on " enable syntax


set viminfo='100,f1

"dictinary
set dictionary= "/usr/share/dict/words"
"setlocal spell spelllang=en_us
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
nmap <leader>vi :tabedit $MYVIMRC<CR>


" open current window maximized
nmap t% :tabedit %<CR>
nmap td :tabclose<CR>
imap jQ jQuery

" next buffer 
" nnoremap <C-n> :bnext<CR>
" nnoremap <C-p> :bprevious<CR>

" buffexplorer 
" nnoremap <C-b> :BufExplorer<CR>

""improve autocomplete menu color
highlight Pmenu ctermbg=238 gui=bold

"fast color change
noremap <leader>c0  :color grb4<CR>
noremap <leader>c9  :color grb256<CR>
noremap <leader>c1  :color moria<CR>
noremap <leader>c2  :color vividchalk<CR>
noremap <leader>c3  :color molokai<CR>
noremap <leader>c4  :color macvim<CR>
noremap <leader>c5  :color solarize<CR>
noremap <leader>c6  :set background=light<CR>
noremap <leader>c7  :set background=dark<CR>
" GRB: set the color scheme
"
set foldmethod=indent
set foldlevelstart=99
"build ctags for the cwd
nmap <leader>ct :!ctags -R --language-force=ObjectiveC  --extra=+q /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.0.sdk/System/Library/Frameworks ./Classes/*<CR>
" au BufNewFile,BufRead *.cpp,*.c,*.h,*.java,*.m syn region myCComment start="\/**" end="\**\/" fold keepend transparent

if filereadable("./project.vim")
  source ./project.vim
endif



"build ctags for the cwd
":nmap <leader>ct :!ctags -R *<CR>
"
""build ctags for the cwd
:nmap <leader>ct :!ctags -R *<CR>


function! s:ExecuteInShell(command)
  let command = join(map(split(a:command), 'expand(v:val)'))
  let winnr = bufwinnr('^' . command . '$')
  silent! execute  winnr < 0 ? 'botright new ' . fnameescape(command) : winnr . 'wincmd w'
  setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
  echo 'Execute ' . command . '...'
  silent! execute 'silent %!'. command
  silent! execute 'resize ' . line('$')
  silent! redraw
  silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
  silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>'
  echo 'Shell command ' . command . ' executed.'
endfunction
command! -complete=shellcmd -nargs=+ Shell call s:ExecuteInShell(<q-args>)
ca shell Shell
                      
