" File specifics
" Git commit messages
autocmd FileType gitcommit setlocal spell

" Python
autocmd FileType python setlocal tabstop=4|setlocal shiftwidth=4|setlocal softtabstop=4
autocmd FileType python setlocal expandtab
autocmd FileType python setlocal smarttab

" TeX
autocmd FileType tex setlocal spell
autocmd FileType tex setlocal spl=en_gb

" C
au FileType c setlocal tabstop=2|setlocal shiftwidth=2|setlocal softtabstop=2
au FileType c setlocal expandtab 
au FileType c setlocal smarttab 
au FileType cpp setlocal tabstop=2|setlocal shiftwidth=2|setlocal softtabstop=2
au FileType cpp setlocal expandtab 
au FileType cpp setlocal smarttab 

" Nix
au FileType nix setlocal tabstop=2|setlocal shiftwidth=2|setlocal softtabstop=2
au FileType nix setlocal expandtab 
au FileType nix setlocal smarttab 

" Lua
au FileType lua setlocal tabstop=2|setlocal shiftwidth=2|setlocal softtabstop=2
au FileType lua setlocal expandtab 
au FileType lua setlocal smarttab 
