" vim: tabstop=2 shiftwidth=2 softtabstop=2 expandtab foldmethod=marker
" ff=unix
"
" Copyright (c) 2013 Brook Hong

" The MIT License

" Permission is hereby granted, free of charge, to any person obtaining
" a copy of this software and associated documentation files
" (the "Software"), to deal in the Software without restriction,
" including without limitation the rights to use, copy, modify,
" merge, publish, distribute, sublicense, and/or sell copies of the
" Software, and to permit persons to whom the Software is furnished
" to do so, subject to the following conditions:

" The above copyright notice and this permission notice shall be included
" in all copies or substantial portions of the Software.

" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
" OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
" IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
" CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
" TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
" SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function! s:FocusMyConsole(winOp)
  if !exists('b:lordWin')
    let l:mw = bufnr('%')
    if exists('b:consoleWin') && bufwinnr(b:consoleWin) != -1
      execute bufwinnr(b:consoleWin)."wincmd w"
    else
      execute "silent ".a:winOp." new [Scratch] for ".bufname(l:mw)."@".l:mw
      setlocal enc=utf-8
      setlocal buftype=nofile
      setlocal nobuflisted
      setlocal noswapfile
      setlocal noreadonly
      let b:lordWin = l:mw
      let l:cw = bufnr('%')
      call setbufvar(l:mw, "consoleWin", l:cw)
    endif
  endif
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

function! k#ReadExCmdIntoConsole(winOp,ft,exCmd)
  let l:result = <SID>RunCmd(a:exCmd)
  let l:mw = bufnr('%')
  call <SID>FocusMyConsole(a:winOp)
  exec "set ft=".a:ft
  exec "normal gg\"_dG"
  call append(0, l:result)
  execute "normal gg"
  execute bufwinnr(l:mw)."wincmd w"
endfunction

function! k#ReadExCmd(exCmd)
  let l:result = <SID>RunCmd(a:exCmd)
  call append(0, l:result)
endfunction

function! k#RunReg(reg, interpreter, winOp, ft, preline)
  call <SID>FocusMyConsole(a:winOp)
  exec "set ft=".a:ft
  exec "normal G\"".a:reg."pk\"_dgg"
  if a:preline != ''
    call append(0, a:preline)
  endif
  silent exec '%!'.a:interpreter
  execute "normal \<c-w>p"
endfunction

function! k#RunMe(interpreter, winOp, ft)
  silent 1,$y k
  call k#RunReg('k', a:interpreter, a:winOp, a:ft, '')
endfunction

function! k#Run(winOp, ft)
  call inputsave()
  let l:interpreter = input("Run with:")
  call inputrestore()
  if l:interpreter != ""
    call k#RunReg('k', l:interpreter, a:winOp, a:ft, '')
  else
    echomsg "Canceled as no interpreter was specified."
  endif
endfunction

function! k#RunLine(interpreter, winOp, ft, preline)
  normal "kyy
  call k#RunReg('k', a:interpreter, a:winOp, a:ft, a:preline)
endfunction

"nnoremap <silent> <leader>x "kyy:call k#Run('botri 30', '')<cr>
vnoremap <silent> <leader>r "ky:call k#Run('botri 30', '')<cr>

function! k#CloseConsole()
  if exists('b:consoleWin') && bufwinnr(b:consoleWin) != -1
    execute b:consoleWin."bd"
  endif
endfunction

function! k#UnregConsole()
  if winbufnr(3) != -1 && exists('b:consoleWin') && bufwinnr(b:consoleWin) != -1
    execute b:consoleWin."bd"
  endif
endfunction

autocmd BufEnter * if &buftype=="nofile" && winbufnr(2) == -1 && exists('b:lordWin') == 1 | quit | endif
autocmd BufDelete * call k#UnregConsole()

autocmd FileType bat        nnoremap <buffer> <leader>r :call k#RunMe('cmd', 'botri 10', "")<CR>
autocmd FileType bat        nnoremap <buffer> <Enter>   :call k#RunLine('cmd', 'botri 10', "", "")<CR>
autocmd FileType sh         nnoremap <buffer> <leader>r :call k#RunMe('bash', 'botri 10', "")<CR>
autocmd FileType sh         nnoremap <buffer> <Enter>   :call k#RunLine('bash', 'botri 10', "", "")<CR>
autocmd FileType php        nnoremap <buffer> <leader>r :call k#RunMe('php', 'botri 10', "")<CR>
autocmd FileType php        nnoremap <buffer> <Enter>   :call k#RunLine('php', 'botri 10', "", "<?php")<CR>
autocmd FileType python     nnoremap <buffer> <leader>r :call k#RunMe('python', 'botri 10', "")<CR>
autocmd FileType python     nnoremap <buffer> <Enter>   :call k#RunLine('python', 'botri 10', "", "")<CR>
autocmd FileType ruby       nnoremap <buffer> <leader>r :call k#RunMe('ruby', 'botri 10', "")<CR>
autocmd FileType perl       nnoremap <buffer> <leader>r :call k#RunMe('perl', 'botri 10', "")<CR>
autocmd FileType javascript nnoremap <buffer> <leader>r :call k#RunMe('node', 'botri 10', "")<CR>
autocmd FileType coffee     nnoremap <buffer> <leader>r :call k#RunMe('coffee -s', 'botri 10', "")<CR>
autocmd FileType coffee     nnoremap <buffer> <leader>p :call k#RunMe('coffee -sbp', 'vert bel', "javascript")<CR>
autocmd FileType java       nnoremap <buffer> <leader>r :call k#RunMe('groovy -e', 'botri 10', "")<CR>
autocmd FileType jade       nnoremap <buffer> <leader>r :call k#RunMe('jade -P', 'vert bel', "html")<CR>
autocmd FileType make       nnoremap <buffer> <leader>r :call k#RunMe('make -f %', 'botri 10', "")<CR>
nnoremap <silent> <space><leader> :call k#CloseConsole()<CR>
com! -nargs=* -complete=command -bar Rc call k#ReadExCmdIntoConsole("botri 10", "", <q-args>)
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
      let l:type = substitute(fn,".*/\\(.*\\)/.*","\\1","")
      if has_key(g:globalDBkeys,l:type)
        exec "nnoremap <silent> ".g:globalDBkeys[l:type]." :call k#ReadExCmdIntoConsole('', '', '!kv query ".fn." '.expand('<cword>'))<CR>"
      else
        let l:localKeys = ['K', '<C-k>']
        if has_key(g:localDBkeys,l:type)
          let l:localKeys = g:localDBkeys[l:type]
        endif
        let l:actionToCall = ":call k#ReadExCmdIntoConsole('', '".l:type."', '!kv query ".fn." '.expand('<cword>'))"
        exec "autocmd FileType ".l:type." nnoremap <buffer> <silent> ".l:localKeys[0]." :".l:actionToCall."<CR>"
        exec "autocmd FileType ".l:type." inoremap <buffer> <silent> ".l:localKeys[1]." <Esc>:".l:actionToCall."<CR>a"
        let l:cmd = substitute(l:type,".","\\U&","")
        let l:actionToCall = substitute(l:actionToCall,"expand('<cword>')","<q-args>","")
        exec "com! -nargs=* -complete=command -bar ".l:cmd." ".l:actionToCall
      endif
    endif
  endfor
endfunction

call k#AutoLoadDict()
