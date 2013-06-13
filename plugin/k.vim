" vim: tabstop=2 shiftwidth=2 softtabstop=2 expandtab foldmethod=marker
" ff=unix
"
function! s:PatternName(fName)
  let l:fName = a:fName
  let l:fName = substitute(l:fName,'[','\\[',"g")
  let l:fName = substitute(l:fName,']','\\]',"g")
  let l:fName = substitute(l:fName,' ','\\ ',"g")
  return l:fName
endfunction

function! s:FocusMyConsole(winOp, winName)
  let l:fName = <SID>PatternName(a:winName)
  let l:consoleWin = bufwinnr('^'.l:fName.'$')
  if(l:consoleWin == -1)
    execute "silent ".a:winOp." new ".l:fName
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal noswapfile
    setlocal noreadonly
    let b:k_console = 1
    let l:consoleWin = bufwinnr('^'.l:fName.'$')
  endif
  execute l:consoleWin."wincmd w"
endfunction

function! s:RunCmd(exCmd)
  if a:exCmd[0] == "!"
    let l:shCmd = strpart(a:exCmd,1)
    let l:result = split(system(l:shCmd),"\\n")
    return l:result
  else
    redi @x
    silent exec a:exCmd
    redi END
    let l:result = split(@x,"\\n")
    return l:result
  endif
endfunction

function! k#ReadExCmdIntoConsole(winOp,winName,ft,exCmd)
  let l:result = <SID>RunCmd(a:exCmd)
  let l:tName = bufname('%')
  call <SID>FocusMyConsole(a:winOp, a:winName)
  exec "set ft=".a:ft
  exec "normal gg\"_dG"
  call append(0, l:result)
  execute "normal gg"
  if(l:tName != a:winName)
    execute "normal \<c-w>p"
  endif
endfunction

function! k#ReadExCmd(exCmd)
  let l:result = <SID>RunCmd(a:exCmd)
  call append(0, l:result)
endfunction

function! k#RunMe(interpreter, winOp, winName)
  silent 1,$y
  call <SID>FocusMyConsole(a:winOp, a:winName)
  exec "normal gg\"_dGP"
  silent exec '%!'.a:interpreter
  execute "normal \<c-w>p"
endfunction

function! k#CloseConsole(winName)
  let l:fName = <SID>PatternName(a:winName)
  let l:consoleWin = bufwinnr('^'.l:fName.'$')
  if(l:consoleWin != -1)
    let l:fName = <SID>PatternName(bufname('%'))
    execute l:consoleWin."wincmd w"
    bdelete
    let l:cwn = bufwinnr('^'.l:fName.'$')
    execute l:cwn."wincmd w"
  endif
endfunction

autocmd BufEnter * if &buftype=="nofile" && winbufnr(2) == -1 && exists('b:k_console') == 1 | quit | endif

autocmd FileType sh         nnoremap <buffer> <leader>r :call k#RunMe('bash', 'botri 10', ">- K.VIM -<")<CR>
autocmd FileType php        nnoremap <buffer> <leader>r :call k#RunMe('php', 'botri 10', ">- K.VIM -<")<CR>
autocmd FileType python     nnoremap <buffer> <leader>r :call k#RunMe('python', 'botri 10', ">- K.VIM -<")<CR>
autocmd FileType ruby       nnoremap <buffer> <leader>r :call k#RunMe('ruby', 'botri 10', ">- K.VIM -<")<CR>
autocmd FileType perl       nnoremap <buffer> <leader>r :call k#RunMe('perl', 'botri 10', ">- K.VIM -<")<CR>
autocmd FileType javascript nnoremap <buffer> <leader>r :call k#RunMe('node', 'botri 10', ">- K.VIM -<")<CR>
autocmd FileType jade       nnoremap <buffer> <leader>r :call k#RunMe('jade -P', 'botri 10', ">- K.VIM -<")<CR>
nnoremap <silent> <space>, :call k#CloseConsole(">- K.VIM -<")<CR>
com! -nargs=* -complete=command -bar Rc call k#ReadExCmdIntoConsole("botri 10", ">- K.VIM -<", "", <q-args>)
com! -nargs=* -complete=command -bar Ri call k#ReadExCmd(<q-args>)

if !exists('g:kdbDir')
  let g:kdbDir = expand("<sfile>:p:h")
  if has("win32")
    let g:kdbDir = substitute(g:kdbDir,"\\","\/","g")
  endif
  let g:kdbDir = g:kdbDir."/../db"
endif

function! k#AutoLoadDict()
  let a = split(globpath(g:kdbDir, "**/*.idx"), "\n")
  for fn in a
    if getftype(fn) == 'file'
      let fn = substitute(fn,"\\","\/","g")
      let l:type = substitute(fn,".*/","","")
      let l:type = substitute(l:type,'\..*$',"","")
      if has_key(g:globalDBkeys,l:type)
        exec "nnoremap <silent> ".g:globalDBkeys[l:type]." :call k#ReadExCmdIntoConsole('topleft 20', '>- K.VIM -<', '', '!kv query ".fn." '.expand('<cword>'))<CR>"
      else
        let l:localKeys = ['K', '<C-k>']
        if has_key(g:localDBkeys,l:type)
          let l:localKeys = g:localDBkeys[l:type]
        endif
        exec "autocmd FileType ".l:type." nnoremap <buffer> <silent> ".l:localKeys[0]." :call k#ReadExCmdIntoConsole('topleft 30', '>- K.VIM -<', '".l:type."', '!kv query ".fn." '.expand('<cword>'))<CR>"
        exec "autocmd FileType ".l:type." inoremap <buffer> <silent> ".l:localKeys[1]." <Esc>:call k#ReadExCmdIntoConsole('topleft 30', '>- K.VIM -<', '".l:type."', '!kv query ".fn." '.expand('<cword>'))<CR>a"
      endif
    endif
  endfor
endfunction

call k#AutoLoadDict()
