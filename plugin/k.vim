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

let g:path_separator = '/'
if has("win32")
  let g:path_separator = '\\'
endif
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
      setlocal ff=unix
      setlocal nolist
      map <buffer> q :q<CR>
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

function! KReadExCmdIntoConsole(winOp,ft,exCmd)
  let l:result = <SID>RunCmd(a:exCmd)
  let l:mw = bufnr('%')
  call <SID>FocusMyConsole(a:winOp)
  exec "set ft=".a:ft
  exec "normal gg\"_dG"
  call append(0, l:result)
  execute "normal gg"
  execute bufwinnr(l:mw)."wincmd w"
endfunction

function! s:ReadExCmd(exCmd)
  let l:result = <SID>RunCmd(a:exCmd)
  call append(0, l:result)
endfunction

let g:cf_options = {'window_open': 'botri 10', 'console_filetype': '', 'input_as_text': 0, 'line_prefix': ''}
function! s:prepareOptions(default_options, override_options)
  let l:cf_options = deepcopy(a:default_options)
  for key in keys(a:override_options)
    let l:cf_options[key] = a:override_options[key]
  endfor
  return l:cf_options
endfunction

function! KRunReg(reg, interpreter, cf_options)
  let l:cf_options = g:cf_options
  if exists('b:cf_options')
    let l:cf_options = <SID>prepareOptions(l:cf_options, b:cf_options)
  endif
  if len(keys(a:cf_options))
    let l:cf_options = <SID>prepareOptions(l:cf_options, a:cf_options)
  endif
  call <SID>FocusMyConsole(l:cf_options['window_open'])
  exec "set ft=".l:cf_options['console_filetype']
  exec "normal ggdG"
  exec "normal \"".a:reg."p"
  if l:cf_options['line_prefix'] != ''
    call append(0, l:cf_options['line_prefix'])
  endif
  if l:cf_options['input_as_text']
    let l:str = substitute(getreg(a:reg), '"' , '\\"', "g")
    let l:str = substitute(l:str, '\s*\n\s*$', '', 'g')
    silent exec '%!'.a:interpreter.' "'.l:str.'"'
  else
    silent exec '%!'.a:interpreter
  endif
  execute "normal \<c-w>p"
endfunction

function! KRunMe(interpreter, ...)
  silent 1,$y k
  let l:cf_options = a:0 ? a:1 : {}
  call KRunReg('k', a:interpreter, l:cf_options)
endfunction

function! s:RunInteractive(...)
  call inputsave()
  let l:interpreter = input("Run with:")
  call inputrestore()
  if l:interpreter != ""
    let l:cf_options = a:0 ? a:1 : {}
    call KRunReg('k', l:interpreter, l:cf_options)
  else
    echomsg "Canceled as no interpreter was specified."
  endif
endfunction

function! s:BufInit()
    let l:kargs = matchlist(getline(1), '.*\s\+k.vim\s\+\(.\+\)\s\+k.vim.*')
    if len(l:kargs) > 1
        exec l:kargs[1]
    endif
endfunction

function! s:RunLine(interpreter, ...)
  call <SID>BufInit()
  let l:interpreter = exists('b:interpreter') ? b:interpreter : a:interpreter
  normal "kyy
  if @k[0] == '!'
    exec @k
  else
    let l:cf_options = a:0 ? a:1 : {}
    call KRunReg('k', l:interpreter, l:cf_options)
  endif
endfunction

vnoremap <silent> <leader>r "ky:call <SID>RunInteractive({'window_open': 'botri 30'})<cr>

function! KCloseConsole()
  if exists('b:consoleWin') && bufwinnr(b:consoleWin) != -1
    execute b:consoleWin."bd"
  endif
endfunction

function! s:UnregConsole()
  if winbufnr(3) != -1 && exists('b:consoleWin') && bufwinnr(b:consoleWin) != -1
    execute b:consoleWin."bd"
  endif
endfunction

autocmd BufEnter * if &buftype=="nofile" && winbufnr(2) == -1 && exists('b:lordWin') == 1 | quit | endif
autocmd BufDelete * call <SID>UnregConsole()

autocmd FileType DOSBATCH   nnoremap <buffer> <leader>r :call KRunMe('cmd')<CR>
autocmd FileType DOSBATCH   nnoremap <buffer> <Enter>   :call <SID>RunLine('cmd')<CR>
autocmd FileType sh         nnoremap <buffer> <leader>r :call KRunMe('bash')<CR>
autocmd FileType sh         nnoremap <buffer> <Enter>   :call <SID>RunLine('bash')<CR>
autocmd FileType sh         nnoremap <buffer> <kEnter>  :call <SID>RunLine('bash')<CR>
autocmd FileType sh         nnoremap <buffer> <C-Enter> :call <SID>RunLine('bash', {'window_open': 'vert bel'})<CR>
autocmd FileType zsh        nnoremap <buffer> <leader>r :call KRunMe('zsh')<CR>
autocmd FileType php        nnoremap <buffer> <leader>r :call KRunMe('php')<CR>
autocmd FileType php        nnoremap <buffer> <Enter>   :call <SID>RunLine('php', {'line_prefix': '<?php'})<CR>
autocmd FileType python     nnoremap <buffer> <leader>r :call KRunMe('python')<CR>
autocmd FileType python     nnoremap <buffer> <Enter>   :call <SID>RunLine('python')<CR>
autocmd FileType mysql      nnoremap <buffer> <Enter>   :call <SID>RunLine('mysql -uroot -e', {'input_as_text': 1})<CR>
autocmd FileType ruby       nnoremap <buffer> <leader>r :call KRunMe('ruby')<CR>
autocmd FileType perl       nnoremap <buffer> <leader>r :call KRunMe('perl')<CR>
autocmd FileType javascript nnoremap <buffer> <leader>r :call KRunMe('node')<CR>
autocmd FileType coffee     nnoremap <buffer> <leader>r :call KRunMe('coffee -s')<CR>
autocmd FileType coffee     nnoremap <buffer> <leader>p :call KRunMe('coffee -sbp', {'window_open': 'vert bel', 'console_filetype': 'javascript'})<CR>
autocmd FileType java       nnoremap <buffer> <leader>r :call KRunMe('groovy -e')<CR>
autocmd FileType jade       nnoremap <buffer> <leader>r :call KRunMe('jade -P', {'window_open': 'vert bel', 'console_filetype': 'html'})<CR>
autocmd FileType make       nnoremap <buffer> <leader>r :call KRunMe('make -f %')<CR>
autocmd FileType cpp        nnoremap <buffer> <leader>rc :w<Bar>let cmd='g++ '.expand('%').' -o '.expand('%:r').'.exe'<Bar>call KRunMe(cmd)<CR>
autocmd FileType c          nnoremap <buffer> <leader>rc :w<Bar>let cmd='gcc '.expand('%').' -o '.expand('%:r').'.exe'<Bar>call KRunMe(cmd)<CR>
autocmd FileType c,cpp      nnoremap <buffer> <leader>rx :let cmd=expand('%:h').g:path_separator.expand('%:r').'.exe'<Bar>call KRunMe(cmd)<CR>
autocmd FileType java       nnoremap <buffer> <leader>rc :w<Bar>let cmd='javac '.expand('%')<Bar>call KRunMe(cmd)<CR>
autocmd FileType java       nnoremap <buffer> <leader>rx :let cmd='java '.expand('%:r')<Bar>call KRunMe(cmd)<CR>
nnoremap <silent> <space><leader> :call KCloseConsole()<CR>
com! -nargs=* -complete=command -bar Rc call KReadExCmdIntoConsole("botri 10", "", <q-args>)
com! -nargs=* -complete=command -bar Ri call <SID>ReadExCmd(<q-args>)
com! -nargs=1 -complete=customlist,GetFileTypes Ft let &ft=<f-args>
com! -nargs=1 -complete=shellcmd Man call KReadExCmdIntoConsole("botri", "", "!man ".<q-args>)
command! CtrlPK call ctrlp#init(ctrlp#k#id())

" echo Plugins(&rtp, 'colors/ir', 'vim')
function! Plugins(path, prefix, ext)
    let cf = globpath(a:path, a:prefix."*.".a:ext)
    let cl = split(cf, '\n')
    let cl = map(cl, 'substitute(v:val, ".*[/\\\\]\\(.*\\).'.a:ext.'", "\\1", "g")')
    let cl = uniq(sort(cl))
    return cl
endfunction

function! GetFileTypes(A,L,P)
  return Plugins(&rtp, 'syntax/'.a:A, 'vim')
endfunction

function! s:TestScript()
    let nr = input('TestScript > ', '', 'customlist,GetFileTypes')
    if nr != ""
      new
      set bt=nofile
      let &ft=nr
    endif
endfunction
nnoremap <silent> <leader>t :call <SID>TestScript()<CR>

function! Rl(ln)
    let l:kargs = matchlist(getline(a:ln), '.*\s\+k.vim#\(\S\+\)\s\+\(.\+\)')
    if len(l:kargs) > 2
        let @k = l:kargs[2]
        call KRunReg('k', l:kargs[1], {'window_open': 'botri 20'})
    endif
endfunction
com! -nargs=1 -bar Rl call Rl(<q-args>)
