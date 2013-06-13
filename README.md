K.vim features VIM with key-value instant search from external dictionary(in StarDict format) using an external command line tool -- `kv`, thus with it you can

* translate word from an oxford english dictionary
* get a quick referrence to some function of some kind of programming langugae
* get a quick help from you own dictionary, which you can build from a plain text file by `kv`


# Installation

1. get and build `kv` tool from https://github.com/brookhong/kv
1. put k.vim to your .vim/plugin folder
1. build or download dictionaries you need to some folder, and tell VIM where it is

    let g:kdbDir = $HOME.'/kdb'

I have shared some of my dictionaries here https://www.dropbox.com/sh/75leolu1dso27qn/lG7VSrv1l7

# Configuration

    " the plugin will scan this directory to create key mapping globally or specially for some type of file.
    let g:kdbDir = $HOME.'/kdb'
    " when press `<leader>,`, will translate word under the cursor, works for all kinds of files.
    let g:globalDBkeys = {
          \ 'oxford-gb' : '<leader>,',
          \ }
    " when press `K` in normal mode or `C-j` in insert mode, will get referrence of function under the cursor, works only for php file.
    " for file-type dictionaries, they must be named same as the file type.
    let g:localDBkeys = {
          \ 'php' : ['K', '<C-j>'],
          \ }
