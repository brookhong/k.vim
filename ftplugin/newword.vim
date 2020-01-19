" augroup AutoExplain
    " au!
    autocmd! CursorMoved <buffer> call Explain(0)
" augroup END
nnoremap <buffer> <silent> <leader><leader> :call Explain(1)<CR>
