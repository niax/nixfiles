" Telescope Configs
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <space>/ <cmd>Telescope live_grep<cr>
nnoremap <space>b <cmd>Telescope buffers<cr>

" lightline Configs
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }
