K.vim now evolves to be a plugin to let you quickly run external command, and show the result
in a scratch window.

1. press `<leader><leader>` to show explanation of word with call to an external
command `kv`, https://github.com/brookhong/kv

1. press `<space><leader>` to close the scratch window

1. press `<leader>r` to run all scripts in a buffer

1. press `<enter>` to run curren line.

![Screencast of K.vim](http://drp.io/files/5357c687a659a.gif)

# Installation of scripts binding
For scripts running, you need two things to be prepared

* The script interpreters like perl/python to be in PATH, so that VIM can launch it.
* `set ft` so that VIM knows what kind of script to be run.

# Installation of kv binding
K.vim features VIM with key-value instant search from external dictionary(in StarDict format) using an external command line tool -- `kv`, thus with it you can

* translate word from an oxford english dictionary
* get a quick referrence to some function of some kind of programming langugae
* get a quick help from you own dictionary, which you can build from a plain text file by `kv`


## Installation

1. get and build `kv` tool from https://github.com/brookhong/kv
1. copy kv or kv.exe to a folder in your path such as /usr/local/bin or C:\Windows\system32
1. put k.vim to your .vim/plugin folder
1. build or download dictionaries you need to some folder, and tell VIM where it is

    let g:kdbDir = $HOME.'/kdb'

I have shared some of my dictionaries here https://www.dropbox.com/sh/75leolu1dso27qn/lG7VSrv1l7

## Configuration

    " the plugin will scan this directory to create key mapping globally or specially for some type of file.
    let g:kdbDir = $HOME.'/kdb'
    " when press `<leader>,`, will translate word under the cursor, works for all kinds of files.
    let g:globalDBkeys = {
          \ 'oxford' : '<leader>,',
          \ }
    " when press `K` in normal mode or `C-j` in insert mode, will get referrence of function under the cursor, works for php file or C file.
    " for file-type dictionaries, the folder must be named same as the file type.
    let g:localDBkeys = {
          \ 'php' : ['K', '<C-j>'],
          \ 'c' : ['K', '<C-j>'],
          \ }

## Usage

For global dictionaries, with cursor on a word, press the key you set in `g:globalDBkeys` to search.
For file-type dictionaries, open a file, with cursor on a word, press the key you set in `g:localDBkeys` to search.
The result is displayed in a split window, you can close it by `<Space>,` in normal mode.
