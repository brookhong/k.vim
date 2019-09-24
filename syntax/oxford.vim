syntax match ExplainationId   /^\d\+/
syntax match ExampleBullet   /^        \* .*/
syntax match Phonetic   /^\/.*\/ /

if &background == "dark"
    highlight ExplainationId   ctermfg=DarkRed guifg=#e00000
    highlight ExampleBullet   ctermfg=LightGray guifg=#818181
    highlight Phonetic   ctermfg=LightGreen guifg=#a0a000
else
    highlight ExplainationId   ctermfg=DarkRed guifg=#a00000
    highlight ExampleBullet   ctermfg=LightGray guifg=#515151
    highlight Phonetic   ctermfg=LightGreen guifg=#707000
endif
