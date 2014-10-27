" =============================================================================
" File:          autoload/ctrlp/k.vim
" Description:   k extension for ctrlp.vim
" =============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['k']
"
" Where 'k' is the name of the file 'k.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]

" Load guard
if ( exists('g:loaded_ctrlp_k') && g:loaded_ctrlp_k )
            \ || v:version < 700 || &cp
    finish
endif
let g:loaded_ctrlp_k = 1

if !exists('g:ctrlp_k_favorites')
    let g:ctrlp_k_favorites = '~/.ctrlpk'
endif


" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
call add(g:ctrlp_ext_vars, {
            \ 'init': 'ctrlp#k#init()',
            \ 'accept': 'ctrlp#k#accept',
            \ 'lname': 'quick launcher',
            \ 'sname': 'k',
            \ 'type': 'line',
            \ 'enter': 'ctrlp#k#enter()',
            \ 'exit': 'ctrlp#k#exit()',
            \ 'opts': 'ctrlp#k#opts()',
            \ 'sort': 0,
            \ 'specinput': 0,
            \ })


" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#k#init()
    let input = ['## EDIT K ##']
    if filereadable(g:ctrlp_k_favorites)
        let input = input + readfile(g:ctrlp_k_favorites)
    endif
    return input
endfunction


" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#k#accept(mode, str)
    " For this example, just exit ctrlp and run help
    call ctrlp#exit()
    if a:str == '## EDIT K ##'
        exec ':sn '.g:ctrlp_k_favorites
    else
        let @k = a:str
        let l:cmd = 'bash'
        if has("win32")
            let l:cmd = 'cmd'
        endif
        call k#RunReg('k', l:cmd, 'botri 20', '', '')
    endif
endfunction


" (optional) Do something before enterting ctrlp
function! ctrlp#k#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#k#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#k#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#k#id()
    return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/k.vim
" command! CtrlPK call ctrlp#init(ctrlp#k#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2