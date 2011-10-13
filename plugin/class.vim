"from objective vimmer"
let s:ClassDirectory = ""


command! -nargs=1 -complete=customlist,CompleteClass Class :call Class(<q-args>)
function! Class(Name)
    let s:ClassDirectory = expand("%:h")
    let l:SpecFile = s:ClassDirectory . "/" . a:Name . "Spec.m"
    if filereadable(l:SpecFile)
        exec "tabedit " . l:SpecFile
        exec "vsplit " . s:ClassDirectory . "/" . a:Name . ".m"
        exec "split " . s:ClassDirectory . "/" . a:Name . ".h"
    else
        exec "tabedit " . s:ClassDirectory . "/" . a:Name . ".m"
        exec "vsplit " . s:ClassDirectory . "/" . a:Name . ".h"
    endif
endfunction

function! CompleteClass(a,b,c)
    let s:ClassDirectory = expand("%:h")
    let l:Result = split(glob(s:ClassDirectory . "/*.m"))
    let l:Result = map(l:Result, 'substitute(v:val, "^" . s:ClassDirectory . "/", "", "")')
    let l:Result = map(l:Result, 'substitute(v:val, "\.m$", "", "")')
    let l:Result = filter(l:Result, 'v:val =~ "^" . a:a')
    let l:Result = filter(l:Result, 'v:val !~ "Spec$"')
    return l:Result
endfunction


" vi:set sts=2 sw=2 ai et:
